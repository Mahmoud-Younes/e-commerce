// Main-flow integration test (PRD stage 7 deliverable; drives PRD §1-§4):
//
//   register (unique random email) → login → browse catalog → add product to
//   cart → place a Cash-on-Delivery order → order appears in My Orders.
//
// Failure classification contract (task rules):
//  - Real environmental failures (no network, Email/Password provider disabled
//    or restricted on the sahety-ba784 Firebase project, unauthorized web
//    domain, rejected API key, throttling, Firestore rules/service unavailability)
//    → `markTestSkipped('SKIP: <reason>')`: the run ends successfully with the
//    reason printed and stored in the binding report data.
//  - Everything else — including app-logic gaps (stub screens, missing route or
//    DI wiring) — is a genuine test failure and must stay red.
//
// The app under test connects to the real Firebase project `sahety-ba784`
// (lib/firebase_options.dart); every account created here is disposable
// (`it_<timestamp>_<random>@shop.test`).

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:e_commerce_app/features/products/ui/widgets/product_card.dart';
import 'package:e_commerce_app/main.dart' as app;

/// Password meeting Firebase's minimum (6+ chars) with no further rules.
const String _password = 'Passw0rd!123';

final Random _random = Random();

/// Substrings (lower-cased) that identify an infrastructure/environment
/// failure rather than an app-logic failure. Messages come from the app's
/// error dialogs, which surface `ApiErrorHandler` output — Firebase codes and
/// raw SDK messages both land there.
const List<String> _environmentalPatterns = <String>[
  // Network / connectivity.
  'network',
  'socketexception',
  'failed host lookup',
  'connection refused',
  'connection reset',
  'xmlhttprequest',
  'cors',
  // Firebase Auth: Email/Password disabled or project/API-key problems.
  'operation-not-allowed',
  'sign-in provider is disabled',
  'provider is disabled',
  'admin-restricted-operation',
  'unauthorized-domain',
  'unauthorized domain',
  'invalid-api-key',
  'api-key-not-valid',
  'invalid api key',
  'api key not valid',
  'configuration-not-found',
  'internal-error',
  // Throttling and service-side availability.
  'too many',
  'quota',
  'resource-exhausted',
  'unavailable',
  'deadline-exceeded',
  // Firestore access/infra (rules or service), surfaced through the dialogs.
  'permission',
  'cloud_firestore',
  'unauthenticated',
];

bool _isEnvironmental(String message) {
  final String lower = message.toLowerCase();
  return _environmentalPatterns.any(lower.contains);
}

/// Pumps frames and polls until [finder] matches, or the deadline passes.
Future<bool> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final DateTime deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) {
      return true;
    }
  }
  await tester.pump();
  return finder.evaluate().isNotEmpty;
}

/// Outcome of waiting for a screen swap: either [successFinder] matched, the
/// app surfaced its standard error dialog ([errorMessage] set), or it timed
/// out ([timedOut]).
class _Transition {
  const _Transition.success() : errorMessage = null, timedOut = false;
  const _Transition.error(this.errorMessage) : timedOut = false;
  const _Transition.timeout() : errorMessage = null, timedOut = true;

  final String? errorMessage;
  final bool timedOut;
}

/// Waits until [successFinder] matches or an [AlertDialog] (the app's error
/// surface) appears, whichever comes first.
Future<_Transition> _waitForTransition(
  WidgetTester tester,
  Finder successFinder, {
  Duration timeout = const Duration(seconds: 60),
}) async {
  final DateTime deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (successFinder.evaluate().isNotEmpty) {
      return const _Transition.success();
    }
    final Iterable<Element> dialogs =
        find.byType(AlertDialog).evaluate();
    if (dialogs.isNotEmpty) {
      return _Transition.error(_dialogMessage(tester));
    }
  }
  return const _Transition.timeout();
}

/// Reads the message text out of the app's standard error dialog
/// (AlertDialog: icon + content Text + 'Got it' action).
String _dialogMessage(WidgetTester tester) {
  final Iterable<Element> texts =
      find.descendant(of: find.byType(AlertDialog), matching: find.byType(Text))
          .evaluate();
  final String message = texts
      .map((Element e) => (e.widget as Text).data ?? '')
      .where((String t) => t.trim().isNotEmpty && t.trim() != 'Got it')
      .join(' | ');
  return message.isEmpty ? '(error dialog without message text)' : message;
}

