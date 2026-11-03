// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'products_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductsState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ProductsState()';
}


}

/// @nodoc
class $ProductsStateCopyWith<$Res>  {
$ProductsStateCopyWith(ProductsState _, $Res Function(ProductsState) __);
}


/// Adds pattern-matching-related methods to [ProductsState].
extension ProductsStatePatterns on ProductsState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ProductsInitial value)?  initial,TResult Function( ProductsLoading value)?  productsLoading,TResult Function( ProductsLoaded value)?  productsLoaded,TResult Function( ProductsEmpty value)?  productsEmpty,TResult Function( ProductsError value)?  productsError,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ProductsInitial() when initial != null:
return initial(_that);case ProductsLoading() when productsLoading != null:
return productsLoading(_that);case ProductsLoaded() when productsLoaded != null:
return productsLoaded(_that);case ProductsEmpty() when productsEmpty != null:
return productsEmpty(_that);case ProductsError() when productsError != null:
return productsError(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ProductsInitial value)  initial,required TResult Function( ProductsLoading value)  productsLoading,required TResult Function( ProductsLoaded value)  productsLoaded,required TResult Function( ProductsEmpty value)  productsEmpty,required TResult Function( ProductsError value)  productsError,}){
final _that = this;
switch (_that) {
case ProductsInitial():
return initial(_that);case ProductsLoading():
return productsLoading(_that);case ProductsLoaded():
return productsLoaded(_that);case ProductsEmpty():
return productsEmpty(_that);case ProductsError():
return productsError(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ProductsInitial value)?  initial,TResult? Function( ProductsLoading value)?  productsLoading,TResult? Function( ProductsLoaded value)?  productsLoaded,TResult? Function( ProductsEmpty value)?  productsEmpty,TResult? Function( ProductsError value)?  productsError,}){
final _that = this;
switch (_that) {
case ProductsInitial() when initial != null:
return initial(_that);case ProductsLoading() when productsLoading != null:
return productsLoading(_that);case ProductsLoaded() when productsLoaded != null:
return productsLoaded(_that);case ProductsEmpty() when productsEmpty != null:
return productsEmpty(_that);case ProductsError() when productsError != null:
return productsError(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  productsLoading,TResult Function( List<ProductDoc> products,  List<String> categories,  String? selectedCategory,  String searchQuery)?  productsLoaded,TResult Function( List<String> categories,  String? selectedCategory,  String searchQuery)?  productsEmpty,TResult Function( ApiErrorModel apiErrorModel)?  productsError,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ProductsInitial() when initial != null:
return initial();case ProductsLoading() when productsLoading != null:
return productsLoading();case ProductsLoaded() when productsLoaded != null:
return productsLoaded(_that.products,_that.categories,_that.selectedCategory,_that.searchQuery);case ProductsEmpty() when productsEmpty != null:
return productsEmpty(_that.categories,_that.selectedCategory,_that.searchQuery);case ProductsError() when productsError != null:
return productsError(_that.apiErrorModel);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  productsLoading,required TResult Function( List<ProductDoc> products,  List<String> categories,  String? selectedCategory,  String searchQuery)  productsLoaded,required TResult Function( List<String> categories,  String? selectedCategory,  String searchQuery)  productsEmpty,required TResult Function( ApiErrorModel apiErrorModel)  productsError,}) {final _that = this;
switch (_that) {
case ProductsInitial():
return initial();case ProductsLoading():
return productsLoading();case ProductsLoaded():
return productsLoaded(_that.products,_that.categories,_that.selectedCategory,_that.searchQuery);case ProductsEmpty():
return productsEmpty(_that.categories,_that.selectedCategory,_that.searchQuery);case ProductsError():
return productsError(_that.apiErrorModel);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  productsLoading,TResult? Function( List<ProductDoc> products,  List<String> categories,  String? selectedCategory,  String searchQuery)?  productsLoaded,TResult? Function( List<String> categories,  String? selectedCategory,  String searchQuery)?  productsEmpty,TResult? Function( ApiErrorModel apiErrorModel)?  productsError,}) {final _that = this;
switch (_that) {
case ProductsInitial() when initial != null:
return initial();case ProductsLoading() when productsLoading != null:
return productsLoading();case ProductsLoaded() when productsLoaded != null:
return productsLoaded(_that.products,_that.categories,_that.selectedCategory,_that.searchQuery);case ProductsEmpty() when productsEmpty != null:
return productsEmpty(_that.categories,_that.selectedCategory,_that.searchQuery);case ProductsError() when productsError != null:
return productsError(_that.apiErrorModel);case _:
  return null;

}
}

}

/// @nodoc


class ProductsInitial implements ProductsState {
  const ProductsInitial();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductsInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ProductsState.initial()';
}


}




/// @nodoc


class ProductsLoading implements ProductsState {
  const ProductsLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductsLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ProductsState.productsLoading()';
}


}




/// @nodoc


class ProductsLoaded implements ProductsState {
  const ProductsLoaded({required  List<ProductDoc> products, required  List<String> categories, this.selectedCategory, this.searchQuery = ''}): _products = products,_categories = categories;
  

 final  List<ProductDoc> _products;
 List<ProductDoc> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}

