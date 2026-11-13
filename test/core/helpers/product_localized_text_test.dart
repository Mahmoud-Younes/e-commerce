import 'package:e_commerce_app/core/helpers/product_localized_text.dart';
import 'package:e_commerce_app/core/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isArabicLocale', () {
    test('true for `ar` (any region/script qualifier)', () {
      expect(isArabicLocale(const Locale('ar')), isTrue);
      expect(isArabicLocale(const Locale('ar', 'EG')), isTrue);
      expect(isArabicLocale(const Locale.fromSubtags(
        languageCode: 'ar',
        scriptCode: 'Arab',
      )), isTrue);
    });

    test('false for non-Arabic locales', () {
      expect(isArabicLocale(const Locale('en')), isFalse);
      expect(isArabicLocale(const Locale('en', 'US')), isFalse);
      expect(isArabicLocale(const Locale('fr')), isFalse);
    });
  });

  group('resolveProductText (frozen bilingual contract)', () {
    const english = 'Espresso Machine';
    const arabic = 'آلة إسبريسو';

    test('Arabic locale + non-empty Arabic text → Arabic', () {
      expect(resolveProductText(english, arabic, true), arabic);
    });

    test('Arabic locale + Arabic text with surrounding whitespace → Arabic '
        '(trimmed)', () {
      expect(resolveProductText(english, '  $arabic  ', true), arabic);
    });

    test('Arabic locale + empty Arabic text → English', () {
      expect(resolveProductText(english, '', true), english);
    });

    test('Arabic locale + whitespace-only Arabic text → English', () {
      expect(resolveProductText(english, '   ', true), english);
    });

    test('Arabic locale + null Arabic text → English', () {
      expect(resolveProductText(english, null, true), english);
    });

    test('English locale + Arabic text present → English', () {
      expect(resolveProductText(english, arabic, false), english);
    });

    test('English locale + null Arabic text → English', () {
      expect(resolveProductText(english, null, false), english);
    });
  });

  group('kCategoryArLabels (canonical category → Arabic label map)', () {
    test('contains exactly the six canonical categories', () {
      expect(kCategoryArLabels.keys.toSet(),
          {'electronics', 'fashion', 'home', 'beauty', 'sports', 'groceries'});
    });

    test('canonical Arabic labels', () {
      expect(kCategoryArLabels['electronics'], 'إلكترونيات');
      expect(kCategoryArLabels['fashion'], 'أزياء');
      expect(kCategoryArLabels['home'], 'منزل ومطبخ');
      expect(kCategoryArLabels['beauty'], 'جمال وعناية');
      expect(kCategoryArLabels['sports'], 'رياضة');
      expect(kCategoryArLabels['groceries'], 'بقالة');
    });
  });

  group('categoryArLabel', () {
    test('looks up case-insensitively and trims the key', () {
      expect(categoryArLabel('Electronics'), 'إلكترونيات');
      expect(categoryArLabel(' FASHION '), 'أزياء');
    });

    test('returns null for an unknown (foreign/legacy) category', () {
      expect(categoryArLabel('kitchen'), isNull);
      expect(categoryArLabel(''), isNull);
    });
  });

  group('resolveCategoryLabel (chip labels)', () {
    test('Arabic locale → the map label', () {
      expect(resolveCategoryLabel('electronics', true), 'إلكترونيات');
    });

    test('English locale → the raw category key', () {
      expect(resolveCategoryLabel('electronics', false), 'electronics');
    });

    test('Arabic locale + unknown category → falls back to the key', () {
      expect(resolveCategoryLabel('kitchen', true), 'kitchen');
    });
  });

  group('resolveCategoryDisplay (product category badge)', () {
    test('Arabic locale + non-empty product categoryAr → the product value',
        () {
      expect(
        resolveCategoryDisplay('electronics', 'إلكترونيات منتج', true),
        'إلكترونيات منتج',
      );
    });

    test('Arabic locale + null/empty categoryAr → the canonical map label',
        () {
      expect(resolveCategoryDisplay('electronics', null, true), 'إلكترونيات');
      expect(resolveCategoryDisplay('electronics', '  ', true), 'إلكترونيات');
    });

    test('Arabic locale + no map entry → the English key', () {
      expect(resolveCategoryDisplay('kitchen', null, true), 'kitchen');
    });

    test('English locale → the raw key regardless of categoryAr', () {
      expect(resolveCategoryDisplay('electronics', 'إلكترونيات', false),
          'electronics');
    });
  });

  group('ProductAdminDisplayX.adminDisplayName (locale-independent)', () {
    test('shows `name · nameAr` whenever nameAr exists', () {
      const product = ProductModel(name: 'Espresso Machine', nameAr: 'آلة');
      expect(product.adminDisplayName, 'Espresso Machine · آلة');
    });

    test('whitespace-only nameAr is treated as absent', () {
      const product = ProductModel(name: 'Espresso Machine', nameAr: '  ');
      expect(product.adminDisplayName, 'Espresso Machine');
    });

    test('falls back to the English name alone', () {
      const product = ProductModel(name: 'Espresso Machine');
      expect(product.adminDisplayName, 'Espresso Machine');
    });
  });

  group('contextIsArabic / productTextFor (BuildContext conveniences)', () {
    testWidgets('Arabic locale + Arabic present → Arabic', (tester) async {
      late String resolved;
      late bool arabic;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              resolved = productTextFor(
                context,
                'Espresso Machine',
                'آلة إسبريسو',
              );
              arabic = contextIsArabic(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(resolved, 'آلة إسبريسو');
      expect(arabic, isTrue);
    });

    testWidgets('English locale + Arabic present → English', (tester) async {
      late String resolved;
      late bool arabic;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resolved = productTextFor(
                context,
                'Espresso Machine',
                'آلة إسبريسو',
              );
              arabic = contextIsArabic(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(resolved, 'Espresso Machine');
      expect(arabic, isFalse);
    });

    testWidgets('Arabic locale + empty Arabic → English', (tester) async {
      late String resolved;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              resolved = productTextFor(context, 'Espresso Machine', '  ');
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(resolved, 'Espresso Machine');
    });

    testWidgets('categoryLabelFor resolves chip labels via the context',
        (tester) async {
      String? englishResult;
      String? arabicResult;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              englishResult = categoryLabelFor(context, 'electronics');
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              arabicResult = categoryLabelFor(context, 'electronics');
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      // First pump: default (English) locale.
      expect(englishResult, 'electronics');
      // Second pump: Arabic locale.
      expect(arabicResult, 'إلكترونيات');
    });
  });
}
