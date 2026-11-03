// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_orders_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AdminOrdersState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminOrdersState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AdminOrdersState()';
}


}

/// @nodoc
class $AdminOrdersStateCopyWith<$Res>  {
$AdminOrdersStateCopyWith(AdminOrdersState _, $Res Function(AdminOrdersState) __);
}


/// Adds pattern-matching-related methods to [AdminOrdersState].
extension AdminOrdersStatePatterns on AdminOrdersState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( AdminOrdersLoading value)?  ordersLoading,TResult Function( AdminOrdersSuccess value)?  ordersSuccess,TResult Function( AdminOrdersError value)?  ordersError,TResult Function( AdminOrderDetailsLoading value)?  orderDetailsLoading,TResult Function( AdminOrderDetailsSuccess value)?  orderDetailsSuccess,TResult Function( AdminOrderDetailsError value)?  orderDetailsError,TResult Function( AdminOrderStatusUpdateLoading value)?  statusUpdateLoading,TResult Function( AdminOrderStatusUpdateSuccess value)?  statusUpdateSuccess,TResult Function( AdminOrderStatusUpdateError value)?  statusUpdateError,TResult Function( AdminOrdersWriteUnauthorized value)?  writeUnauthorized,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case AdminOrdersLoading() when ordersLoading != null:
return ordersLoading(_that);case AdminOrdersSuccess() when ordersSuccess != null:
return ordersSuccess(_that);case AdminOrdersError() when ordersError != null:
return ordersError(_that);case AdminOrderDetailsLoading() when orderDetailsLoading != null:
return orderDetailsLoading(_that);case AdminOrderDetailsSuccess() when orderDetailsSuccess != null:
return orderDetailsSuccess(_that);case AdminOrderDetailsError() when orderDetailsError != null:
return orderDetailsError(_that);case AdminOrderStatusUpdateLoading() when statusUpdateLoading != null:
return statusUpdateLoading(_that);case AdminOrderStatusUpdateSuccess() when statusUpdateSuccess != null:
return statusUpdateSuccess(_that);case AdminOrderStatusUpdateError() when statusUpdateError != null:
return statusUpdateError(_that);case AdminOrdersWriteUnauthorized() when writeUnauthorized != null:
return writeUnauthorized(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( AdminOrdersLoading value)  ordersLoading,required TResult Function( AdminOrdersSuccess value)  ordersSuccess,required TResult Function( AdminOrdersError value)  ordersError,required TResult Function( AdminOrderDetailsLoading value)  orderDetailsLoading,required TResult Function( AdminOrderDetailsSuccess value)  orderDetailsSuccess,required TResult Function( AdminOrderDetailsError value)  orderDetailsError,required TResult Function( AdminOrderStatusUpdateLoading value)  statusUpdateLoading,required TResult Function( AdminOrderStatusUpdateSuccess value)  statusUpdateSuccess,required TResult Function( AdminOrderStatusUpdateError value)  statusUpdateError,required TResult Function( AdminOrdersWriteUnauthorized value)  writeUnauthorized,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case AdminOrdersLoading():
return ordersLoading(_that);case AdminOrdersSuccess():
return ordersSuccess(_that);case AdminOrdersError():
return ordersError(_that);case AdminOrderDetailsLoading():
return orderDetailsLoading(_that);case AdminOrderDetailsSuccess():
return orderDetailsSuccess(_that);case AdminOrderDetailsError():
return orderDetailsError(_that);case AdminOrderStatusUpdateLoading():
return statusUpdateLoading(_that);case AdminOrderStatusUpdateSuccess():
return statusUpdateSuccess(_that);case AdminOrderStatusUpdateError():
return statusUpdateError(_that);case AdminOrdersWriteUnauthorized():
return writeUnauthorized(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( AdminOrdersLoading value)?  ordersLoading,TResult? Function( AdminOrdersSuccess value)?  ordersSuccess,TResult? Function( AdminOrdersError value)?  ordersError,TResult? Function( AdminOrderDetailsLoading value)?  orderDetailsLoading,TResult? Function( AdminOrderDetailsSuccess value)?  orderDetailsSuccess,TResult? Function( AdminOrderDetailsError value)?  orderDetailsError,TResult? Function( AdminOrderStatusUpdateLoading value)?  statusUpdateLoading,TResult? Function( AdminOrderStatusUpdateSuccess value)?  statusUpdateSuccess,TResult? Function( AdminOrderStatusUpdateError value)?  statusUpdateError,TResult? Function( AdminOrdersWriteUnauthorized value)?  writeUnauthorized,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case AdminOrdersLoading() when ordersLoading != null:
return ordersLoading(_that);case AdminOrdersSuccess() when ordersSuccess != null:
return ordersSuccess(_that);case AdminOrdersError() when ordersError != null:
return ordersError(_that);case AdminOrderDetailsLoading() when orderDetailsLoading != null:
return orderDetailsLoading(_that);case AdminOrderDetailsSuccess() when orderDetailsSuccess != null:
return orderDetailsSuccess(_that);case AdminOrderDetailsError() when orderDetailsError != null:
return orderDetailsError(_that);case AdminOrderStatusUpdateLoading() when statusUpdateLoading != null:
return statusUpdateLoading(_that);case AdminOrderStatusUpdateSuccess() when statusUpdateSuccess != null:
return statusUpdateSuccess(_that);case AdminOrderStatusUpdateError() when statusUpdateError != null:
return statusUpdateError(_that);case AdminOrdersWriteUnauthorized() when writeUnauthorized != null:
return writeUnauthorized(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  ordersLoading,TResult Function( List<OrderModel> orders,  Map<String, String> customerNames)?  ordersSuccess,TResult Function( ApiErrorModel apiErrorModel)?  ordersError,TResult Function()?  orderDetailsLoading,TResult Function( OrderModel order)?  orderDetailsSuccess,TResult Function( ApiErrorModel apiErrorModel)?  orderDetailsError,TResult Function()?  statusUpdateLoading,TResult Function( OrderModel updatedOrder,  String successMessage)?  statusUpdateSuccess,TResult Function( ApiErrorModel apiErrorModel)?  statusUpdateError,TResult Function( ApiErrorModel apiErrorModel)?  writeUnauthorized,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case AdminOrdersLoading() when ordersLoading != null:
return ordersLoading();case AdminOrdersSuccess() when ordersSuccess != null:
return ordersSuccess(_that.orders,_that.customerNames);case AdminOrdersError() when ordersError != null:
return ordersError(_that.apiErrorModel);case AdminOrderDetailsLoading() when orderDetailsLoading != null:
return orderDetailsLoading();case AdminOrderDetailsSuccess() when orderDetailsSuccess != null:
return orderDetailsSuccess(_that.order);case AdminOrderDetailsError() when orderDetailsError != null:
return orderDetailsError(_that.apiErrorModel);case AdminOrderStatusUpdateLoading() when statusUpdateLoading != null:
return statusUpdateLoading();case AdminOrderStatusUpdateSuccess() when statusUpdateSuccess != null:
return statusUpdateSuccess(_that.updatedOrder,_that.successMessage);case AdminOrderStatusUpdateError() when statusUpdateError != null:
return statusUpdateError(_that.apiErrorModel);case AdminOrdersWriteUnauthorized() when writeUnauthorized != null:
return writeUnauthorized(_that.apiErrorModel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  ordersLoading,required TResult Function( List<OrderModel> orders,  Map<String, String> customerNames)  ordersSuccess,required TResult Function( ApiErrorModel apiErrorModel)  ordersError,required TResult Function()  orderDetailsLoading,required TResult Function( OrderModel order)  orderDetailsSuccess,required TResult Function( ApiErrorModel apiErrorModel)  orderDetailsError,required TResult Function()  statusUpdateLoading,required TResult Function( OrderModel updatedOrder,  String successMessage)  statusUpdateSuccess,required TResult Function( ApiErrorModel apiErrorModel)  statusUpdateError,required TResult Function( ApiErrorModel apiErrorModel)  writeUnauthorized,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case AdminOrdersLoading():
return ordersLoading();case AdminOrdersSuccess():
return ordersSuccess(_that.orders,_that.customerNames);case AdminOrdersError():
return ordersError(_that.apiErrorModel);case AdminOrderDetailsLoading():
return orderDetailsLoading();case AdminOrderDetailsSuccess():
return orderDetailsSuccess(_that.order);case AdminOrderDetailsError():
return orderDetailsError(_that.apiErrorModel);case AdminOrderStatusUpdateLoading():
return statusUpdateLoading();case AdminOrderStatusUpdateSuccess():
return statusUpdateSuccess(_that.updatedOrder,_that.successMessage);case AdminOrderStatusUpdateError():
return statusUpdateError(_that.apiErrorModel);case AdminOrdersWriteUnauthorized():
return writeUnauthorized(_that.apiErrorModel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  ordersLoading,TResult? Function( List<OrderModel> orders,  Map<String, String> customerNames)?  ordersSuccess,TResult? Function( ApiErrorModel apiErrorModel)?  ordersError,TResult? Function()?  orderDetailsLoading,TResult? Function( OrderModel order)?  orderDetailsSuccess,TResult? Function( ApiErrorModel apiErrorModel)?  orderDetailsError,TResult? Function()?  statusUpdateLoading,TResult? Function( OrderModel updatedOrder,  String successMessage)?  statusUpdateSuccess,TResult? Function( ApiErrorModel apiErrorModel)?  statusUpdateError,TResult? Function( ApiErrorModel apiErrorModel)?  writeUnauthorized,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case AdminOrdersLoading() when ordersLoading != null:
return ordersLoading();case AdminOrdersSuccess() when ordersSuccess != null:
return ordersSuccess(_that.orders,_that.customerNames);case AdminOrdersError() when ordersError != null:
return ordersError(_that.apiErrorModel);case AdminOrderDetailsLoading() when orderDetailsLoading != null:
return orderDetailsLoading();case AdminOrderDetailsSuccess() when orderDetailsSuccess != null:
return orderDetailsSuccess(_that.order);case AdminOrderDetailsError() when orderDetailsError != null:
return orderDetailsError(_that.apiErrorModel);case AdminOrderStatusUpdateLoading() when statusUpdateLoading != null:
return statusUpdateLoading();case AdminOrderStatusUpdateSuccess() when statusUpdateSuccess != null:
return statusUpdateSuccess(_that.updatedOrder,_that.successMessage);case AdminOrderStatusUpdateError() when statusUpdateError != null:
return statusUpdateError(_that.apiErrorModel);case AdminOrdersWriteUnauthorized() when writeUnauthorized != null:
return writeUnauthorized(_that.apiErrorModel);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements AdminOrdersState {
  const _Initial();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AdminOrdersState.initial()';
}


}




/// @nodoc


class AdminOrdersLoading implements AdminOrdersState {
  const AdminOrdersLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminOrdersLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AdminOrdersState.ordersLoading()';
}


}




/// @nodoc


class AdminOrdersSuccess implements AdminOrdersState {
  const AdminOrdersSuccess( List<OrderModel> orders,  Map<String, String> customerNames): _orders = orders,_customerNames = customerNames;
  

 final  List<OrderModel> _orders;
 List<OrderModel> get orders {
  if (_orders is EqualUnmodifiableListView) return _orders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_orders);
}

 final  Map<String, String> _customerNames;
 Map<String, String> get customerNames {
  if (_customerNames is EqualUnmodifiableMapView) return _customerNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_customerNames);
}


/// Create a copy of AdminOrdersState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminOrdersSuccessCopyWith<AdminOrdersSuccess> get copyWith => _$AdminOrdersSuccessCopyWithImpl<AdminOrdersSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminOrdersSuccess&&const DeepCollectionEquality().equals(other.orders, _orders)&&const DeepCollectionEquality().equals(other.customerNames, _customerNames));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_orders),const DeepCollectionEquality().hash(_customerNames));
}

@override
String toString() {
    return 'AdminOrdersState.ordersSuccess(orders: $orders, customerNames: $customerNames)';
}


}

