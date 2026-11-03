// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_products_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AdminProductsState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminProductsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AdminProductsState()';
}


}

/// @nodoc
class $AdminProductsStateCopyWith<$Res>  {
$AdminProductsStateCopyWith(AdminProductsState _, $Res Function(AdminProductsState) __);
}


/// Adds pattern-matching-related methods to [AdminProductsState].
extension AdminProductsStatePatterns on AdminProductsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( AdminProductsLoading value)?  productsLoading,TResult Function( AdminProductsSuccess value)?  productsSuccess,TResult Function( AdminProductsError value)?  productsError,TResult Function( AdminProductSubmitLoading value)?  submitLoading,TResult Function( AdminProductSubmitSuccess value)?  submitSuccess,TResult Function( AdminProductSubmitError value)?  submitError,TResult Function( AdminProductDeleteLoading value)?  deleteLoading,TResult Function( AdminProductDeleteSuccess value)?  deleteSuccess,TResult Function( AdminProductDeleteError value)?  deleteError,TResult Function( AdminProductsWriteUnauthorized value)?  writeUnauthorized,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case AdminProductsLoading() when productsLoading != null:
return productsLoading(_that);case AdminProductsSuccess() when productsSuccess != null:
return productsSuccess(_that);case AdminProductsError() when productsError != null:
return productsError(_that);case AdminProductSubmitLoading() when submitLoading != null:
return submitLoading(_that);case AdminProductSubmitSuccess() when submitSuccess != null:
return submitSuccess(_that);case AdminProductSubmitError() when submitError != null:
return submitError(_that);case AdminProductDeleteLoading() when deleteLoading != null:
return deleteLoading(_that);case AdminProductDeleteSuccess() when deleteSuccess != null:
return deleteSuccess(_that);case AdminProductDeleteError() when deleteError != null:
return deleteError(_that);case AdminProductsWriteUnauthorized() when writeUnauthorized != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( AdminProductsLoading value)  productsLoading,required TResult Function( AdminProductsSuccess value)  productsSuccess,required TResult Function( AdminProductsError value)  productsError,required TResult Function( AdminProductSubmitLoading value)  submitLoading,required TResult Function( AdminProductSubmitSuccess value)  submitSuccess,required TResult Function( AdminProductSubmitError value)  submitError,required TResult Function( AdminProductDeleteLoading value)  deleteLoading,required TResult Function( AdminProductDeleteSuccess value)  deleteSuccess,required TResult Function( AdminProductDeleteError value)  deleteError,required TResult Function( AdminProductsWriteUnauthorized value)  writeUnauthorized,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case AdminProductsLoading():
return productsLoading(_that);case AdminProductsSuccess():
return productsSuccess(_that);case AdminProductsError():
return productsError(_that);case AdminProductSubmitLoading():
return submitLoading(_that);case AdminProductSubmitSuccess():
return submitSuccess(_that);case AdminProductSubmitError():
return submitError(_that);case AdminProductDeleteLoading():
return deleteLoading(_that);case AdminProductDeleteSuccess():
return deleteSuccess(_that);case AdminProductDeleteError():
return deleteError(_that);case AdminProductsWriteUnauthorized():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( AdminProductsLoading value)?  productsLoading,TResult? Function( AdminProductsSuccess value)?  productsSuccess,TResult? Function( AdminProductsError value)?  productsError,TResult? Function( AdminProductSubmitLoading value)?  submitLoading,TResult? Function( AdminProductSubmitSuccess value)?  submitSuccess,TResult? Function( AdminProductSubmitError value)?  submitError,TResult? Function( AdminProductDeleteLoading value)?  deleteLoading,TResult? Function( AdminProductDeleteSuccess value)?  deleteSuccess,TResult? Function( AdminProductDeleteError value)?  deleteError,TResult? Function( AdminProductsWriteUnauthorized value)?  writeUnauthorized,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case AdminProductsLoading() when productsLoading != null:
return productsLoading(_that);case AdminProductsSuccess() when productsSuccess != null:
return productsSuccess(_that);case AdminProductsError() when productsError != null:
return productsError(_that);case AdminProductSubmitLoading() when submitLoading != null:
return submitLoading(_that);case AdminProductSubmitSuccess() when submitSuccess != null:
return submitSuccess(_that);case AdminProductSubmitError() when submitError != null:
return submitError(_that);case AdminProductDeleteLoading() when deleteLoading != null:
return deleteLoading(_that);case AdminProductDeleteSuccess() when deleteSuccess != null:
return deleteSuccess(_that);case AdminProductDeleteError() when deleteError != null:
return deleteError(_that);case AdminProductsWriteUnauthorized() when writeUnauthorized != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  productsLoading,TResult Function( List<AdminProductEntry> entries)?  productsSuccess,TResult Function( ApiErrorModel apiErrorModel)?  productsError,TResult Function()?  submitLoading,TResult Function( String successMessage)?  submitSuccess,TResult Function( ApiErrorModel apiErrorModel)?  submitError,TResult Function()?  deleteLoading,TResult Function( String successMessage)?  deleteSuccess,TResult Function( ApiErrorModel apiErrorModel)?  deleteError,TResult Function( ApiErrorModel apiErrorModel)?  writeUnauthorized,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case AdminProductsLoading() when productsLoading != null:
return productsLoading();case AdminProductsSuccess() when productsSuccess != null:
return productsSuccess(_that.entries);case AdminProductsError() when productsError != null:
return productsError(_that.apiErrorModel);case AdminProductSubmitLoading() when submitLoading != null:
return submitLoading();case AdminProductSubmitSuccess() when submitSuccess != null:
return submitSuccess(_that.successMessage);case AdminProductSubmitError() when submitError != null:
return submitError(_that.apiErrorModel);case AdminProductDeleteLoading() when deleteLoading != null:
return deleteLoading();case AdminProductDeleteSuccess() when deleteSuccess != null:
return deleteSuccess(_that.successMessage);case AdminProductDeleteError() when deleteError != null:
return deleteError(_that.apiErrorModel);case AdminProductsWriteUnauthorized() when writeUnauthorized != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  productsLoading,required TResult Function( List<AdminProductEntry> entries)  productsSuccess,required TResult Function( ApiErrorModel apiErrorModel)  productsError,required TResult Function()  submitLoading,required TResult Function( String successMessage)  submitSuccess,required TResult Function( ApiErrorModel apiErrorModel)  submitError,required TResult Function()  deleteLoading,required TResult Function( String successMessage)  deleteSuccess,required TResult Function( ApiErrorModel apiErrorModel)  deleteError,required TResult Function( ApiErrorModel apiErrorModel)  writeUnauthorized,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case AdminProductsLoading():
return productsLoading();case AdminProductsSuccess():
return productsSuccess(_that.entries);case AdminProductsError():
return productsError(_that.apiErrorModel);case AdminProductSubmitLoading():
return submitLoading();case AdminProductSubmitSuccess():
return submitSuccess(_that.successMessage);case AdminProductSubmitError():
return submitError(_that.apiErrorModel);case AdminProductDeleteLoading():
return deleteLoading();case AdminProductDeleteSuccess():
return deleteSuccess(_that.successMessage);case AdminProductDeleteError():
return deleteError(_that.apiErrorModel);case AdminProductsWriteUnauthorized():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  productsLoading,TResult? Function( List<AdminProductEntry> entries)?  productsSuccess,TResult? Function( ApiErrorModel apiErrorModel)?  productsError,TResult? Function()?  submitLoading,TResult? Function( String successMessage)?  submitSuccess,TResult? Function( ApiErrorModel apiErrorModel)?  submitError,TResult? Function()?  deleteLoading,TResult? Function( String successMessage)?  deleteSuccess,TResult? Function( ApiErrorModel apiErrorModel)?  deleteError,TResult? Function( ApiErrorModel apiErrorModel)?  writeUnauthorized,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case AdminProductsLoading() when productsLoading != null:
return productsLoading();case AdminProductsSuccess() when productsSuccess != null:
return productsSuccess(_that.entries);case AdminProductsError() when productsError != null:
return productsError(_that.apiErrorModel);case AdminProductSubmitLoading() when submitLoading != null:
return submitLoading();case AdminProductSubmitSuccess() when submitSuccess != null:
return submitSuccess(_that.successMessage);case AdminProductSubmitError() when submitError != null:
return submitError(_that.apiErrorModel);case AdminProductDeleteLoading() when deleteLoading != null:
return deleteLoading();case AdminProductDeleteSuccess() when deleteSuccess != null:
return deleteSuccess(_that.successMessage);case AdminProductDeleteError() when deleteError != null:
return deleteError(_that.apiErrorModel);case AdminProductsWriteUnauthorized() when writeUnauthorized != null:
return writeUnauthorized(_that.apiErrorModel);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements AdminProductsState {
  const _Initial();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AdminProductsState.initial()';
}


}




