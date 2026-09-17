import { onCall, HttpsError } from "firebase-functions/v2/https";
import { auth, db } from "./admin";
import { assertAdmin } from "./assertAdmin";

interface ApplyProfileChangeData {
  requestId: string;
  approve: boolean; // false = reject
  adminNote?: string;
}

/**
 * Admin-only: approves or rejects a /profileChangeRequests document.
 *
 * Only 'email' and 'role' changes are routed through this function, since
 * those touch Firebase Auth itself (login email, custom claims) and so
 * can't be applied with a plain Firestore write the way name/phone/sex/
 * classId changes are (handled directly by the admin UI via the normal
 * admin-write rule on /users and /students). Rejecting never needs the
 * Admin SDK, but is handled here too so every request goes through one
 * server-trusted path instead of letting the client flip `status` itself.
 */
export const applyProfileChangeRequest = onCall<ApplyProfileChangeData>(async (request) => {
  const adminUid = assertAdmin(request);

  const { requestId, approve, adminNote } = request.data;
  if (!requestId) {
    throw new HttpsError("invalid-argument", "requestId obligatwa.");
  }

  const reqRef = db.collection("profileChangeRequests").doc(requestId);
  const reqSnap = await reqRef.get();
  if (!reqSnap.exists) {
    throw new HttpsError("not-found", "Demann chanjman an pa egziste.");
  }
  const data = reqSnap.data()!;
  if (data.status !== "pending") {
    throw new HttpsError("failed-precondition", "Demann sa a deja trete.");
  }

  if (!approve) {
    await reqRef.update({
      status: "rejected",
      reviewedBy: adminUid,
      adminNote: adminNote || null,
    });
    return { status: "rejected" };
  }

  const { targetCollection, targetId, field, requestedValue } = data;

  if (field === "email") {
    await auth.updateUser(targetId, { email: requestedValue });
    await db.collection(targetCollection).doc(targetId).update({ email: requestedValue });
  } else if (field === "role") {
    const user = await auth.getUser(targetId);
    await auth.setCustomUserClaims(targetId, { ...user.customClaims, role: requestedValue });
    await db.collection(targetCollection).doc(targetId).update({ role: requestedValue });
  } else {
    // Defense in depth: the client only ever creates email/role requests
    // for this function (everything else applies via a plain admin write),
    // but never trust that assumption alone.
    throw new HttpsError(
      "invalid-argument",
      `Chan sa a (${field}) pa mande Cloud Function — modifye l dirèkteman.`
    );
  }

  await reqRef.update({
    status: "approved",
    reviewedBy: adminUid,
    adminNote: adminNote || null,
  });

  return { status: "approved" };
});