/// @nodoc
abstract mixin class $AdminOrdersSuccessCopyWith<$Res> implements $AdminOrdersStateCopyWith<$Res> {
  factory $AdminOrdersSuccessCopyWith(AdminOrdersSuccess value, $Res Function(AdminOrdersSuccess) _then) = _$AdminOrdersSuccessCopyWithImpl;
@useResult
$Res call({
 List<OrderModel> orders, Map<String, String> customerNames
});




}
/// @nodoc
class _$AdminOrdersSuccessCopyWithImpl<$Res>
    implements $AdminOrdersSuccessCopyWith<$Res> {
  _$AdminOrdersSuccessCopyWithImpl(this._self, this._then);

  final AdminOrdersSuccess _self;
  final $Res Function(AdminOrdersSuccess) _then;

/// Create a copy of AdminOrdersState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? orders = null,Object? customerNames = null,}) {
  return _then(AdminOrdersSuccess(
null == orders ? _self._orders : orders // ignore: cast_nullable_to_non_nullable
as List<OrderModel>,null == customerNames ? _self._customerNames : customerNames // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

/// @nodoc


class AdminOrdersError implements AdminOrdersState {
  const AdminOrdersError(this.apiErrorModel);
  

 final  ApiErrorModel apiErrorModel;

/// Create a copy of AdminOrdersState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminOrdersErrorCopyWith<AdminOrdersError> get copyWith => _$AdminOrdersErrorCopyWithImpl<AdminOrdersError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminOrdersError&&(identical(other.apiErrorModel, apiErrorModel) || other.apiErrorModel == apiErrorModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,apiErrorModel);
}

@override
String toString() {
    return 'AdminOrdersState.ordersError(apiErrorModel: $apiErrorModel)';
}


}

/// @nodoc
abstract mixin class $AdminOrdersErrorCopyWith<$Res> implements $AdminOrdersStateCopyWith<$Res> {
  factory $AdminOrdersErrorCopyWith(AdminOrdersError value, $Res Function(AdminOrdersError) _then) = _$AdminOrdersErrorCopyWithImpl;
@useResult
$Res call({
 ApiErrorModel apiErrorModel
});




}
/// @nodoc
class _$AdminOrdersErrorCopyWithImpl<$Res>
    implements $AdminOrdersErrorCopyWith<$Res> {
  _$AdminOrdersErrorCopyWithImpl(this._self, this._then);

  final AdminOrdersError _self;
  final $Res Function(AdminOrdersError) _then;

/// Create a copy of AdminOrdersState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? apiErrorModel = null,}) {
  return _then(AdminOrdersError(
null == apiErrorModel ? _self.apiErrorModel : apiErrorModel // ignore: cast_nullable_to_non_nullable
as ApiErrorModel,
  ));
}


}

/// @nodoc


class AdminOrderDetailsLoading implements AdminOrdersState {
  const AdminOrderDetailsLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminOrderDetailsLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AdminOrdersState.orderDetailsLoading()';
}


}