/// @nodoc


class AdminProductsLoading implements AdminProductsState {
  const AdminProductsLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminProductsLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AdminProductsState.productsLoading()';
}


}




/// @nodoc


class AdminProductsSuccess implements AdminProductsState {
  const AdminProductsSuccess( List<AdminProductEntry> entries): _entries = entries;
  

 final  List<AdminProductEntry> _entries;
 List<AdminProductEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


/// Create a copy of AdminProductsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminProductsSuccessCopyWith<AdminProductsSuccess> get copyWith => _$AdminProductsSuccessCopyWithImpl<AdminProductsSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminProductsSuccess&&const DeepCollectionEquality().equals(other.entries, _entries));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_entries));
}

@override
String toString() {
    return 'AdminProductsState.productsSuccess(entries: $entries)';
}


}

/// @nodoc
abstract mixin class $AdminProductsSuccessCopyWith<$Res> implements $AdminProductsStateCopyWith<$Res> {
  factory $AdminProductsSuccessCopyWith(AdminProductsSuccess value, $Res Function(AdminProductsSuccess) _then) = _$AdminProductsSuccessCopyWithImpl;
@useResult
$Res call({
 List<AdminProductEntry> entries
});




}
/// @nodoc
class _$AdminProductsSuccessCopyWithImpl<$Res>
    implements $AdminProductsSuccessCopyWith<$Res> {
  _$AdminProductsSuccessCopyWithImpl(this._self, this._then);

  final AdminProductsSuccess _self;
  final $Res Function(AdminProductsSuccess) _then;

/// Create a copy of AdminProductsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? entries = null,}) {
  return _then(AdminProductsSuccess(
null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<AdminProductEntry>,
  ));
}


}

