import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/core/networking/api_result.dart';
import 'package:e_commerce_app/features/favorites/data/repos/favorites_repository_impl.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  group('FavoritesRepositoryImpl (fake_cloud_firestore, PRD §7)', () {
    late FakeFirebaseFirestore firestore;
    late FavoritesRepositoryImpl repo;
    const uid = 'user-1';

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repo = FavoritesRepositoryImpl(firestore: firestore);
    });

    group('streamFavoriteIds', () {
      test('emits the favorite doc IDs as product IDs, live', () async {
        await firestore
            .collection('users/$uid/favorites')
            .doc('p1')
            .set({'productId': 'p1'});
        await firestore
            .collection('users/$uid/favorites')
            .doc('p2')
            .set({'productId': 'p2'});

        final first = await repo.streamFavoriteIds(uid).first;

        // Doc order from the fake is by document ID.
        expect(first, containsAllInOrder(<Matcher>[equals('p1'), equals('p2')]));
      });

      test('emits an empty list when the user has no favorites', () async {
        expect(await repo.streamFavoriteIds(uid).first, isEmpty);
      });

      test('reflects new favorites without re-subscribing (live stream)',
          () async {
        final emitted = <List<String>>[];
        final sub = repo.streamFavoriteIds(uid).listen(emitted.add);

        await firestore
            .collection('users/$uid/favorites')
            .doc('p9')
            .set({'productId': 'p9'});
        await Future<void>.delayed(Duration.zero);

        expect(emitted.last, ['p9']);
        await sub.cancel();
      });
    });

    group('toggle', () {
      test('adds a favorite doc (product ID is the doc ID, stores productId)',
          () async {
        final result = await repo.toggle(uid, 'p1');

        expect(result, isA<Success<void>>());
        final doc =
            await firestore.collection('users/$uid/favorites').doc('p1').get();
        expect(doc.exists, isTrue);
        expect(doc.data()?['productId'], 'p1');
      });

      test('removes the favorite doc when it already exists', () async {
        await repo.toggle(uid, 'p1');

        final result = await repo.toggle(uid, 'p1');

        expect(result, isA<Success<void>>());
        final doc =
            await firestore.collection('users/$uid/favorites').doc('p1').get();
        expect(doc.exists, isFalse);
      });

      test('only touches the target user\'s subcollection', () async {
        await repo.toggle(uid, 'p1');
        // user-2 toggles twice: add then remove — must not touch user-1's doc.
        await repo.toggle('user-2', 'p1');
        await repo.toggle('user-2', 'p1');

        final user1 = await firestore
            .collection('users/$uid/favorites')
            .doc('p1')
            .get();
        final user2 = await firestore
            .collection('users/user-2/favorites')
            .doc('p1')
            .get();

        expect(user1.exists, isTrue);
        expect(user2.exists, isFalse);
      });

      test('maps thrown errors to ApiResult.failure (never rethrows)',
          () async {
        final throwing = _MockFirebaseFirestore();
        when(() => throwing.doc(any())).thenThrow(Exception('boom'));
        final failingRepo = FavoritesRepositoryImpl(firestore: throwing);

        final result = await failingRepo.toggle(uid, 'p1');

        expect(result, isA<Failure<void>>());
        expect((result as Failure<void>).apiErrorModel.message, isNotNull);
      });
    });
  });
}



