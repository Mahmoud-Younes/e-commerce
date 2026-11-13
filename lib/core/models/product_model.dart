import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

/// Firestore `products/{productId}` document (PRD §2, §7). The product ID is
/// the Firestore document ID (same pattern as [UserModel] where the uid is
/// the doc ID) — read it via `doc.id`, not from the payload.
@JsonSerializable()
class ProductModel {
  @JsonKey(defaultValue: '')
  final String name;

  /// Optional Arabic display name (bilingual contract). `null` when the
  /// admin did not enter an Arabic variant — resolution goes through
  /// `core/helpers/product_localized_text.dart`.
  final String? nameAr;

  @JsonKey(defaultValue: '')
  final String description;

  /// Optional Arabic display description (bilingual contract).
  final String? descriptionAr;

  @JsonKey(defaultValue: 0.0)
  final double price;

  @JsonKey(defaultValue: '')
  final String imageUrl;

  /// Canonical English category key, lowercase (e.g. `electronics`).
  @JsonKey(defaultValue: '')
  final String category;

  /// Arabic label of [category] (e.g. `إلكترونيات`), derived from the
  /// canonical category map at admin-save time — never a free-text input.
  final String? categoryAr;

  @JsonKey(defaultValue: 0)
  final int stock;

  @JsonKey(defaultValue: true)
  final bool isAvailable;

  const ProductModel({
    required this.name,
    this.nameAr,
    this.description = '',
    this.descriptionAr,
    this.price = 0.0,
    this.imageUrl = '',
    this.category = '',
    this.categoryAr,
    this.stock = 0,
    this.isAvailable = true,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  factory ProductModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      ProductModel.fromJson(doc.data() ?? <String, dynamic>{});

  bool get inStock => isAvailable && stock > 0;

  ProductModel copyWith({
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    double? price,
    String? imageUrl,
    String? category,
    String? categoryAr,
    int? stock,
    bool? isAvailable,
  }) {
    return ProductModel(
      name: name ?? this.name,
      // The Arabic fields are nullable-by-design: copyWith cannot clear them
      // (passing null keeps the current value) — build a fresh ProductModel
      // when an Arabic field must be set back to null.
      nameAr: nameAr ?? this.nameAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      categoryAr: categoryAr ?? this.categoryAr,
      stock: stock ?? this.stock,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