/// @nodoc


class AdminOrderDetailsSuccess implements AdminOrdersState {
  const AdminOrderDetailsSuccess(this.order);
  

 final  OrderModel order;

/// Create a copy of AdminOrdersState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminOrderDetailsSuccessCopyWith<AdminOrderDetailsSuccess> get copyWith => _$AdminOrderDetailsSuccessCopyWithImpl<AdminOrderDetailsSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminOrderDetailsSuccess&&(identical(other.order, order) || other.order == order));
}


@override
int get hashCode {
    return Object.hash(runtimeType,order);
}

@override
String toString() {
    return 'AdminOrdersState.orderDetailsSuccess(order: $order)';
}


}

/// @nodoc
abstract mixin class $AdminOrderDetailsSuccessCopyWith<$Res> implements $AdminOrdersStateCopyWith<$Res> {
  factory $AdminOrderDetailsSuccessCopyWith(AdminOrderDetailsSuccess value, $Res Function(AdminOrderDetailsSuccess) _then) = _$AdminOrderDetailsSuccessCopyWithImpl;
@useResult
$Res call({
 OrderModel order
});




}
/// @nodoc
class _$AdminOrderDetailsSuccessCopyWithImpl<$Res>
    implements $AdminOrderDetailsSuccessCopyWith<$Res> {
  _$AdminOrderDetailsSuccessCopyWithImpl(this._self, this._then);

  final AdminOrderDetailsSuccess _self;
  final $Res Function(AdminOrderDetailsSuccess) _then;

/// Create a copy of AdminOrdersState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? order = null,}) {
  return _then(AdminOrderDetailsSuccess(
null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as OrderModel,
  ));
}


}

