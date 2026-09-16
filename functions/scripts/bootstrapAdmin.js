// One-off local bootstrap: creates the very first admin account directly
// with the Admin SDK, bypassing createStaffAccount's assertAdmin check
// (which nothing can satisfy before an admin exists). Run once, then rely
// on the in-app "Anplwaye" screen (createStaffAccount) for every account
// after this. Never deployed — this only ever runs on a developer machine
// against the service account key in this same folder.
//
// Usage: node scripts/bootstrapAdmin.js <email> "<full name>" ["<position>"]

const admin = require("firebase-admin");
const serviceAccount = require("../serviceAccountKey.json");

const [, , email, fullName, position] = process.argv;

if (!email || !fullName) {
  console.error('Usage: node scripts/bootstrapAdmin.js <email> "<full name>" ["<position>"]');
  process.exit(1);
}

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });

async function main() {
  const auth = admin.auth();
  const db = admin.firestore();

  let userRecord;
  try {
    userRecord = await auth.getUserByEmail(email);
    console.log(`Kont ${email} deja egziste (uid: ${userRecord.uid}). M ap mete claims/dokiman ajou.`);
  } catch (err) {
    userRecord = await auth.createUser({
      email,
      displayName: fullName,
      password: `Tmp-${Math.random().toString(36).slice(2)}${Date.now()}`,
    });
    console.log(`Kont kreye pou ${email} (uid: ${userRecord.uid}).`);
  }

  await auth.setCustomUserClaims(userRecord.uid, { role: "admin" });

  await db.collection("users").doc(userRecord.uid).set({
    fullName,
    email,
    role: "admin",
    position: position || "Direktè",
    active: true,
  });

  const link = await auth.generatePasswordResetLink(email);

  console.log("\n=== Bootstrap Admin fini ===");
  console.log(`UID: ${userRecord.uid}`);
  console.log(`Lyen pou defini modpas:\n${link}`);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Erè:", err);
    process.exit(1);
  });