/// Distinct categories across the whole catalog (chips stay complete
/// while one category is selected).
 final  List<String> _categories;
/// Distinct categories across the whole catalog (chips stay complete
/// while one category is selected).
 List<String> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  String? selectedCategory;
@JsonKey() final  String searchQuery;

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductsLoadedCopyWith<ProductsLoaded> get copyWith => _$ProductsLoadedCopyWithImpl<ProductsLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductsLoaded&&const DeepCollectionEquality().equals(other.products, _products)&&const DeepCollectionEquality().equals(other.categories, _categories)&&(identical(other.selectedCategory, selectedCategory) || other.selectedCategory == selectedCategory)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_products),const DeepCollectionEquality().hash(_categories),selectedCategory,searchQuery);
}

@override
String toString() {
    return 'ProductsState.productsLoaded(products: $products, categories: $categories, selectedCategory: $selectedCategory, searchQuery: $searchQuery)';
}


}

/// @nodoc
abstract mixin class $ProductsLoadedCopyWith<$Res> implements $ProductsStateCopyWith<$Res> {
  factory $ProductsLoadedCopyWith(ProductsLoaded value, $Res Function(ProductsLoaded) _then) = _$ProductsLoadedCopyWithImpl;
@useResult
$Res call({
 List<ProductDoc> products, List<String> categories, String? selectedCategory, String searchQuery
});




}
/// @nodoc
class _$ProductsLoadedCopyWithImpl<$Res>
    implements $ProductsLoadedCopyWith<$Res> {
  _$ProductsLoadedCopyWithImpl(this._self, this._then);

  final ProductsLoaded _self;
  final $Res Function(ProductsLoaded) _then;

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? products = null,Object? categories = null,Object? selectedCategory = freezed,Object? searchQuery = null,}) {
  return _then(ProductsLoaded(
products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<ProductDoc>,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,selectedCategory: freezed == selectedCategory ? _self.selectedCategory : selectedCategory // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ProductsEmpty implements ProductsState {
  const ProductsEmpty({required  List<String> categories, this.selectedCategory, this.searchQuery = ''}): _categories = categories;
  

 final  List<String> _categories;
 List<String> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  String? selectedCategory;
@JsonKey() final  String searchQuery;

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductsEmptyCopyWith<ProductsEmpty> get copyWith => _$ProductsEmptyCopyWithImpl<ProductsEmpty>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductsEmpty&&const DeepCollectionEquality().equals(other.categories, _categories)&&(identical(other.selectedCategory, selectedCategory) || other.selectedCategory == selectedCategory)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_categories),selectedCategory,searchQuery);
}

@override
String toString() {
    return 'ProductsState.productsEmpty(categories: $categories, selectedCategory: $selectedCategory, searchQuery: $searchQuery)';
}


}

/// @nodoc
abstract mixin class $ProductsEmptyCopyWith<$Res> implements $ProductsStateCopyWith<$Res> {
  factory $ProductsEmptyCopyWith(ProductsEmpty value, $Res Function(ProductsEmpty) _then) = _$ProductsEmptyCopyWithImpl;
@useResult
$Res call({
 List<String> categories, String? selectedCategory, String searchQuery
});




}
/// @nodoc
class _$ProductsEmptyCopyWithImpl<$Res>
    implements $ProductsEmptyCopyWith<$Res> {
  _$ProductsEmptyCopyWithImpl(this._self, this._then);

  final ProductsEmpty _self;
  final $Res Function(ProductsEmpty) _then;

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? categories = null,Object? selectedCategory = freezed,Object? searchQuery = null,}) {
  return _then(ProductsEmpty(
categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,selectedCategory: freezed == selectedCategory ? _self.selectedCategory : selectedCategory // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ProductsError implements ProductsState {
  const ProductsError(this.apiErrorModel);
  

 final  ApiErrorModel apiErrorModel;

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductsErrorCopyWith<ProductsError> get copyWith => _$ProductsErrorCopyWithImpl<ProductsError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductsError&&(identical(other.apiErrorModel, apiErrorModel) || other.apiErrorModel == apiErrorModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,apiErrorModel);
}

@override
String toString() {
    return 'ProductsState.productsError(apiErrorModel: $apiErrorModel)';
}


}

/// @nodoc
abstract mixin class $ProductsErrorCopyWith<$Res> implements $ProductsStateCopyWith<$Res> {
  factory $ProductsErrorCopyWith(ProductsError value, $Res Function(ProductsError) _then) = _$ProductsErrorCopyWithImpl;
@useResult
$Res call({
 ApiErrorModel apiErrorModel
});




}
/// @nodoc
class _$ProductsErrorCopyWithImpl<$Res>
    implements $ProductsErrorCopyWith<$Res> {
  _$ProductsErrorCopyWithImpl(this._self, this._then);

  final ProductsError _self;
  final $Res Function(ProductsError) _then;

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? apiErrorModel = null,}) {
  return _then(ProductsError(
null == apiErrorModel ? _self.apiErrorModel : apiErrorModel // ignore: cast_nullable_to_non_nullable
as ApiErrorModel,
  ));
}


}

// dart format on
