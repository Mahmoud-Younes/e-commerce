// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
  name: json['name'] as String? ?? '',
  nameAr: json['nameAr'] as String?,
  description: json['description'] as String? ?? '',
  descriptionAr: json['descriptionAr'] as String?,
  price: (json['price'] as num?)?.toDouble() ?? 0.0,
  imageUrl: json['imageUrl'] as String? ?? '',
  category: json['category'] as String? ?? '',
  categoryAr: json['categoryAr'] as String?,
  stock: (json['stock'] as num?)?.toInt() ?? 0,
  isAvailable: json['isAvailable'] as bool? ?? true,
);

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'nameAr': instance.nameAr,
      'description': instance.description,
      'descriptionAr': instance.descriptionAr,
      'price': instance.price,
      'imageUrl': instance.imageUrl,
      'category': instance.category,
      'categoryAr': instance.categoryAr,
      'stock': instance.stock,
      'isAvailable': instance.isAvailable,
    };
