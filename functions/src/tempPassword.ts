import * as crypto from "crypto";

const ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // no O/0, I/1 — easier to read aloud/copy

/**
 * A short, human-shareable temporary password (e.g. "K7H2-PQ9X") — printable
 * or read over the phone by a secretary, unlike a UUID. Never persisted
 * anywhere in plaintext: Firebase Auth stores only its hash, and the caller
 * is expected to hand it to the account owner once and discard it. Paired
 * with `mustChangePassword: true` on the /users doc so the app forces a
 * real password to be set before anything else is usable.
 */
export function generateTempPassword(): string {
  const chars = Array.from(
    { length: 8 },
    () => ALPHABET[crypto.randomInt(ALPHABET.length)]
  );
  return `${chars.slice(0, 4).join("")}-${chars.slice(4).join("")}`;
}
