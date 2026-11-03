// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkout_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CheckoutState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CheckoutState()';
}


}

/// @nodoc
class $CheckoutStateCopyWith<$Res>  {
$CheckoutStateCopyWith(CheckoutState _, $Res Function(CheckoutState) __);
}


/// Adds pattern-matching-related methods to [CheckoutState].
extension CheckoutStatePatterns on CheckoutState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( CheckoutLoading value)?  checkoutLoading,TResult Function( CheckoutLoaded value)?  checkoutLoaded,TResult Function( OrderPlacing value)?  orderPlacing,TResult Function( OrderSuccess value)?  orderSuccess,TResult Function( CheckoutError value)?  checkoutError,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case CheckoutLoading() when checkoutLoading != null:
return checkoutLoading(_that);case CheckoutLoaded() when checkoutLoaded != null:
return checkoutLoaded(_that);case OrderPlacing() when orderPlacing != null:
return orderPlacing(_that);case OrderSuccess() when orderSuccess != null:
return orderSuccess(_that);case CheckoutError() when checkoutError != null:
return checkoutError(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( CheckoutLoading value)  checkoutLoading,required TResult Function( CheckoutLoaded value)  checkoutLoaded,required TResult Function( OrderPlacing value)  orderPlacing,required TResult Function( OrderSuccess value)  orderSuccess,required TResult Function( CheckoutError value)  checkoutError,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case CheckoutLoading():
return checkoutLoading(_that);case CheckoutLoaded():
return checkoutLoaded(_that);case OrderPlacing():
return orderPlacing(_that);case OrderSuccess():
return orderSuccess(_that);case CheckoutError():
return checkoutError(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( CheckoutLoading value)?  checkoutLoading,TResult? Function( CheckoutLoaded value)?  checkoutLoaded,TResult? Function( OrderPlacing value)?  orderPlacing,TResult? Function( OrderSuccess value)?  orderSuccess,TResult? Function( CheckoutError value)?  checkoutError,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case CheckoutLoading() when checkoutLoading != null:
return checkoutLoading(_that);case CheckoutLoaded() when checkoutLoaded != null:
return checkoutLoaded(_that);case OrderPlacing() when orderPlacing != null:
return orderPlacing(_that);case OrderSuccess() when orderSuccess != null:
return orderSuccess(_that);case CheckoutError() when checkoutError != null:
return checkoutError(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  checkoutLoading,TResult Function( List<CartItemModel> items,  double totalPrice)?  checkoutLoaded,TResult Function( List<CartItemModel> items,  double totalPrice)?  orderPlacing,TResult Function( String orderId)?  orderSuccess,TResult Function( ApiErrorModel apiErrorModel)?  checkoutError,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case CheckoutLoading() when checkoutLoading != null:
return checkoutLoading();case CheckoutLoaded() when checkoutLoaded != null:
return checkoutLoaded(_that.items,_that.totalPrice);case OrderPlacing() when orderPlacing != null:
return orderPlacing(_that.items,_that.totalPrice);case OrderSuccess() when orderSuccess != null:
return orderSuccess(_that.orderId);case CheckoutError() when checkoutError != null:
return checkoutError(_that.apiErrorModel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  checkoutLoading,required TResult Function( List<CartItemModel> items,  double totalPrice)  checkoutLoaded,required TResult Function( List<CartItemModel> items,  double totalPrice)  orderPlacing,required TResult Function( String orderId)  orderSuccess,required TResult Function( ApiErrorModel apiErrorModel)  checkoutError,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case CheckoutLoading():
return checkoutLoading();case CheckoutLoaded():
return checkoutLoaded(_that.items,_that.totalPrice);case OrderPlacing():
return orderPlacing(_that.items,_that.totalPrice);case OrderSuccess():
return orderSuccess(_that.orderId);case CheckoutError():
return checkoutError(_that.apiErrorModel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  checkoutLoading,TResult? Function( List<CartItemModel> items,  double totalPrice)?  checkoutLoaded,TResult? Function( List<CartItemModel> items,  double totalPrice)?  orderPlacing,TResult? Function( String orderId)?  orderSuccess,TResult? Function( ApiErrorModel apiErrorModel)?  checkoutError,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case CheckoutLoading() when checkoutLoading != null:
return checkoutLoading();case CheckoutLoaded() when checkoutLoaded != null:
return checkoutLoaded(_that.items,_that.totalPrice);case OrderPlacing() when orderPlacing != null:
return orderPlacing(_that.items,_that.totalPrice);case OrderSuccess() when orderSuccess != null:
return orderSuccess(_that.orderId);case CheckoutError() when checkoutError != null:
return checkoutError(_that.apiErrorModel);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements CheckoutState {
  const _Initial();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CheckoutState.initial()';
}


}




/// @nodoc


class CheckoutLoading implements CheckoutState {
  const CheckoutLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CheckoutState.checkoutLoading()';
}


}




/// @nodoc


class CheckoutLoaded implements CheckoutState {
  const CheckoutLoaded({required  List<CartItemModel> items, required this.totalPrice}): _items = items;
  

 final  List<CartItemModel> _items;
 List<CartItemModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  double totalPrice;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutLoadedCopyWith<CheckoutLoaded> get copyWith => _$CheckoutLoadedCopyWithImpl<CheckoutLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutLoaded&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),totalPrice);
}

@override
String toString() {
    return 'CheckoutState.checkoutLoaded(items: $items, totalPrice: $totalPrice)';
}


}

