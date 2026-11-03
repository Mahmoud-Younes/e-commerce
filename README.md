# E-Commerce App (Flutter + Firebase)

Flutter e-commerce app with Firebase Authentication, Cloud Firestore, and Firebase Cloud Messaging (FCM). Product images are stored in Supabase Storage.

## Features (v1)
- Customer: browse products, favorites, cart, checkout (cash on delivery), orders tracking.
- Admin: product CRUD, order review, status updates.
- Role-based routing after login (Customer vs Admin).

## Prerequisites
- Flutter SDK (stable) matching `pubspec.yaml` (`sdk: ^3.13.4`)
- Firebase project `sahety-ba784` (or your own) with Auth + Firestore enabled
- Supabase project with a public `product-images` bucket (optional, for admin image upload)

## Firebase setup
1. Create a Firebase project and enable **Email/Password** authentication.
2. Create a **Cloud Firestore** database.
3. Add an Android app with package name `com.example.e_commerce_app`.
4. Download `google-services.json` into `android/app/`.
5. Run `flutterfire configure` (or keep the committed `lib/firebase_options.dart`).
6. (Optional) Deploy `firestore.rules`.

## Supabase setup (product images)
1. Create a Supabase project and a public bucket `product-images`.
2. Update `lib/core/constants/supabase_constants.dart` (or the relevant config) with your URL and anon key.
3. Admin uploads use `image_picker` -> Supabase Storage -> Firestore `imageUrl`.

## Run
```bash
flutter pub get
flutter run
```

## Tests
```bash
flutter test
```

## E2E (Android)
Build and install the APK first, then:
```bash
npx e2e run
```
See `e2e.config.ts` and `tests/auth.e2e.ts`.

## Notes
- Admin role is stored in Firestore `users/{uid}.role`; regular users cannot grant themselves admin.
- Order totals and product prices are validated by Firestore Security Rules.
