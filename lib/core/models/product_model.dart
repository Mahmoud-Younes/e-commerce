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

  @JsonKey(defaultValue: '')
  final String description;

  @JsonKey(defaultValue: 0.0)
  final double price;

  @JsonKey(defaultValue: '')
  final String imageUrl;

  @JsonKey(defaultValue: '')
  final String category;

  @JsonKey(defaultValue: 0)
  final int stock;

  @JsonKey(defaultValue: true)
  final bool isAvailable;

  const ProductModel({
    required this.name,
    this.description = '',
    this.price = 0.0,
    this.imageUrl = '',
    this.category = '',
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
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    int? stock,
    bool? isAvailable,
  }) {
    return ProductModel(
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
