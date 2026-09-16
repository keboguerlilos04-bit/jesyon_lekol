import { onCall, HttpsError } from "firebase-functions/v2/https";
import { auth, db } from "./admin";
import { assertAdmin } from "./assertAdmin";
import * as admin from "firebase-admin";

interface ApproveEnrollmentData {
  requestId: string;
}

/**
 * Admin-only: turns a pending /enrollmentRequests document into a real
 * /students record, creating (or reusing, for a second child) the parent's
 * Firebase Auth account and appending to their studentIds custom claim.
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

  const parentEmail: string = data.parentEmail;
  let passwordResetLink: string | undefined;
  let parentUid: string;

  try {
    const existing = await auth.getUserByEmail(parentEmail);
    parentUid = existing.uid;
  } catch (err) {
    const userRecord = await auth.createUser({
      email: parentEmail,
      displayName: data.parentFullName,
      password: `Tmp-${Math.random().toString(36).slice(2)}${Date.now()}`,
    });
    parentUid = userRecord.uid;
    passwordResetLink = await auth.generatePasswordResetLink(parentEmail);

    await db.collection("users").doc(parentUid).set({
      fullName: data.parentFullName,
      email: parentEmail,
      phone: data.parentPhone || null,
      role: "parent",
      active: true,
    });
  }

  const studentRef = db.collection("students").doc();
  await studentRef.set({
    firstName: data.studentFirstName,
    lastName: data.studentLastName,
    dob: data.dob || null,
    sex: data.sex || null,
    classId: data.classId,
    parentIds: admin.firestore.FieldValue.arrayUnion(parentUid),
    enrollmentStatus: "active",
  });

  await db.collection("parents").doc(parentUid).set(
    {
      studentIds: admin.firestore.FieldValue.arrayUnion(studentRef.id),
      phone: data.parentPhone || null,
    },
    { merge: true }
  );

  // Custom claims can't use arrayUnion — read the current list and append.
  const parentUser = await auth.getUser(parentUid);
  const currentStudentIds: string[] = (parentUser.customClaims?.studentIds as string[]) || [];
  await auth.setCustomUserClaims(parentUid, {
    role: "parent",
    studentIds: [...new Set([...currentStudentIds, studentRef.id])],
  });

  await requestRef.update({
    status: "approved",
    linkedStudentId: studentRef.id,
    linkedParentUid: parentUid,
  });

  return { studentId: studentRef.id, parentUid, passwordResetLink };
});
