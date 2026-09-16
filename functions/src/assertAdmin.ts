import { CallableRequest, HttpsError } from "firebase-functions/v2/https";

/**
 * Every privileged callable in this project must start with this check.
 * The role claim is trusted here because it can only ever have been set by
 * these same Cloud Functions (via auth.setCustomUserClaims) — never by a
 * client write — so a forged ID token cannot carry role: "admin".
 */
export function assertAdmin(request: CallableRequest): string {
  const uid = request.auth?.uid;
  const role = request.auth?.token?.role;
  if (!uid || role !== "admin") {
    throw new HttpsError("permission-denied", "Sèlman admin ka fè aksyon sa a.");
  }
  return uid;
}
