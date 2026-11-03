import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:e_commerce_app/core/helpers/constants.dart';
import 'package:e_commerce_app/core/networking/api_result.dart';
import 'package:e_commerce_app/features/admin/data/repos/admin_role_guard.dart';

/// PRD §5: "Protect Admin actions using trusted authorization" — the guard
/// reads `role` from the `users/{uid}` doc before ANY admin write. Firestore
/// Security Rules re-check server-side in a later stage (PRD §8 stage 7).
void main() {
  late FakeFirebaseFirestore firestore;

  AdminRoleGuard buildGuard(MockFirebaseAuth auth) =>
      FirebaseAdminRoleGuard(auth, firestore);

  Future<void> seedUser(String uid, String role) async {
    await firestore.collection(Collections.users).doc(uid).set({
      UserFields.role: role,
    });
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  group('FirebaseAdminRoleGuard.ensureAdmin', () {
    test('succeeds for a signed-in user whose doc has role == admin', () async {
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'admin-1'),
      );
      await seedUser('admin-1', UserRoleValues.admin);

      final result = await buildGuard(auth).ensureAdmin();

      expect(result, isA<Success<void>>());
    });

    test('FAILS for a signed-in user whose role is customer — the write '
        'must not proceed', () async {
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'customer-1'),
      );
      await seedUser('customer-1', 'customer');

      final result = await buildGuard(auth).ensureAdmin();

      expect(result, isA<Failure<void>>());
      final message = (result as Failure<void>).apiErrorModel.message ?? '';
      expect(message, contains('Only admins'));
    });

    test('FAILS when the user doc has NO role field', () async {
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'no-role-1'),
      );
      await firestore.collection(Collections.users).doc('no-role-1').set({
        UserFields.name: 'No Role',
      });

      final result = await buildGuard(auth).ensureAdmin();

      expect(result, isA<Failure<void>>());
    });

    test('FAILS when the user doc is missing entirely', () async {
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'ghost-1'),
      );

      final result = await buildGuard(auth).ensureAdmin();

      expect(result, isA<Failure<void>>());
    });

    test('FAILS when nobody is signed in', () async {
      final auth = MockFirebaseAuth(signedIn: false);

      final result = await buildGuard(auth).ensureAdmin();

      expect(result, isA<Failure<void>>());
      final message = (result as Failure<void>).apiErrorModel.message ?? '';
      expect(message, contains('signed in'));
    });
  });
}



