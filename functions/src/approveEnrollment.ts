import { onCall, HttpsError } from "firebase-functions/v2/https";
import { auth, db } from "./admin";
import { assertAdmin } from "./assertAdmin";
import { generateTempPassword } from "./tempPassword";
import * as admin from "firebase-admin";

interface ApproveEnrollmentData {
  requestId: string;
}

interface CreatedAccount {
  uid: string;
  email: string;
  tempPassword?: string; // absent when the account already existed
}

/**
 * Creates the parent's Firebase Auth account if it doesn't already exist
 * (a second child's enrollment reuses the same parent by email), links the
 * student to it, and (re)appends studentId to their custom claims. Returns
 * a tempPassword only when the account was freshly created.
 */
async function upsertParent(
  email: string,
  fullName: string,
  phone: string | null | undefined,
  studentId: string
): Promise<CreatedAccount> {
  let uid: string;
  let tempPassword: string | undefined;

  try {
    uid = (await auth.getUserByEmail(email)).uid;
  } catch (err) {
    tempPassword = generateTempPassword();
    uid = (
      await auth.createUser({ email, displayName: fullName, password: tempPassword })
    ).uid;
    await db.collection("users").doc(uid).set({
      fullName,
      email,
      phone: phone || null,
      role: "parent",
      active: true,
      mustChangePassword: true,
    });
  }

  await db.collection("parents").doc(uid).set(
    { studentIds: admin.firestore.FieldValue.arrayUnion(studentId), phone: phone || null },
    { merge: true }
  );

  // Custom claims can't use arrayUnion — read the current list and append.
  const parentUser = await auth.getUser(uid);
  const currentStudentIds: string[] = (parentUser.customClaims?.studentIds as string[]) || [];
  await auth.setCustomUserClaims(uid, {
    role: "parent",
    studentIds: [...new Set([...currentStudentIds, studentId])],
  });

  return { uid, email, tempPassword };
}

/**
 * Admin-only: turns a pending /enrollmentRequests document into a real
 * /students record, creating the student's own login, the parent's Firebase
 * Auth account (or a second parent's, if provided) and linking them all
 * together via studentIds custom claims.
 *
 * This is the ONLY path that is allowed to create a /students document with
 * a parentIds link or grant a parent account access to a child's records —
 * firestore.rules refuses that write from any client, including an admin's.
 */
export const approveEnrollment = onCall<ApproveEnrollmentData>(async (request) => {
  assertAdmin(request);

  const { requestId } = request.data;
  if (!requestId) {
    throw new HttpsError("invalid-argument", "requestId obligatwa.");
  }

  const requestRef = db.collection("enrollmentRequests").doc(requestId);
  const requestSnap = await requestRef.get();
  if (!requestSnap.exists) {
    throw new HttpsError("not-found", "Demann enskripsyon an pa egziste.");
  }
  const data = requestSnap.data()!;
  if (data.status !== "pending") {
    throw new HttpsError("failed-precondition", "Demann sa a deja trete.");
  }

  const studentRef = db.collection("students").doc();

  const parent = await upsertParent(data.parentEmail, data.parentFullName, data.parentPhone, studentRef.id);
  let parent2: CreatedAccount | undefined;
  if (data.parent2Email && data.parent2FullName) {
    parent2 = await upsertParent(data.parent2Email, data.parent2FullName, data.parent2Phone, studentRef.id);
  }

  // The student's own login is optional per school, but we create one by
  // default at enrollment time so credentials are handed out once, up
  // front, rather than as a separate manual step later.
  const studentTempPassword = generateTempPassword();
  const studentEmail: string | undefined = data.studentEmail || undefined;
  let studentUid: string | undefined;
  if (studentEmail) {
    const studentUser = await auth.createUser({
      email: studentEmail,
      displayName: `${data.studentFirstName} ${data.studentLastName}`,
      password: studentTempPassword,
    });
    studentUid = studentUser.uid;
    await auth.setCustomUserClaims(studentUid, { role: "student", studentId: studentRef.id });
    await db.collection("users").doc(studentUid).set({
      fullName: `${data.studentFirstName} ${data.studentLastName}`,
      email: studentEmail,
      role: "student",
      active: true,
      mustChangePassword: true,
    });
  }

  const parentIds = [parent.uid, ...(parent2 ? [parent2.uid] : [])];
  await studentRef.set({
    firstName: data.studentFirstName,
    lastName: data.studentLastName,
    dob: data.dob || null,
    sex: data.sex || null,
    classId: data.classId,
    uid: studentUid || null,
    parentIds,
    enrollmentStatus: "active",
  });

  await requestRef.update({
    status: "approved",
    linkedStudentId: studentRef.id,
    linkedParentUid: parent.uid,
  });

  return {
    studentId: studentRef.id,
    parentUid: parent.uid,
    accounts: [
      { role: "parent", email: parent.email, tempPassword: parent.tempPassword },
      ...(parent2 ? [{ role: "parent", email: parent2.email, tempPassword: parent2.tempPassword }] : []),
      ...(studentUid ? [{ role: "student", email: studentEmail, tempPassword: studentTempPassword }] : []),
    ],
  };
});
