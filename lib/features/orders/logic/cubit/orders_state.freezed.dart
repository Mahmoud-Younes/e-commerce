// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'orders_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OrdersState<T> {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OrdersState<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'OrdersState<$T>()';
}


}

/// @nodoc
class $OrdersStateCopyWith<T,$Res>  {
$OrdersStateCopyWith(OrdersState<T> _, $Res Function(OrdersState<T>) __);
}


/// Adds pattern-matching-related methods to [OrdersState].
extension OrdersStatePatterns<T> on OrdersState<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial<T> value)?  initial,TResult Function( OrdersLoading<T> value)?  ordersLoading,TResult Function( OrdersLoaded<T> value)?  ordersLoaded,TResult Function( OrdersEmpty<T> value)?  ordersEmpty,TResult Function( OrdersError<T> value)?  ordersError,TResult Function( OrderDetailsLoading<T> value)?  orderDetailsLoading,TResult Function( OrderDetailsLoaded<T> value)?  orderDetailsLoaded,TResult Function( OrderDetailsError<T> value)?  orderDetailsError,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case OrdersLoading() when ordersLoading != null:
return ordersLoading(_that);case OrdersLoaded() when ordersLoaded != null:
return ordersLoaded(_that);case OrdersEmpty() when ordersEmpty != null:
return ordersEmpty(_that);case OrdersError() when ordersError != null:
return ordersError(_that);case OrderDetailsLoading() when orderDetailsLoading != null:
return orderDetailsLoading(_that);case OrderDetailsLoaded() when orderDetailsLoaded != null:
return orderDetailsLoaded(_that);case OrderDetailsError() when orderDetailsError != null:
return orderDetailsError(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial<T> value)  initial,required TResult Function( OrdersLoading<T> value)  ordersLoading,required TResult Function( OrdersLoaded<T> value)  ordersLoaded,required TResult Function( OrdersEmpty<T> value)  ordersEmpty,required TResult Function( OrdersError<T> value)  ordersError,required TResult Function( OrderDetailsLoading<T> value)  orderDetailsLoading,required TResult Function( OrderDetailsLoaded<T> value)  orderDetailsLoaded,required TResult Function( OrderDetailsError<T> value)  orderDetailsError,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case OrdersLoading():
return ordersLoading(_that);case OrdersLoaded():
return ordersLoaded(_that);case OrdersEmpty():
return ordersEmpty(_that);case OrdersError():
return ordersError(_that);case OrderDetailsLoading():
return orderDetailsLoading(_that);case OrderDetailsLoaded():
return orderDetailsLoaded(_that);case OrderDetailsError():
return orderDetailsError(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial<T> value)?  initial,TResult? Function( OrdersLoading<T> value)?  ordersLoading,TResult? Function( OrdersLoaded<T> value)?  ordersLoaded,TResult? Function( OrdersEmpty<T> value)?  ordersEmpty,TResult? Function( OrdersError<T> value)?  ordersError,TResult? Function( OrderDetailsLoading<T> value)?  orderDetailsLoading,TResult? Function( OrderDetailsLoaded<T> value)?  orderDetailsLoaded,TResult? Function( OrderDetailsError<T> value)?  orderDetailsError,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case OrdersLoading() when ordersLoading != null:
return ordersLoading(_that);case OrdersLoaded() when ordersLoaded != null:
return ordersLoaded(_that);case OrdersEmpty() when ordersEmpty != null:
return ordersEmpty(_that);case OrdersError() when ordersError != null:
return ordersError(_that);case OrderDetailsLoading() when orderDetailsLoading != null:
return orderDetailsLoading(_that);case OrderDetailsLoaded() when orderDetailsLoaded != null:
return orderDetailsLoaded(_that);case OrderDetailsError() when orderDetailsError != null:
return orderDetailsError(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  ordersLoading,TResult Function( List<OrderModel> orders)?  ordersLoaded,TResult Function()?  ordersEmpty,TResult Function( ApiErrorModel apiErrorModel)?  ordersError,TResult Function()?  orderDetailsLoading,TResult Function( OrderModel order)?  orderDetailsLoaded,TResult Function( ApiErrorModel apiErrorModel)?  orderDetailsError,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case OrdersLoading() when ordersLoading != null:
return ordersLoading();case OrdersLoaded() when ordersLoaded != null:
return ordersLoaded(_that.orders);case OrdersEmpty() when ordersEmpty != null:
return ordersEmpty();case OrdersError() when ordersError != null:
return ordersError(_that.apiErrorModel);case OrderDetailsLoading() when orderDetailsLoading != null:
return orderDetailsLoading();case OrderDetailsLoaded() when orderDetailsLoaded != null:
return orderDetailsLoaded(_that.order);case OrderDetailsError() when orderDetailsError != null:
return orderDetailsError(_that.apiErrorModel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  ordersLoading,required TResult Function( List<OrderModel> orders)  ordersLoaded,required TResult Function()  ordersEmpty,required TResult Function( ApiErrorModel apiErrorModel)  ordersError,required TResult Function()  orderDetailsLoading,required TResult Function( OrderModel order)  orderDetailsLoaded,required TResult Function( ApiErrorModel apiErrorModel)  orderDetailsError,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case OrdersLoading():
return ordersLoading();case OrdersLoaded():
return ordersLoaded(_that.orders);case OrdersEmpty():
return ordersEmpty();case OrdersError():
return ordersError(_that.apiErrorModel);case OrderDetailsLoading():
return orderDetailsLoading();case OrderDetailsLoaded():
return orderDetailsLoaded(_that.order);case OrderDetailsError():
return orderDetailsError(_that.apiErrorModel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  ordersLoading,TResult? Function( List<OrderModel> orders)?  ordersLoaded,TResult? Function()?  ordersEmpty,TResult? Function( ApiErrorModel apiErrorModel)?  ordersError,TResult? Function()?  orderDetailsLoading,TResult? Function( OrderModel order)?  orderDetailsLoaded,TResult? Function( ApiErrorModel apiErrorModel)?  orderDetailsError,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case OrdersLoading() when ordersLoading != null:
return ordersLoading();case OrdersLoaded() when ordersLoaded != null:
return ordersLoaded(_that.orders);case OrdersEmpty() when ordersEmpty != null:
return ordersEmpty();case OrdersError() when ordersError != null:
return ordersError(_that.apiErrorModel);case OrderDetailsLoading() when orderDetailsLoading != null:
return orderDetailsLoading();case OrderDetailsLoaded() when orderDetailsLoaded != null:
return orderDetailsLoaded(_that.order);case OrderDetailsError() when orderDetailsError != null:
return orderDetailsError(_that.apiErrorModel);case _:
  return null;

}
}

}

