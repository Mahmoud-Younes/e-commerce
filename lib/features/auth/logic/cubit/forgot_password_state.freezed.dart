// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'forgot_password_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ForgotPasswordState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ForgotPasswordState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ForgotPasswordState()';
}


}

/// @nodoc
class $ForgotPasswordStateCopyWith<$Res>  {
$ForgotPasswordStateCopyWith(ForgotPasswordState _, $Res Function(ForgotPasswordState) __);
}


/// Adds pattern-matching-related methods to [ForgotPasswordState].
extension ForgotPasswordStatePatterns on ForgotPasswordState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( ForgotPasswordLoading value)?  forgotPasswordLoading,TResult Function( ForgotPasswordSuccess value)?  forgotPasswordSuccess,TResult Function( ForgotPasswordError value)?  forgotPasswordError,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case ForgotPasswordLoading() when forgotPasswordLoading != null:
return forgotPasswordLoading(_that);case ForgotPasswordSuccess() when forgotPasswordSuccess != null:
return forgotPasswordSuccess(_that);case ForgotPasswordError() when forgotPasswordError != null:
return forgotPasswordError(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( ForgotPasswordLoading value)  forgotPasswordLoading,required TResult Function( ForgotPasswordSuccess value)  forgotPasswordSuccess,required TResult Function( ForgotPasswordError value)  forgotPasswordError,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case ForgotPasswordLoading():
return forgotPasswordLoading(_that);case ForgotPasswordSuccess():
return forgotPasswordSuccess(_that);case ForgotPasswordError():
return forgotPasswordError(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( ForgotPasswordLoading value)?  forgotPasswordLoading,TResult? Function( ForgotPasswordSuccess value)?  forgotPasswordSuccess,TResult? Function( ForgotPasswordError value)?  forgotPasswordError,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case ForgotPasswordLoading() when forgotPasswordLoading != null:
return forgotPasswordLoading(_that);case ForgotPasswordSuccess() when forgotPasswordSuccess != null:
return forgotPasswordSuccess(_that);case ForgotPasswordError() when forgotPasswordError != null:
return forgotPasswordError(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  forgotPasswordLoading,TResult Function( String successMessage)?  forgotPasswordSuccess,TResult Function( ApiErrorModel apiErrorModel)?  forgotPasswordError,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case ForgotPasswordLoading() when forgotPasswordLoading != null:
return forgotPasswordLoading();case ForgotPasswordSuccess() when forgotPasswordSuccess != null:
return forgotPasswordSuccess(_that.successMessage);case ForgotPasswordError() when forgotPasswordError != null:
return forgotPasswordError(_that.apiErrorModel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  forgotPasswordLoading,required TResult Function( String successMessage)  forgotPasswordSuccess,required TResult Function( ApiErrorModel apiErrorModel)  forgotPasswordError,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case ForgotPasswordLoading():
return forgotPasswordLoading();case ForgotPasswordSuccess():
return forgotPasswordSuccess(_that.successMessage);case ForgotPasswordError():
return forgotPasswordError(_that.apiErrorModel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  forgotPasswordLoading,TResult? Function( String successMessage)?  forgotPasswordSuccess,TResult? Function( ApiErrorModel apiErrorModel)?  forgotPasswordError,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case ForgotPasswordLoading() when forgotPasswordLoading != null:
return forgotPasswordLoading();case ForgotPasswordSuccess() when forgotPasswordSuccess != null:
return forgotPasswordSuccess(_that.successMessage);case ForgotPasswordError() when forgotPasswordError != null:
return forgotPasswordError(_that.apiErrorModel);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements ForgotPasswordState {
  const _Initial();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ForgotPasswordState.initial()';
}


}




/// @nodoc


class ForgotPasswordLoading implements ForgotPasswordState {
  const ForgotPasswordLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ForgotPasswordLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ForgotPasswordState.forgotPasswordLoading()';
}


}




/// @nodoc


class ForgotPasswordSuccess implements ForgotPasswordState {
  const ForgotPasswordSuccess(this.successMessage);
  

 final  String successMessage;

/// Create a copy of ForgotPasswordState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForgotPasswordSuccessCopyWith<ForgotPasswordSuccess> get copyWith => _$ForgotPasswordSuccessCopyWithImpl<ForgotPasswordSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ForgotPasswordSuccess&&(identical(other.successMessage, successMessage) || other.successMessage == successMessage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,successMessage);
}

@override
String toString() {
    return 'ForgotPasswordState.forgotPasswordSuccess(successMessage: $successMessage)';
}


}

/// @nodoc
abstract mixin class $ForgotPasswordSuccessCopyWith<$Res> implements $ForgotPasswordStateCopyWith<$Res> {
  factory $ForgotPasswordSuccessCopyWith(ForgotPasswordSuccess value, $Res Function(ForgotPasswordSuccess) _then) = _$ForgotPasswordSuccessCopyWithImpl;
@useResult
$Res call({
 String successMessage
});




}
/// @nodoc
class _$ForgotPasswordSuccessCopyWithImpl<$Res>
    implements $ForgotPasswordSuccessCopyWith<$Res> {
  _$ForgotPasswordSuccessCopyWithImpl(this._self, this._then);

  final ForgotPasswordSuccess _self;
  final $Res Function(ForgotPasswordSuccess) _then;

/// Create a copy of ForgotPasswordState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? successMessage = null,}) {
  return _then(ForgotPasswordSuccess(
null == successMessage ? _self.successMessage : successMessage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ForgotPasswordError implements ForgotPasswordState {
  const ForgotPasswordError(this.apiErrorModel);
  

 final  ApiErrorModel apiErrorModel;

/// Create a copy of ForgotPasswordState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForgotPasswordErrorCopyWith<ForgotPasswordError> get copyWith => _$ForgotPasswordErrorCopyWithImpl<ForgotPasswordError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ForgotPasswordError&&(identical(other.apiErrorModel, apiErrorModel) || other.apiErrorModel == apiErrorModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,apiErrorModel);
}

@override
String toString() {
    return 'ForgotPasswordState.forgotPasswordError(apiErrorModel: $apiErrorModel)';
}


}

/// @nodoc
abstract mixin class $ForgotPasswordErrorCopyWith<$Res> implements $ForgotPasswordStateCopyWith<$Res> {
  factory $ForgotPasswordErrorCopyWith(ForgotPasswordError value, $Res Function(ForgotPasswordError) _then) = _$ForgotPasswordErrorCopyWithImpl;
@useResult
$Res call({
 ApiErrorModel apiErrorModel
});




}
/// @nodoc
class _$ForgotPasswordErrorCopyWithImpl<$Res>
    implements $ForgotPasswordErrorCopyWith<$Res> {
  _$ForgotPasswordErrorCopyWithImpl(this._self, this._then);

  final ForgotPasswordError _self;
  final $Res Function(ForgotPasswordError) _then;

/// Create a copy of ForgotPasswordState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? apiErrorModel = null,}) {
  return _then(ForgotPasswordError(
null == apiErrorModel ? _self.apiErrorModel : apiErrorModel // ignore: cast_nullable_to_non_nullable
as ApiErrorModel,
  ));
}


}

// dart format on
