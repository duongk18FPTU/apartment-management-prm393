const {readFileSync} = require("node:fs");
const path = require("node:path");
const {after, before, beforeEach, describe, test} = require("node:test");

const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require("@firebase/rules-unit-testing");
const {
  collection,
  doc,
  getDoc,
  getDocs,
  serverTimestamp,
  setDoc,
  updateDoc,
} = require("firebase/firestore");

const hasEmulator = Boolean(process.env.FIRESTORE_EMULATOR_HOST);

describe("Firestore user security rules", {skip: !hasEmulator}, () => {
  let environment;

  const userProfile = (fullName, email, role) => ({
    fullName,
    email,
    phone: "0901234567",
    role,
    apartmentId: null,
    nationalId: "012345678901",
    dateOfBirth: null,
    avatarUrl: null,
    status: "active",
    createdAt: new Date("2026-01-01T00:00:00Z"),
    updatedAt: new Date("2026-01-01T00:00:00Z"),
  });

  before(async () => {
    environment = await initializeTestEnvironment({
      projectId: "demo-apartment-management",
      firestore: {
        rules: readFileSync(
          path.resolve(__dirname, "../../firestore.rules"),
          "utf8",
        ),
      },
    });
  });

  beforeEach(async () => {
    await environment.clearFirestore();
    await environment.withSecurityRulesDisabled(async (context) => {
      const database = context.firestore();
      await setDoc(
        doc(database, "users/admin-1"),
        userProfile("Admin One", "admin@example.com", "admin"),
      );
      await setDoc(
        doc(database, "users/resident-1"),
        userProfile("Resident One", "resident1@example.com", "resident"),
      );
      await setDoc(
        doc(database, "users/resident-2"),
        userProfile("Resident Two", "resident2@example.com", "resident"),
      );
    });
  });

  after(async () => environment.cleanup());

  test("allows active admins to list users", async () => {
    const database = environment.authenticatedContext("admin-1").firestore();
    await assertSucceeds(getDocs(collection(database, "users")));
  });

  test("allows residents to read only their own profile", async () => {
    const database = environment
      .authenticatedContext("resident-1")
      .firestore();
    await assertSucceeds(getDoc(doc(database, "users/resident-1")));
    await assertFails(getDoc(doc(database, "users/resident-2")));
    await assertFails(getDocs(collection(database, "users")));
  });

  test("allows active admins to create and manage user profiles", async () => {
    const database = environment.authenticatedContext("admin-1").firestore();
    await assertSucceeds(
      setDoc(doc(database, "users/staff-1"), {
        ...userProfile("Staff One", "staff@example.com", "staff"),
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
      }),
    );
    await assertSucceeds(
      updateDoc(doc(database, "users/resident-1"), {
        role: "staff",
        status: "inactive",
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test("prevents an admin from removing their own access", async () => {
    const database = environment.authenticatedContext("admin-1").firestore();
    await assertFails(
      updateDoc(doc(database, "users/admin-1"), {
        role: "resident",
        updatedAt: serverTimestamp(),
      }),
    );
    await assertFails(
      updateDoc(doc(database, "users/admin-1"), {
        status: "inactive",
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test("denies Firestore access after an admin marks a user inactive", async () => {
    const adminDatabase = environment
      .authenticatedContext("admin-1")
      .firestore();
    await assertSucceeds(
      updateDoc(doc(adminDatabase, "users/resident-2"), {
        status: "inactive",
        updatedAt: serverTimestamp(),
      }),
    );

    const inactiveDatabase = environment
      .authenticatedContext("resident-2")
      .firestore();
    await assertFails(getDoc(doc(inactiveDatabase, "users/resident-2")));
  });

  test("allows safe self-profile updates but rejects role changes", async () => {
    const database = environment
      .authenticatedContext("resident-1")
      .firestore();
    await assertSucceeds(
      updateDoc(doc(database, "users/resident-1"), {
        phone: "0901234567",
      }),
    );
    await assertFails(
      updateDoc(doc(database, "users/resident-1"), {role: "admin"}),
    );
  });

  test("denies unauthenticated profile reads", async () => {
    const database = environment.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(database, "users/resident-1")));
  });
});