/// Ends the test as SKIP when [message] is an environmental failure,
/// otherwise fails it. Callers must `return` right after this helper.
Future<void> _skipOrFail(
  IntegrationTestWidgetsFlutterBinding binding,
  String phase,
  String message,
) async {
  if (_isEnvironmental(message)) {
    debugPrint('SKIP: $phase — environmental failure: $message');
    binding.reportData ??= <String, dynamic>{};
    binding.reportData!['skip'] = 'SKIP: $phase — environmental failure: $message';
    markTestSkipped('SKIP: $phase — environmental failure: $message');
    return;
  }
  fail('$phase failed: $message');
}

/// Locates a form field by its hint. The app's `AppTextFormField` builds a
/// [TextFormField] wrapping a [TextField] that carries the InputDecoration.
Finder _fieldByHint(String hint) => find.byWidgetPredicate(
      (Widget w) => w is TextField && w.decoration?.hintText == hint,
    );

Future<void> _fillField(WidgetTester tester, String hint, String value) async {
  final Finder field = _fieldByHint(hint);
  if (!_pumpUntilSync(tester, field)) {
    fail('Expected a form field with hint "$hint" on the current screen.');
  }
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pump();
}

/// Synchronous presence probe (fields render with the screen; one pump suffices).
bool _pumpUntilSync(WidgetTester tester, Finder finder) {
  for (int i = 0; i < 4; i++) {
    if (finder.evaluate().isNotEmpty) {
      return true;
    }
    tester.pump(const Duration(milliseconds: 150));
  }
  return finder.evaluate().isNotEmpty;
}

/// Taps the trailing ' Sign Up' span inside the login screen's RichText link.
/// Samples points across the line and taps the first one the paragraph maps
/// back into the 'Sign Up' span (the span sits at the end of the text).
Future<void> _tapSignUpLink(WidgetTester tester) async {
  final Finder link = find.byWidgetPredicate(
    (Widget w) => w is RichText && w.text.toPlainText().contains('Sign Up'),
  );
  if (link.evaluate().isEmpty) {
    fail("Login screen: the 'Don't have an account? Sign Up' link was not found.");
  }
  final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(link);
  final String plain = paragraph.text.toPlainText();
  final int start = plain.indexOf('Sign Up');
  final Rect rect = tester.getRect(link);
  final Offset topLeft = paragraph.localToGlobal(Offset.zero);
  for (final double fraction in const <double>[
    0.9, 0.95, 0.85, 0.8, 0.75, 0.7, 0.65, 0.6, 0.55, 0.5,
  ]) {
    final Offset global = Offset(rect.left + rect.width * fraction, rect.center.dy);
    final TextPosition pos =
        paragraph.getPositionForOffset(global - topLeft);
    if (pos.offset >= start && pos.offset < start + 'Sign Up'.length) {
      await tester.tapAt(global);
      await tester.pump();
      return;
    }
  }
  fail("Could not locate the tappable 'Sign Up' span on the login screen.");
}