/// @nodoc


class _Initial<T> implements OrdersState<T> {
  const _Initial();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'OrdersState<$T>.initial()';
}


}




/// @nodoc


class OrdersLoading<T> implements OrdersState<T> {
  const OrdersLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OrdersLoading<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'OrdersState<$T>.ordersLoading()';
}


}




/// @nodoc


class OrdersLoaded<T> implements OrdersState<T> {
  const OrdersLoaded( List<OrderModel> orders): _orders = orders;
  

 final  List<OrderModel> _orders;
 List<OrderModel> get orders {
  if (_orders is EqualUnmodifiableListView) return _orders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_orders);
}


/// Create a copy of OrdersState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrdersLoadedCopyWith<T, OrdersLoaded<T>> get copyWith => _$OrdersLoadedCopyWithImpl<T, OrdersLoaded<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OrdersLoaded<T>&&const DeepCollectionEquality().equals(other.orders, _orders));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_orders));
}

@override
String toString() {
    return 'OrdersState<$T>.ordersLoaded(orders: $orders)';
}


}

/// @nodoc
abstract mixin class $OrdersLoadedCopyWith<T,$Res> implements $OrdersStateCopyWith<T, $Res> {
  factory $OrdersLoadedCopyWith(OrdersLoaded<T> value, $Res Function(OrdersLoaded<T>) _then) = _$OrdersLoadedCopyWithImpl;
@useResult
$Res call({
 List<OrderModel> orders
});




}
/// @nodoc
class _$OrdersLoadedCopyWithImpl<T,$Res>
    implements $OrdersLoadedCopyWith<T, $Res> {
  _$OrdersLoadedCopyWithImpl(this._self, this._then);

  final OrdersLoaded<T> _self;
  final $Res Function(OrdersLoaded<T>) _then;

/// Create a copy of OrdersState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? orders = null,}) {
  return _then(OrdersLoaded<T>(
null == orders ? _self._orders : orders // ignore: cast_nullable_to_non_nullable
as List<OrderModel>,
  ));
}


}

/// @nodoc


class OrdersEmpty<T> implements OrdersState<T> {
  const OrdersEmpty();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OrdersEmpty<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'OrdersState<$T>.ordersEmpty()';
}


}




/// @nodoc


class OrdersError<T> implements OrdersState<T> {
  const OrdersError(this.apiErrorModel);
  

 final  ApiErrorModel apiErrorModel;

/// Create a copy of OrdersState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrdersErrorCopyWith<T, OrdersError<T>> get copyWith => _$OrdersErrorCopyWithImpl<T, OrdersError<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OrdersError<T>&&(identical(other.apiErrorModel, apiErrorModel) || other.apiErrorModel == apiErrorModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,apiErrorModel);
}

