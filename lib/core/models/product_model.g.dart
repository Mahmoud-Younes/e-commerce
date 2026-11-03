// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
  name: json['name'] as String? ?? '',
  description: json['description'] as String? ?? '',
  price: (json['price'] as num?)?.toDouble() ?? 0.0,
  imageUrl: json['imageUrl'] as String? ?? '',
  category: json['category'] as String? ?? '',
  stock: (json['stock'] as num?)?.toInt() ?? 0,
  isAvailable: json['isAvailable'] as bool? ?? true,
);

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'imageUrl': instance.imageUrl,
      'category': instance.category,
      'stock': instance.stock,
      'isAvailable': instance.isAvailable,
    };
