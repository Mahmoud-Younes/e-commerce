import 'package:json_annotation/json_annotation.dart';

part 'cart_item_model.g.dart';

/// One cart line (PRD §3, §7). Stored at `users/{uid}/cart/{productId}` — the
/// productId is the document ID. Also embedded inside `OrderModel.items` so
/// historical orders keep the product name and price at purchase time
/// (PRD §4: "Store the product name and price at the time of purchase").
@JsonSerializable()
class CartItemModel {
  @JsonKey(defaultValue: '')
  final String productId;
  final String name;

  @JsonKey(defaultValue: 0.0)
  final double price;

  @JsonKey(defaultValue: 1)
  final int quantity;

  const CartItemModel({
    required this.productId,
    this.name = '',
    this.price = 0.0,
    this.quantity = 1,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemModelToJson(this);

  double get subtotal => price * quantity;

  CartItemModel copyWith({
    String? productId,
    String? name,
    double? price,
    int? quantity,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}