@override
String toString() {
    return 'OrdersState<$T>.ordersError(apiErrorModel: $apiErrorModel)';
}


}

/// @nodoc
abstract mixin class $OrdersErrorCopyWith<T,$Res> implements $OrdersStateCopyWith<T, $Res> {
  factory $OrdersErrorCopyWith(OrdersError<T> value, $Res Function(OrdersError<T>) _then) = _$OrdersErrorCopyWithImpl;
@useResult
$Res call({
 ApiErrorModel apiErrorModel
});




}
/// @nodoc
class _$OrdersErrorCopyWithImpl<T,$Res>
    implements $OrdersErrorCopyWith<T, $Res> {
  _$OrdersErrorCopyWithImpl(this._self, this._then);

  final OrdersError<T> _self;
  final $Res Function(OrdersError<T>) _then;

/// Create a copy of OrdersState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? apiErrorModel = null,}) {
  return _then(OrdersError<T>(
null == apiErrorModel ? _self.apiErrorModel : apiErrorModel // ignore: cast_nullable_to_non_nullable
as ApiErrorModel,
  ));
}


}

/// @nodoc


class OrderDetailsLoading<T> implements OrdersState<T> {
  const OrderDetailsLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderDetailsLoading<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'OrdersState<$T>.orderDetailsLoading()';
}


}




/// @nodoc


class OrderDetailsLoaded<T> implements OrdersState<T> {
  const OrderDetailsLoaded(this.order);
  

 final  OrderModel order;

/// Create a copy of OrdersState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderDetailsLoadedCopyWith<T, OrderDetailsLoaded<T>> get copyWith => _$OrderDetailsLoadedCopyWithImpl<T, OrderDetailsLoaded<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderDetailsLoaded<T>&&(identical(other.order, order) || other.order == order));
}


@override
int get hashCode {
    return Object.hash(runtimeType,order);
}

@override
String toString() {
    return 'OrdersState<$T>.orderDetailsLoaded(order: $order)';
}


}

/// @nodoc
abstract mixin class $OrderDetailsLoadedCopyWith<T,$Res> implements $OrdersStateCopyWith<T, $Res> {
  factory $OrderDetailsLoadedCopyWith(OrderDetailsLoaded<T> value, $Res Function(OrderDetailsLoaded<T>) _then) = _$OrderDetailsLoadedCopyWithImpl;
@useResult
$Res call({
 OrderModel order
});




}
/// @nodoc
class _$OrderDetailsLoadedCopyWithImpl<T,$Res>
    implements $OrderDetailsLoadedCopyWith<T, $Res> {
  _$OrderDetailsLoadedCopyWithImpl(this._self, this._then);

  final OrderDetailsLoaded<T> _self;
  final $Res Function(OrderDetailsLoaded<T>) _then;

/// Create a copy of OrdersState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? order = null,}) {
  return _then(OrderDetailsLoaded<T>(
null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as OrderModel,
  ));
}


}

/// @nodoc


class OrderDetailsError<T> implements OrdersState<T> {
  const OrderDetailsError(this.apiErrorModel);
  

 final  ApiErrorModel apiErrorModel;

/// Create a copy of OrdersState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderDetailsErrorCopyWith<T, OrderDetailsError<T>> get copyWith => _$OrderDetailsErrorCopyWithImpl<T, OrderDetailsError<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderDetailsError<T>&&(identical(other.apiErrorModel, apiErrorModel) || other.apiErrorModel == apiErrorModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,apiErrorModel);
}

@override
String toString() {
    return 'OrdersState<$T>.orderDetailsError(apiErrorModel: $apiErrorModel)';
}


}

/// @nodoc
abstract mixin class $OrderDetailsErrorCopyWith<T,$Res> implements $OrdersStateCopyWith<T, $Res> {
  factory $OrderDetailsErrorCopyWith(OrderDetailsError<T> value, $Res Function(OrderDetailsError<T>) _then) = _$OrderDetailsErrorCopyWithImpl;
@useResult
$Res call({
 ApiErrorModel apiErrorModel
});




}
/// @nodoc
class _$OrderDetailsErrorCopyWithImpl<T,$Res>
    implements $OrderDetailsErrorCopyWith<T, $Res> {
  _$OrderDetailsErrorCopyWithImpl(this._self, this._then);

  final OrderDetailsError<T> _self;
  final $Res Function(OrderDetailsError<T>) _then;

/// Create a copy of OrdersState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? apiErrorModel = null,}) {
  return _then(OrderDetailsError<T>(
null == apiErrorModel ? _self.apiErrorModel : apiErrorModel // ignore: cast_nullable_to_non_nullable
as ApiErrorModel,
  ));
}


}

// dart format on
