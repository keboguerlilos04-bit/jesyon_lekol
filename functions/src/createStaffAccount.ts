import { onCall, HttpsError } from "firebase-functions/v2/https";
import { auth, db } from "./admin";
import { assertAdmin } from "./assertAdmin";

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
 * Returns a password-reset link instead of a temporary password so the new
 * account owner sets their own credential — this project has no outbound
 * email configured yet, so the admin is expected to hand the link over
 * directly (SMS, WhatsApp, in person, etc.) until that's wired up.
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

  const userRecord = await auth.createUser({
    email: email.trim(),
    displayName: fullName.trim(),
    password: cryptoRandomPassword(),
  });

  await auth.setCustomUserClaims(userRecord.uid, { role });

  await db.collection("users").doc(userRecord.uid).set({
    fullName: fullName.trim(),
    email: email.trim(),
    role,
    position: position?.trim() || null,
    active: true,
  });

  if (role === "teacher") {
    await db.collection("teachers").doc(userRecord.uid).set({
      subjectIds,
      classIds,
    });
  }

  const passwordResetLink = await auth.generatePasswordResetLink(email.trim());

  return { uid: userRecord.uid, passwordResetLink };
});

function cryptoRandomPassword(): string {
  // Never actually used to sign in — the account owner sets their own
  // password via the reset link returned above.
  return `Tmp-${Math.random().toString(36).slice(2)}${Date.now()}`;
}