Future<void> _tapTextButton(
  WidgetTester tester,
  String label, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final Finder button = find.widgetWithText(TextButton, label);
  if (!(await _pumpUntil(tester, button, timeout: timeout))) {
    fail('Expected a "$label" button on the current screen.');
  }
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button, warnIfMissed: false);
  await tester.pump();
}

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'main flow: register → login → catalog → add to cart → COD order → My Orders',
    (WidgetTester tester) async {
      binding.reportData ??= <String, dynamic>{};

      // ---------------- Phase 0: boot ----------------
      debugPrint('main-flow: phase 0 — boot');
      app.main();

      // AuthGate spins until authStateChanges connects, then shows either the
      // login screen or — on a persisted session in this browser profile — the
      // customer home screen.
      final bool onLogin =
          await _pumpUntil(tester, find.text('Welcome Back'), timeout: const Duration(seconds: 45));
      if (!onLogin) {
        final bool onHome =
            await _pumpUntil(tester, find.text('Home'), timeout: const Duration(seconds: 15));
        if (!onHome) {
          fail('App boot: neither the login screen ("Welcome Back") nor the '
              'home screen ("Home") appeared within 60s.');
        }
        // Sign the stale session out through the SDK; AuthGate swaps back.
        await FirebaseAuth.instance.signOut();
        final bool backToLogin = await _pumpUntil(
          tester,
          find.text('Welcome Back'),
          timeout: const Duration(seconds: 30),
        );
        if (!backToLogin) {
          fail('App boot: sign-out of a persisted session did not return to '
              'the login screen within 30s.');
        }
      }

      // ---------------- Phase 1: register (unique random email) ----------------
      debugPrint('main-flow: phase 1 — register');
      final String email =
          'it_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(100000)}@shop.test';
      await _tapSignUpLink(tester);

      if (!(await _pumpUntil(
        tester,
        find.text('Create Account'),
        timeout: const Duration(seconds: 20),
      ))) {
        fail('Register screen ("Create Account") did not open after tapping Sign Up.');
      }

      await _fillField(tester, 'Name', 'Integration Tester');
      await _fillField(tester, 'Email', email);
      await _fillField(tester, 'Password', _password);
      await _fillField(tester, 'Confirm Password', _password);

      await _tapTextButton(tester, 'Create Account');
      final _Transition registerOutcome = await _waitForTransition(
        tester,
        find.text('Home'),
        timeout: const Duration(seconds: 90),
      );
      if (registerOutcome.timedOut) {
        fail('Register: neither the home screen nor an error dialog appeared '
            'within 90s (email: $email).');
      }
      if (registerOutcome.errorMessage != null) {
        await _skipOrFail(binding, 'register', registerOutcome.errorMessage!);
        return;
      }

      // ---------------- Phase 2: logout, then login again ----------------
      debugPrint('main-flow: phase 2 — logout + login');
      final Finder profileIcon = find.byTooltip('Profile');
      if (profileIcon.evaluate().isEmpty) {
        fail("Home screen: the 'Profile' icon button (tooltip 'Profile') is "
            'missing; no path to logout.');
      }
      await tester.tap(profileIcon, warnIfMissed: false);
      await tester.pump();

      final _Transition profileOutcome = await _waitForTransition(
        tester,
        find.widgetWithText(TextButton, 'Logout'),
        timeout: const Duration(seconds: 30),
      );
      if (profileOutcome.timedOut) {
        fail("Profile screen did not show the 'Logout' button within 30s.");
      }
      if (profileOutcome.errorMessage != null) {
        await _skipOrFail(binding, 'profile load', profileOutcome.errorMessage!);
        return;
      }
      await _tapTextButton(tester, 'Logout');

      if (!(await _pumpUntil(
        tester,
        find.text('Welcome Back'),
        timeout: const Duration(seconds: 45),
      ))) {
        fail('Logout did not return to the login screen ("Welcome Back") within 45s.');
      }

      await _fillField(tester, 'Email', email);
      await _fillField(tester, 'Password', _password);
      await _tapTextButton(tester, 'Login');
      final _Transition loginOutcome = await _waitForTransition(
        tester,
        find.text('Home'),
        timeout: const Duration(seconds: 60),
      );
      if (loginOutcome.timedOut) {
        fail('Login: neither the home screen nor an error dialog appeared within 60s.');
      }
      if (loginOutcome.errorMessage != null) {
        await _skipOrFail(binding, 'login', loginOutcome.errorMessage!);
        return;
      }

      // ---------------- Phase 3: browse the catalog ----------------
      debugPrint('main-flow: phase 3 — browse catalog');
      final bool homeIsStub =
          await _pumpUntil(tester, find.text('Home — coming next'), timeout: const Duration(seconds: 5));
      final bool hasCatalogUi = await _pumpUntil(
        tester,
        find.byWidgetPredicate(
          (Widget w) =>
              w is ProductCard || w is GridView || w is ListView,
        ),
        timeout: const Duration(seconds: 10),
      );
      if (homeIsStub || !hasCatalogUi) {
        // Logical gap in the app under test, not an environmental failure:
        // at the time of authoring, /homeScreen, /productsScreen and
        // /productDetailsScreen are routed to the features/catalog placeholder
        // screens and no screen pushes the implemented products feature.
        fail(
          'Browse catalog: the customer home screen offers no catalog. '
          'The home screen is the stage-1 stub ("Home — coming next", '
          'lib/features/catalog/ui/screens/home_screen.dart:24) with no entry '
          'point to products; app_router.dart:69-79 routes /homeScreen, '
          '/productsScreen and /productDetailsScreen to the features/catalog '
          'stubs, and the implemented products feature '
          '(lib/features/products/ui/screens/products_screen.dart, with the '
          'Add to Cart flow on its details screen) is not reachable from any '
          'screen. The main flow cannot proceed past login.',
        );
      }

      // --------------- Phase 4: product details → Add to Cart ---------------
      debugPrint('main-flow: phase 4 — add to cart');
      final Finder productCard = find.byWidgetPredicate((Widget w) => w is Card).first;
      if (!(await _pumpUntil(tester, productCard, timeout: const Duration(seconds: 30)))) {
        fail('Catalog is displayed but contains no product cards within 30s.');
      }
      await tester.tap(productCard, warnIfMissed: false);
      await tester.pump();
      if (!(await _pumpUntil(
        tester,
        find.widgetWithText(TextButton, 'Add to Cart'),
        timeout: const Duration(seconds: 30),
      ))) {
        fail("Product details screen did not show the 'Add to Cart' button within 30s.");
      }
      await _tapTextButton(tester, 'Add to Cart');
      if (!(await _pumpUntil(
        tester,
        find.text('Added to cart'),
        timeout: const Duration(seconds: 15),
      ))) {
        fail("Add to cart: the 'Added to cart' confirmation did not appear within 15s.");
      }

      // --------------- Phase 5: cart → checkout (Cash on Delivery) ---------------
      debugPrint('main-flow: phase 5 — checkout');
      final Finder cartEntry = _findCartEntry();
      if (cartEntry.evaluate().isEmpty) {
        fail(
          'No cart entry point found on the current screen: no UI anywhere in '
          'the app pushes Routes.cartScreen, so the cart screen '
          '(lib/features/cart/ui/screens/cart_screen.dart) is unreachable and '
          'the order flow cannot continue.',
        );
      }
      await tester.tap(cartEntry, warnIfMissed: false);
      await tester.pump();
      if (!(await _pumpUntil(
        tester,
        find.byKey(const Key('cartCheckoutButton')),
        timeout: const Duration(seconds: 30),
      ))) {
        fail("Cart screen did not show the 'Checkout' button "
            "(Key('cartCheckoutButton')) within 30s.");
      }
      await _tapTextButtonByKey(tester, const Key('cartCheckoutButton'));

      await _fillField(tester, 'Delivery address', '12 Tahrir Square, Cairo');
      await _fillField(tester, 'Phone number', '+201000000000');
      await _tapTextButton(tester, 'Place Order (Cash on Delivery)');

      final _Transition orderOutcome = await _waitForTransition(
        tester,
        find.text('Order placed successfully!'),
        timeout: const Duration(seconds: 60),
      );
      if (orderOutcome.timedOut) {
        fail('Place order: neither the order-success screen nor an error '
            'dialog appeared within 60s.');
      }
      if (orderOutcome.errorMessage != null) {
        await _skipOrFail(binding, 'place order', orderOutcome.errorMessage!);
        return;
      }

      // --------------- Phase 6: the order appears in My Orders ---------------
      debugPrint('main-flow: phase 6 — My Orders');
      final Finder trackButton = find.text('Track it in My Orders');
      if (!(await _pumpUntil(tester, trackButton, timeout: const Duration(seconds: 10)))) {
        fail("Order-success screen did not offer the 'Track it in My Orders' action.");
      }
      await tester.tap(trackButton, warnIfMissed: false);
      await tester.pump();

      final bool ordersListed = await _pumpUntil(
        tester,
        find.byWidgetPredicate((Widget w) => w is Card),
        timeout: const Duration(seconds: 30),
      );
      final bool emptyState =
          find.text('No orders yet.').evaluate().isNotEmpty;
      if (!ordersListed || emptyState) {
        fail('My Orders screen shows "No orders yet." (or no order rows) '
            'after the order was placed successfully — the created order is '
            'not visible in My Orders.');
      }
      debugPrint('main-flow: completed — order visible in My Orders.');
    },
  );
}

/// Looks for a cart entry point on the current screen: a tooltip-labelled
/// 'Cart' action or a shopping-cart icon button.
Finder _findCartEntry() {
  final Finder byTooltip = find.byTooltip('Cart');
  if (byTooltip.evaluate().isNotEmpty) {
    return byTooltip;
  }
  const List<IconData> cartIcons = <IconData>[
    Icons.shopping_cart,
    Icons.shopping_cart_outlined,
    Icons.shopping_cart_rounded,
    Icons.shopping_cart_sharp,
  ];
  return find.byWidgetPredicate(
    (Widget w) =>
        w is IconButton &&
        w.icon is Icon &&
        cartIcons.contains((w.icon as Icon).icon),
  );
}

Future<void> _tapTextButtonByKey(WidgetTester tester, Key key) async {
  final Finder button = find.byKey(key);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button, warnIfMissed: false);
  await tester.pump();
}