/// @nodoc


class AdminProductsError implements AdminProductsState {
  const AdminProductsError(this.apiErrorModel);
  

 final  ApiErrorModel apiErrorModel;

/// Create a copy of AdminProductsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminProductsErrorCopyWith<AdminProductsError> get copyWith => _$AdminProductsErrorCopyWithImpl<AdminProductsError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminProductsError&&(identical(other.apiErrorModel, apiErrorModel) || other.apiErrorModel == apiErrorModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,apiErrorModel);
}

@override
String toString() {
    return 'AdminProductsState.productsError(apiErrorModel: $apiErrorModel)';
}


}

/// @nodoc
abstract mixin class $AdminProductsErrorCopyWith<$Res> implements $AdminProductsStateCopyWith<$Res> {
  factory $AdminProductsErrorCopyWith(AdminProductsError value, $Res Function(AdminProductsError) _then) = _$AdminProductsErrorCopyWithImpl;
@useResult
$Res call({
 ApiErrorModel apiErrorModel
});




}
/// @nodoc
class _$AdminProductsErrorCopyWithImpl<$Res>
    implements $AdminProductsErrorCopyWith<$Res> {
  _$AdminProductsErrorCopyWithImpl(this._self, this._then);

  final AdminProductsError _self;
  final $Res Function(AdminProductsError) _then;

/// Create a copy of AdminProductsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? apiErrorModel = null,}) {
  return _then(AdminProductsError(
null == apiErrorModel ? _self.apiErrorModel : apiErrorModel // ignore: cast_nullable_to_non_nullable
as ApiErrorModel,
  ));
}


}

/// @nodoc


class AdminProductSubmitLoading implements AdminProductsState {
  const AdminProductSubmitLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminProductSubmitLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AdminProductsState.submitLoading()';
}


}




/// @nodoc


class AdminProductSubmitSuccess implements AdminProductsState {
  const AdminProductSubmitSuccess(this.successMessage);
  

