import { onCall, HttpsError } from "firebase-functions/v2/https";
import { auth, db } from "./admin";
import { assertAdmin } from "./assertAdmin";
import { generateTempPassword } from "./tempPassword";

interface CreateStaffData {
  fullName: string;
  email: string;
  role: "admin" | "teacher";
  position?: string;
  subjectIds?: string[];
  classIds?: string[];
}

const ALLOWED_ROLES = new Set(["admin", "teacher"]);

/**
 * Admin-only: creates a Firebase Auth account for a new employee (teacher or
 * a secretary given admin-level app access), sets their role custom claim,
 * and writes the matching /users (and, for teachers, /teachers) document.
 *
 * Returns a short temporary password the admin hands to the new employee
 * directly (this project has no outbound email configured yet). The
 * account is flagged `mustChangePassword: true`, which the app's router
 * enforces by routing straight to a change-password screen on first sign-in
 * — the temporary password is never usable for anything beyond that.
 */
export const createStaffAccount = onCall<CreateStaffData>(async (request) => {
  assertAdmin(request);

  const { fullName, email, role, position, subjectIds = [], classIds = [] } = request.data;

  if (!fullName?.trim() || !email?.trim()) {
    throw new HttpsError("invalid-argument", "Non ak email obligatwa.");
  }
  if (!ALLOWED_ROLES.has(role)) {
    throw new HttpsError("invalid-argument", `Wòl envalid: ${role}`);
  }

  const tempPassword = generateTempPassword();

  const userRecord = await auth.createUser({
    email: email.trim(),
    displayName: fullName.trim(),
    password: tempPassword,
  });

  await auth.setCustomUserClaims(userRecord.uid, { role });

  await db.collection("users").doc(userRecord.uid).set({
    fullName: fullName.trim(),
    email: email.trim(),
    role,
    position: position?.trim() || null,
    active: true,
    mustChangePassword: true,
  });

  if (role === "teacher") {
    await db.collection("teachers").doc(userRecord.uid).set({
      subjectIds,
      classIds,
    });
  }

  return { uid: userRecord.uid, tempPassword };
});