/// @nodoc
abstract mixin class $CheckoutLoadedCopyWith<$Res> implements $CheckoutStateCopyWith<$Res> {
  factory $CheckoutLoadedCopyWith(CheckoutLoaded value, $Res Function(CheckoutLoaded) _then) = _$CheckoutLoadedCopyWithImpl;
@useResult
$Res call({
 List<CartItemModel> items, double totalPrice
});




}
/// @nodoc
class _$CheckoutLoadedCopyWithImpl<$Res>
    implements $CheckoutLoadedCopyWith<$Res> {
  _$CheckoutLoadedCopyWithImpl(this._self, this._then);

  final CheckoutLoaded _self;
  final $Res Function(CheckoutLoaded) _then;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? items = null,Object? totalPrice = null,}) {
  return _then(CheckoutLoaded(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CartItemModel>,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class OrderPlacing implements CheckoutState {
  const OrderPlacing({required  List<CartItemModel> items, required this.totalPrice}): _items = items;
  

 final  List<CartItemModel> _items;
 List<CartItemModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  double totalPrice;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderPlacingCopyWith<OrderPlacing> get copyWith => _$OrderPlacingCopyWithImpl<OrderPlacing>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderPlacing&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),totalPrice);
}

@override
String toString() {
    return 'CheckoutState.orderPlacing(items: $items, totalPrice: $totalPrice)';
}


}

/// @nodoc
abstract mixin class $OrderPlacingCopyWith<$Res> implements $CheckoutStateCopyWith<$Res> {
  factory $OrderPlacingCopyWith(OrderPlacing value, $Res Function(OrderPlacing) _then) = _$OrderPlacingCopyWithImpl;
@useResult
$Res call({
 List<CartItemModel> items, double totalPrice
});




}
/// @nodoc
class _$OrderPlacingCopyWithImpl<$Res>
    implements $OrderPlacingCopyWith<$Res> {
  _$OrderPlacingCopyWithImpl(this._self, this._then);

  final OrderPlacing _self;
  final $Res Function(OrderPlacing) _then;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? items = null,Object? totalPrice = null,}) {
  return _then(OrderPlacing(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CartItemModel>,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class OrderSuccess implements CheckoutState {
  const OrderSuccess(this.orderId);
  

 final  String orderId;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderSuccessCopyWith<OrderSuccess> get copyWith => _$OrderSuccessCopyWithImpl<OrderSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderSuccess&&(identical(other.orderId, orderId) || other.orderId == orderId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,orderId);
}

@override
String toString() {
    return 'CheckoutState.orderSuccess(orderId: $orderId)';
}


}

/// @nodoc
abstract mixin class $OrderSuccessCopyWith<$Res> implements $CheckoutStateCopyWith<$Res> {
  factory $OrderSuccessCopyWith(OrderSuccess value, $Res Function(OrderSuccess) _then) = _$OrderSuccessCopyWithImpl;
@useResult
$Res call({
 String orderId
});




}
/// @nodoc
class _$OrderSuccessCopyWithImpl<$Res>
    implements $OrderSuccessCopyWith<$Res> {
  _$OrderSuccessCopyWithImpl(this._self, this._then);

  final OrderSuccess _self;
  final $Res Function(OrderSuccess) _then;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? orderId = null,}) {
  return _then(OrderSuccess(
null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CheckoutError implements CheckoutState {
  const CheckoutError(this.apiErrorModel);
  

 final  ApiErrorModel apiErrorModel;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutErrorCopyWith<CheckoutError> get copyWith => _$CheckoutErrorCopyWithImpl<CheckoutError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutError&&(identical(other.apiErrorModel, apiErrorModel) || other.apiErrorModel == apiErrorModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,apiErrorModel);
}

@override
String toString() {
    return 'CheckoutState.checkoutError(apiErrorModel: $apiErrorModel)';
}


}

/// @nodoc
abstract mixin class $CheckoutErrorCopyWith<$Res> implements $CheckoutStateCopyWith<$Res> {
  factory $CheckoutErrorCopyWith(CheckoutError value, $Res Function(CheckoutError) _then) = _$CheckoutErrorCopyWithImpl;
@useResult
$Res call({
 ApiErrorModel apiErrorModel
});




}
/// @nodoc
class _$CheckoutErrorCopyWithImpl<$Res>
    implements $CheckoutErrorCopyWith<$Res> {
  _$CheckoutErrorCopyWithImpl(this._self, this._then);

  final CheckoutError _self;
  final $Res Function(CheckoutError) _then;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? apiErrorModel = null,}) {
  return _then(CheckoutError(
null == apiErrorModel ? _self.apiErrorModel : apiErrorModel // ignore: cast_nullable_to_non_nullable
as ApiErrorModel,
  ));
}


}

// dart format on