/// @nodoc


class AdminOrderDetailsError implements AdminOrdersState {
  const AdminOrderDetailsError(this.apiErrorModel);
  

 final  ApiErrorModel apiErrorModel;

/// Create a copy of AdminOrdersState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminOrderDetailsErrorCopyWith<AdminOrderDetailsError> get copyWith => _$AdminOrderDetailsErrorCopyWithImpl<AdminOrderDetailsError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminOrderDetailsError&&(identical(other.apiErrorModel, apiErrorModel) || other.apiErrorModel == apiErrorModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,apiErrorModel);
}

@override
String toString() {
    return 'AdminOrdersState.orderDetailsError(apiErrorModel: $apiErrorModel)';
}


}

/// @nodoc
abstract mixin class $AdminOrderDetailsErrorCopyWith<$Res> implements $AdminOrdersStateCopyWith<$Res> {
  factory $AdminOrderDetailsErrorCopyWith(AdminOrderDetailsError value, $Res Function(AdminOrderDetailsError) _then) = _$AdminOrderDetailsErrorCopyWithImpl;
@useResult
$Res call({
 ApiErrorModel apiErrorModel
});




}
/// @nodoc
class _$AdminOrderDetailsErrorCopyWithImpl<$Res>
    implements $AdminOrderDetailsErrorCopyWith<$Res> {
  _$AdminOrderDetailsErrorCopyWithImpl(this._self, this._then);

  final AdminOrderDetailsError _self;
  final $Res Function(AdminOrderDetailsError) _then;

/// Create a copy of AdminOrdersState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? apiErrorModel = null,}) {
  return _then(AdminOrderDetailsError(
null == apiErrorModel ? _self.apiErrorModel : apiErrorModel // ignore: cast_nullable_to_non_nullable
as ApiErrorModel,
  ));
}


}

