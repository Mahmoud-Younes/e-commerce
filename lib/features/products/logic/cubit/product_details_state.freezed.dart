// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_details_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductDetailsState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductDetailsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ProductDetailsState()';
}


}

/// @nodoc
class $ProductDetailsStateCopyWith<$Res>  {
$ProductDetailsStateCopyWith(ProductDetailsState _, $Res Function(ProductDetailsState) __);
}


/// Adds pattern-matching-related methods to [ProductDetailsState].
extension ProductDetailsStatePatterns on ProductDetailsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ProductDetailsInitial value)?  initial,TResult Function( ProductDetailsLoading value)?  detailsLoading,TResult Function( ProductDetailsLoaded value)?  detailsLoaded,TResult Function( ProductDetailsError value)?  detailsError,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ProductDetailsInitial() when initial != null:
return initial(_that);case ProductDetailsLoading() when detailsLoading != null:
return detailsLoading(_that);case ProductDetailsLoaded() when detailsLoaded != null:
return detailsLoaded(_that);case ProductDetailsError() when detailsError != null:
return detailsError(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ProductDetailsInitial value)  initial,required TResult Function( ProductDetailsLoading value)  detailsLoading,required TResult Function( ProductDetailsLoaded value)  detailsLoaded,required TResult Function( ProductDetailsError value)  detailsError,}){
final _that = this;
switch (_that) {
case ProductDetailsInitial():
return initial(_that);case ProductDetailsLoading():
return detailsLoading(_that);case ProductDetailsLoaded():
return detailsLoaded(_that);case ProductDetailsError():
return detailsError(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ProductDetailsInitial value)?  initial,TResult? Function( ProductDetailsLoading value)?  detailsLoading,TResult? Function( ProductDetailsLoaded value)?  detailsLoaded,TResult? Function( ProductDetailsError value)?  detailsError,}){
final _that = this;
switch (_that) {
case ProductDetailsInitial() when initial != null:
return initial(_that);case ProductDetailsLoading() when detailsLoading != null:
return detailsLoading(_that);case ProductDetailsLoaded() when detailsLoaded != null:
return detailsLoaded(_that);case ProductDetailsError() when detailsError != null:
return detailsError(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  detailsLoading,TResult Function( ProductModel product)?  detailsLoaded,TResult Function( ApiErrorModel apiErrorModel)?  detailsError,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ProductDetailsInitial() when initial != null:
return initial();case ProductDetailsLoading() when detailsLoading != null:
return detailsLoading();case ProductDetailsLoaded() when detailsLoaded != null:
return detailsLoaded(_that.product);case ProductDetailsError() when detailsError != null:
return detailsError(_that.apiErrorModel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  detailsLoading,required TResult Function( ProductModel product)  detailsLoaded,required TResult Function( ApiErrorModel apiErrorModel)  detailsError,}) {final _that = this;
switch (_that) {
case ProductDetailsInitial():
return initial();case ProductDetailsLoading():
return detailsLoading();case ProductDetailsLoaded():
return detailsLoaded(_that.product);case ProductDetailsError():
return detailsError(_that.apiErrorModel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  detailsLoading,TResult? Function( ProductModel product)?  detailsLoaded,TResult? Function( ApiErrorModel apiErrorModel)?  detailsError,}) {final _that = this;
switch (_that) {
case ProductDetailsInitial() when initial != null:
return initial();case ProductDetailsLoading() when detailsLoading != null:
return detailsLoading();case ProductDetailsLoaded() when detailsLoaded != null:
return detailsLoaded(_that.product);case ProductDetailsError() when detailsError != null:
return detailsError(_that.apiErrorModel);case _:
  return null;

}
}

}

/// @nodoc


class ProductDetailsInitial implements ProductDetailsState {
  const ProductDetailsInitial();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductDetailsInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ProductDetailsState.initial()';
}


}




/// @nodoc


class ProductDetailsLoading implements ProductDetailsState {
  const ProductDetailsLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductDetailsLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ProductDetailsState.detailsLoading()';
}


}




/// @nodoc


class ProductDetailsLoaded implements ProductDetailsState {
  const ProductDetailsLoaded(this.product);
  

 final  ProductModel product;

/// Create a copy of ProductDetailsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductDetailsLoadedCopyWith<ProductDetailsLoaded> get copyWith => _$ProductDetailsLoadedCopyWithImpl<ProductDetailsLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductDetailsLoaded&&(identical(other.product, product) || other.product == product));
}


@override
int get hashCode {
    return Object.hash(runtimeType,product);
}

@override
String toString() {
    return 'ProductDetailsState.detailsLoaded(product: $product)';
}


}

/// @nodoc
abstract mixin class $ProductDetailsLoadedCopyWith<$Res> implements $ProductDetailsStateCopyWith<$Res> {
  factory $ProductDetailsLoadedCopyWith(ProductDetailsLoaded value, $Res Function(ProductDetailsLoaded) _then) = _$ProductDetailsLoadedCopyWithImpl;
@useResult
$Res call({
 ProductModel product
});




}
/// @nodoc
class _$ProductDetailsLoadedCopyWithImpl<$Res>
    implements $ProductDetailsLoadedCopyWith<$Res> {
  _$ProductDetailsLoadedCopyWithImpl(this._self, this._then);

  final ProductDetailsLoaded _self;
  final $Res Function(ProductDetailsLoaded) _then;

/// Create a copy of ProductDetailsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? product = null,}) {
  return _then(ProductDetailsLoaded(
null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductModel,
  ));
}


}

/// @nodoc


class ProductDetailsError implements ProductDetailsState {
  const ProductDetailsError(this.apiErrorModel);
  

 final  ApiErrorModel apiErrorModel;

/// Create a copy of ProductDetailsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductDetailsErrorCopyWith<ProductDetailsError> get copyWith => _$ProductDetailsErrorCopyWithImpl<ProductDetailsError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductDetailsError&&(identical(other.apiErrorModel, apiErrorModel) || other.apiErrorModel == apiErrorModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,apiErrorModel);
}

@override
String toString() {
    return 'ProductDetailsState.detailsError(apiErrorModel: $apiErrorModel)';
}


}

/// @nodoc
abstract mixin class $ProductDetailsErrorCopyWith<$Res> implements $ProductDetailsStateCopyWith<$Res> {
  factory $ProductDetailsErrorCopyWith(ProductDetailsError value, $Res Function(ProductDetailsError) _then) = _$ProductDetailsErrorCopyWithImpl;
@useResult
$Res call({
 ApiErrorModel apiErrorModel
});




}
/// @nodoc
class _$ProductDetailsErrorCopyWithImpl<$Res>
    implements $ProductDetailsErrorCopyWith<$Res> {
  _$ProductDetailsErrorCopyWithImpl(this._self, this._then);

  final ProductDetailsError _self;
  final $Res Function(ProductDetailsError) _then;

/// Create a copy of ProductDetailsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? apiErrorModel = null,}) {
  return _then(ProductDetailsError(
null == apiErrorModel ? _self.apiErrorModel : apiErrorModel // ignore: cast_nullable_to_non_nullable
as ApiErrorModel,
  ));
}


}

// dart format on