 final  String successMessage;

/// Create a copy of AdminProductsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminProductSubmitSuccessCopyWith<AdminProductSubmitSuccess> get copyWith => _$AdminProductSubmitSuccessCopyWithImpl<AdminProductSubmitSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminProductSubmitSuccess&&(identical(other.successMessage, successMessage) || other.successMessage == successMessage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,successMessage);
}

@override
String toString() {
    return 'AdminProductsState.submitSuccess(successMessage: $successMessage)';
}


}

/// @nodoc
abstract mixin class $AdminProductSubmitSuccessCopyWith<$Res> implements $AdminProductsStateCopyWith<$Res> {
  factory $AdminProductSubmitSuccessCopyWith(AdminProductSubmitSuccess value, $Res Function(AdminProductSubmitSuccess) _then) = _$AdminProductSubmitSuccessCopyWithImpl;
@useResult
$Res call({
 String successMessage
});




}
/// @nodoc
class _$AdminProductSubmitSuccessCopyWithImpl<$Res>
    implements $AdminProductSubmitSuccessCopyWith<$Res> {
  _$AdminProductSubmitSuccessCopyWithImpl(this._self, this._then);

  final AdminProductSubmitSuccess _self;
  final $Res Function(AdminProductSubmitSuccess) _then;

/// Create a copy of AdminProductsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? successMessage = null,}) {
  return _then(AdminProductSubmitSuccess(
null == successMessage ? _self.successMessage : successMessage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AdminProductSubmitError implements AdminProductsState {
  const AdminProductSubmitError(this.apiErrorModel);
  

 final  ApiErrorModel apiErrorModel;

/// Create a copy of AdminProductsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminProductSubmitErrorCopyWith<AdminProductSubmitError> get copyWith => _$AdminProductSubmitErrorCopyWithImpl<AdminProductSubmitError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminProductSubmitError&&(identical(other.apiErrorModel, apiErrorModel) || other.apiErrorModel == apiErrorModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,apiErrorModel);
}

@override
String toString() {
    return 'AdminProductsState.submitError(apiErrorModel: $apiErrorModel)';
}


}

/// @nodoc
abstract mixin class $AdminProductSubmitErrorCopyWith<$Res> implements $AdminProductsStateCopyWith<$Res> {
  factory $AdminProductSubmitErrorCopyWith(AdminProductSubmitError value, $Res Function(AdminProductSubmitError) _then) = _$AdminProductSubmitErrorCopyWithImpl;
@useResult
$Res call({
 ApiErrorModel apiErrorModel
});




}
/// @nodoc
class _$AdminProductSubmitErrorCopyWithImpl<$Res>
    implements $AdminProductSubmitErrorCopyWith<$Res> {
  _$AdminProductSubmitErrorCopyWithImpl(this._self, this._then);

  final AdminProductSubmitError _self;
  final $Res Function(AdminProductSubmitError) _then;

/// Create a copy of AdminProductsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? apiErrorModel = null,}) {
  return _then(AdminProductSubmitError(
null == apiErrorModel ? _self.apiErrorModel : apiErrorModel // ignore: cast_nullable_to_non_nullable
as ApiErrorModel,
  ));
}


}

/// @nodoc


class AdminProductDeleteLoading implements AdminProductsState {
  const AdminProductDeleteLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminProductDeleteLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AdminProductsState.deleteLoading()';
}


}




/// @nodoc


class AdminProductDeleteSuccess implements AdminProductsState {
  const AdminProductDeleteSuccess(this.successMessage);
  

 final  String successMessage;

/// Create a copy of AdminProductsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminProductDeleteSuccessCopyWith<AdminProductDeleteSuccess> get copyWith => _$AdminProductDeleteSuccessCopyWithImpl<AdminProductDeleteSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminProductDeleteSuccess&&(identical(other.successMessage, successMessage) || other.successMessage == successMessage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,successMessage);
}

@override
String toString() {
    return 'AdminProductsState.deleteSuccess(successMessage: $successMessage)';
}


}