/// @nodoc


class AdminOrderStatusUpdateLoading implements AdminOrdersState {
  const AdminOrderStatusUpdateLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminOrderStatusUpdateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AdminOrdersState.statusUpdateLoading()';
}


}




/// @nodoc


class AdminOrderStatusUpdateSuccess implements AdminOrdersState {
  const AdminOrderStatusUpdateSuccess(this.updatedOrder, this.successMessage);
  

 final  OrderModel updatedOrder;
 final  String successMessage;

/// Create a copy of AdminOrdersState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminOrderStatusUpdateSuccessCopyWith<AdminOrderStatusUpdateSuccess> get copyWith => _$AdminOrderStatusUpdateSuccessCopyWithImpl<AdminOrderStatusUpdateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminOrderStatusUpdateSuccess&&(identical(other.updatedOrder, updatedOrder) || other.updatedOrder == updatedOrder)&&(identical(other.successMessage, successMessage) || other.successMessage == successMessage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,updatedOrder,successMessage);
}

@override
String toString() {
    return 'AdminOrdersState.statusUpdateSuccess(updatedOrder: $updatedOrder, successMessage: $successMessage)';
}


}

/// @nodoc
abstract mixin class $AdminOrderStatusUpdateSuccessCopyWith<$Res> implements $AdminOrdersStateCopyWith<$Res> {
  factory $AdminOrderStatusUpdateSuccessCopyWith(AdminOrderStatusUpdateSuccess value, $Res Function(AdminOrderStatusUpdateSuccess) _then) = _$AdminOrderStatusUpdateSuccessCopyWithImpl;
@useResult
$Res call({
 OrderModel updatedOrder, String successMessage
});




}
/// @nodoc
class _$AdminOrderStatusUpdateSuccessCopyWithImpl<$Res>
    implements $AdminOrderStatusUpdateSuccessCopyWith<$Res> {
  _$AdminOrderStatusUpdateSuccessCopyWithImpl(this._self, this._then);

  final AdminOrderStatusUpdateSuccess _self;
  final $Res Function(AdminOrderStatusUpdateSuccess) _then;

/// Create a copy of AdminOrdersState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? updatedOrder = null,Object? successMessage = null,}) {
  return _then(AdminOrderStatusUpdateSuccess(
null == updatedOrder ? _self.updatedOrder : updatedOrder // ignore: cast_nullable_to_non_nullable
as OrderModel,null == successMessage ? _self.successMessage : successMessage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AdminOrderStatusUpdateError implements AdminOrdersState {
  const AdminOrderStatusUpdateError(this.apiErrorModel);
  

 final  ApiErrorModel apiErrorModel;

/// Create a copy of AdminOrdersState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminOrderStatusUpdateErrorCopyWith<AdminOrderStatusUpdateError> get copyWith => _$AdminOrderStatusUpdateErrorCopyWithImpl<AdminOrderStatusUpdateError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminOrderStatusUpdateError&&(identical(other.apiErrorModel, apiErrorModel) || other.apiErrorModel == apiErrorModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,apiErrorModel);
}

@override
String toString() {
    return 'AdminOrdersState.statusUpdateError(apiErrorModel: $apiErrorModel)';
}


}

/// @nodoc
abstract mixin class $AdminOrderStatusUpdateErrorCopyWith<$Res> implements $AdminOrdersStateCopyWith<$Res> {
  factory $AdminOrderStatusUpdateErrorCopyWith(AdminOrderStatusUpdateError value, $Res Function(AdminOrderStatusUpdateError) _then) = _$AdminOrderStatusUpdateErrorCopyWithImpl;
@useResult
$Res call({
 ApiErrorModel apiErrorModel
});




}
/// @nodoc
class _$AdminOrderStatusUpdateErrorCopyWithImpl<$Res>
    implements $AdminOrderStatusUpdateErrorCopyWith<$Res> {
  _$AdminOrderStatusUpdateErrorCopyWithImpl(this._self, this._then);

  final AdminOrderStatusUpdateError _self;
  final $Res Function(AdminOrderStatusUpdateError) _then;

/// Create a copy of AdminOrdersState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? apiErrorModel = null,}) {
  return _then(AdminOrderStatusUpdateError(
null == apiErrorModel ? _self.apiErrorModel : apiErrorModel // ignore: cast_nullable_to_non_nullable
as ApiErrorModel,
  ));
}


}

/// @nodoc


class AdminOrdersWriteUnauthorized implements AdminOrdersState {
  const AdminOrdersWriteUnauthorized(this.apiErrorModel);
  

 final  ApiErrorModel apiErrorModel;

/// Create a copy of AdminOrdersState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminOrdersWriteUnauthorizedCopyWith<AdminOrdersWriteUnauthorized> get copyWith => _$AdminOrdersWriteUnauthorizedCopyWithImpl<AdminOrdersWriteUnauthorized>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminOrdersWriteUnauthorized&&(identical(other.apiErrorModel, apiErrorModel) || other.apiErrorModel == apiErrorModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,apiErrorModel);
}

@override
String toString() {
    return 'AdminOrdersState.writeUnauthorized(apiErrorModel: $apiErrorModel)';
}


}

/// @nodoc
abstract mixin class $AdminOrdersWriteUnauthorizedCopyWith<$Res> implements $AdminOrdersStateCopyWith<$Res> {
  factory $AdminOrdersWriteUnauthorizedCopyWith(AdminOrdersWriteUnauthorized value, $Res Function(AdminOrdersWriteUnauthorized) _then) = _$AdminOrdersWriteUnauthorizedCopyWithImpl;
@useResult
$Res call({
 ApiErrorModel apiErrorModel
});




}
/// @nodoc
class _$AdminOrdersWriteUnauthorizedCopyWithImpl<$Res>
    implements $AdminOrdersWriteUnauthorizedCopyWith<$Res> {
  _$AdminOrdersWriteUnauthorizedCopyWithImpl(this._self, this._then);

  final AdminOrdersWriteUnauthorized _self;
  final $Res Function(AdminOrdersWriteUnauthorized) _then;

/// Create a copy of AdminOrdersState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? apiErrorModel = null,}) {
  return _then(AdminOrdersWriteUnauthorized(
null == apiErrorModel ? _self.apiErrorModel : apiErrorModel // ignore: cast_nullable_to_non_nullable
as ApiErrorModel,
  ));
}


}

// dart format on
