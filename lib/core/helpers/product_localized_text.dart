import 'package:flutter/widgets.dart';

import '../models/product_model.dart';

/// Canonical English category keys → Arabic labels (frozen bilingual
/// contract): `products/{id}.category` is the lowercase English key and
/// `categoryAr` is its Arabic label. The seed script writes both in this
/// shape; the admin form derives `categoryAr` from this map at save time
/// (there is no free-text Arabic category input).
const Map<String, String> kCategoryArLabels = {
  'electronics': 'إلكترونيات',
  'fashion': 'أزياء',
  'home': 'منزل ومطبخ',
  'beauty': 'جمال وعناية',
  'sports': 'رياضة',
  'groceries': 'بقالة',
};

/// Pure locale check (testable without widgets): the app is bilingual
/// Arabic/English and switches on the language code only.
bool isArabicLocale(Locale locale) => locale.languageCode == 'ar';

/// Whether the given [context] is running under an Arabic locale.
bool contextIsArabic(BuildContext context) =>
    isArabicLocale(Localizations.localeOf(context));

/// Returns [text] when it is non-empty after trimming, else `null`.
String? _trimmedNonEmpty(String? text) {
  if (text == null) return null;
  final trimmed = text.trim();
  return trimmed.isEmpty ? null : trimmed;
}

/// Resolves a product's display text (frozen bilingual contract): the Arabic
/// variant when the locale is Arabic AND the Arabic text is non-empty after
/// trimming, otherwise the English text.
///
/// Pure function — testable without widgets; [productTextFor] is the
/// BuildContext convenience that derives `isArabic` from
/// `Localizations.localeOf(context)`.
String resolveProductText(
  String englishText,
  String? arabicText,
  bool isArabic,
) {
  if (isArabic) {
    final arabic = _trimmedNonEmpty(arabicText);
    if (arabic != null) return arabic;
  }
  return englishText;
}

/// [BuildContext] convenience for [resolveProductText]: resolves the display
/// text via the ambient `Localizations.localeOf`.
String productTextFor(
  BuildContext context,
  String englishText,
  String? arabicText,
) =>
    resolveProductText(englishText, arabicText, contextIsArabic(context));

/// The Arabic label for a canonical category key, case-insensitively looked
/// up in [kCategoryArLabels]; `null` when the key has no entry (a foreign or
/// legacy category keeps the English key as its label).
String? categoryArLabel(String category) =>
    kCategoryArLabels[category.trim().toLowerCase()];

/// Resolves a canonical category key to its chip/display label: the Arabic
/// label from [kCategoryArLabels] when [isArabic], falling back to the
/// category key itself when the key has no Arabic entry.
String resolveCategoryLabel(String category, bool isArabic) {
  if (!isArabic) return category;
  return categoryArLabel(category) ?? category;
}

/// [BuildContext] convenience for [resolveCategoryLabel].
String categoryLabelFor(BuildContext context, String category) =>
    resolveCategoryLabel(category, contextIsArabic(context));

/// Resolves a single product's category for display: the product's own
/// `categoryAr` when the locale is Arabic and it is non-empty, else the
/// canonical [kCategoryArLabels] label for the category key, else the raw
/// (English) category key.
String resolveCategoryDisplay(
  String category,
  String? categoryAr,
  bool isArabic,
) {
  if (!isArabic) return category;
  return _trimmedNonEmpty(categoryAr) ?? categoryArLabel(category) ?? category;
}

/// [BuildContext] convenience for [resolveCategoryDisplay].
String categoryDisplayFor(
  BuildContext context,
  String category,
  String? categoryAr,
) =>
    resolveCategoryDisplay(category, categoryAr, contextIsArabic(context));

/// Admin-facing product display name — locale-INDEPENDENT: shows
/// `name · nameAr` whenever `nameAr` is non-empty so the admin always sees
/// both language variants while managing the catalog.
extension ProductAdminDisplayX on ProductModel {
  String get adminDisplayName {
    final arabic = _trimmedNonEmpty(nameAr);
    return arabic == null ? name : '$name · $arabic';
  }
}
