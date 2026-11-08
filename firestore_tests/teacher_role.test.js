// Security rules tests for the teacher role (DEL-4 / BL-19).
// Run from the project root: npm --prefix firestore_tests test

import { after, before, beforeEach, describe, test } from 'node:test';
import { readFileSync } from 'node:fs';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, serverTimestamp, setDoc, Timestamp, updateDoc } from 'firebase/firestore';

let env;

const profile = (uid, role) => ({
  uid,
  name: `User ${uid}`,
  username: `user_${uid}`,
  email: `${uid}@delta.edu`,
  role,
  createdAt: serverTimestamp(),
});

const question = {
  id: 'q1',
  statement: 'Por que há quem diga que o português do Brasil parece outra língua?',
  options: ['Pela escrita distinta', 'Pela pronúncia distinta'],
  correctOptionIndex: 1,
};

const db = (uid) => (uid ? env.authenticatedContext(uid) : env.unauthenticatedContext()).firestore();

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-delta',
    firestore: {
      // RULES_FILE lets you run the suite against another version of the rules.
      rules: readFileSync(process.env.RULES_FILE ?? new URL('../firestore.rules', import.meta.url), 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

beforeEach(async () => {
  await env.clearFirestore();
  // Existing accounts, written as an admin would (bypassing the rules).
  await env.withSecurityRulesDisabled(async (ctx) => {
    const admin = ctx.firestore();
    for (const [uid, role] of [['student', 'student'], ['pending', 'teacher_pending'], ['teacher', 'teacher']]) {
      await setDoc(doc(admin, 'users', uid), { ...profile(uid, role), createdAt: Timestamp.now() });
    }
  });
});

after(async () => {
  await env.cleanup();
});

describe('AC4: sign-up never creates a teacher', () => {
  test('a new user cannot create their profile with role teacher', async () => {
    await assertFails(setDoc(doc(db('new'), 'users', 'new'), profile('new', 'teacher')));
  });

  test('a new user can create their profile with role teacher_pending', async () => {
    await assertSucceeds(setDoc(doc(db('new'), 'users', 'new'), profile('new', 'teacher_pending')));
  });

  test('a new user can create their profile with role student', async () => {
    await assertSucceeds(setDoc(doc(db('new'), 'users', 'new'), profile('new', 'student')));
  });

  test('a user cannot create a profile for someone else', async () => {
    await assertFails(setDoc(doc(db('new'), 'users', 'other'), profile('other', 'student')));
  });

  test('a signed-out visitor cannot create a profile', async () => {
    await assertFails(setDoc(doc(db(null), 'users', 'new'), profile('new', 'student')));
  });
});

describe('CT04: nobody promotes themselves', () => {
  test('a student cannot change their role to teacher', async () => {
    await assertFails(updateDoc(doc(db('student'), 'users', 'student'), { role: 'teacher' }));
  });

  test('a pending teacher cannot approve themselves', async () => {
    await assertFails(updateDoc(doc(db('pending'), 'users', 'pending'), { role: 'teacher' }));
  });

  test('a student can still update their name and username', async () => {
    await assertSucceeds(
      updateDoc(doc(db('student'), 'users', 'student'), { name: 'Novo Nome', username: 'novo_nome' }),
    );
  });
});

describe('AC3: teacher-only data', () => {
  for (const collection of ['questions', 'texts', 'classes']) {
    test(`a student cannot write to ${collection}`, async () => {
      await assertFails(setDoc(doc(db('student'), collection, 'x'), question));
    });

    test(`a pending teacher cannot write to ${collection}`, async () => {
      await assertFails(setDoc(doc(db('pending'), collection, 'x'), question));
    });

    test(`an approved teacher can write to ${collection}`, async () => {
      await assertSucceeds(setDoc(doc(db('teacher'), collection, 'x'), question));
    });
  }

  test('a teacher can read a student profile', async () => {
    await assertSucceeds(getDoc(doc(db('teacher'), 'users', 'student')));
  });

  test('a pending teacher cannot read another user profile', async () => {
    await assertFails(getDoc(doc(db('pending'), 'users', 'student')));
  });

  test('a student cannot read another user profile', async () => {
    await assertFails(getDoc(doc(db('student'), 'users', 'teacher')));
  });
});