/// @nodoc
abstract mixin class $AdminProductDeleteSuccessCopyWith<$Res> implements $AdminProductsStateCopyWith<$Res> {
  factory $AdminProductDeleteSuccessCopyWith(AdminProductDeleteSuccess value, $Res Function(AdminProductDeleteSuccess) _then) = _$AdminProductDeleteSuccessCopyWithImpl;
@useResult
$Res call({
 String successMessage
});




}
/// @nodoc
class _$AdminProductDeleteSuccessCopyWithImpl<$Res>
    implements $AdminProductDeleteSuccessCopyWith<$Res> {
  _$AdminProductDeleteSuccessCopyWithImpl(this._self, this._then);

  final AdminProductDeleteSuccess _self;
  final $Res Function(AdminProductDeleteSuccess) _then;

/// Create a copy of AdminProductsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? successMessage = null,}) {
  return _then(AdminProductDeleteSuccess(
null == successMessage ? _self.successMessage : successMessage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AdminProductDeleteError implements AdminProductsState {
  const AdminProductDeleteError(this.apiErrorModel);
  

 final  ApiErrorModel apiErrorModel;

/// Create a copy of AdminProductsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminProductDeleteErrorCopyWith<AdminProductDeleteError> get copyWith => _$AdminProductDeleteErrorCopyWithImpl<AdminProductDeleteError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminProductDeleteError&&(identical(other.apiErrorModel, apiErrorModel) || other.apiErrorModel == apiErrorModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,apiErrorModel);
}

@override
String toString() {
    return 'AdminProductsState.deleteError(apiErrorModel: $apiErrorModel)';
}


}

/// @nodoc
abstract mixin class $AdminProductDeleteErrorCopyWith<$Res> implements $AdminProductsStateCopyWith<$Res> {
  factory $AdminProductDeleteErrorCopyWith(AdminProductDeleteError value, $Res Function(AdminProductDeleteError) _then) = _$AdminProductDeleteErrorCopyWithImpl;
@useResult
$Res call({
 ApiErrorModel apiErrorModel
});




}
/// @nodoc
class _$AdminProductDeleteErrorCopyWithImpl<$Res>
    implements $AdminProductDeleteErrorCopyWith<$Res> {
  _$AdminProductDeleteErrorCopyWithImpl(this._self, this._then);

  final AdminProductDeleteError _self;
  final $Res Function(AdminProductDeleteError) _then;

/// Create a copy of AdminProductsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? apiErrorModel = null,}) {
  return _then(AdminProductDeleteError(
null == apiErrorModel ? _self.apiErrorModel : apiErrorModel // ignore: cast_nullable_to_non_nullable
as ApiErrorModel,
  ));
}


}

/// @nodoc


class AdminProductsWriteUnauthorized implements AdminProductsState {
  const AdminProductsWriteUnauthorized(this.apiErrorModel);
  

 final  ApiErrorModel apiErrorModel;

/// Create a copy of AdminProductsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminProductsWriteUnauthorizedCopyWith<AdminProductsWriteUnauthorized> get copyWith => _$AdminProductsWriteUnauthorizedCopyWithImpl<AdminProductsWriteUnauthorized>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminProductsWriteUnauthorized&&(identical(other.apiErrorModel, apiErrorModel) || other.apiErrorModel == apiErrorModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,apiErrorModel);
}

@override
String toString() {
    return 'AdminProductsState.writeUnauthorized(apiErrorModel: $apiErrorModel)';
}


}

/// @nodoc
abstract mixin class $AdminProductsWriteUnauthorizedCopyWith<$Res> implements $AdminProductsStateCopyWith<$Res> {
  factory $AdminProductsWriteUnauthorizedCopyWith(AdminProductsWriteUnauthorized value, $Res Function(AdminProductsWriteUnauthorized) _then) = _$AdminProductsWriteUnauthorizedCopyWithImpl;
@useResult
$Res call({
 ApiErrorModel apiErrorModel
});




}
/// @nodoc
class _$AdminProductsWriteUnauthorizedCopyWithImpl<$Res>
    implements $AdminProductsWriteUnauthorizedCopyWith<$Res> {
  _$AdminProductsWriteUnauthorizedCopyWithImpl(this._self, this._then);

  final AdminProductsWriteUnauthorized _self;
  final $Res Function(AdminProductsWriteUnauthorized) _then;

/// Create a copy of AdminProductsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? apiErrorModel = null,}) {
  return _then(AdminProductsWriteUnauthorized(
null == apiErrorModel ? _self.apiErrorModel : apiErrorModel // ignore: cast_nullable_to_non_nullable
as ApiErrorModel,
  ));
}


}

// dart format on
