// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RegisterState<T> {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterState<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'RegisterState<$T>()';
}


}

/// @nodoc
class $RegisterStateCopyWith<T,$Res>  {
$RegisterStateCopyWith(RegisterState<T> _, $Res Function(RegisterState<T>) __);
}


/// Adds pattern-matching-related methods to [RegisterState].
extension RegisterStatePatterns<T> on RegisterState<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial<T> value)?  initial,TResult Function( RegisterLoading<T> value)?  registerLoading,TResult Function( RegisterSuccess<T> value)?  registerSuccess,TResult Function( RegisterError<T> value)?  registerError,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case RegisterLoading() when registerLoading != null:
return registerLoading(_that);case RegisterSuccess() when registerSuccess != null:
return registerSuccess(_that);case RegisterError() when registerError != null:
return registerError(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial<T> value)  initial,required TResult Function( RegisterLoading<T> value)  registerLoading,required TResult Function( RegisterSuccess<T> value)  registerSuccess,required TResult Function( RegisterError<T> value)  registerError,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case RegisterLoading():
return registerLoading(_that);case RegisterSuccess():
return registerSuccess(_that);case RegisterError():
return registerError(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial<T> value)?  initial,TResult? Function( RegisterLoading<T> value)?  registerLoading,TResult? Function( RegisterSuccess<T> value)?  registerSuccess,TResult? Function( RegisterError<T> value)?  registerError,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case RegisterLoading() when registerLoading != null:
return registerLoading(_that);case RegisterSuccess() when registerSuccess != null:
return registerSuccess(_that);case RegisterError() when registerError != null:
return registerError(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  registerLoading,TResult Function( T user)?  registerSuccess,TResult Function( ApiErrorModel apiErrorModel)?  registerError,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case RegisterLoading() when registerLoading != null:
return registerLoading();case RegisterSuccess() when registerSuccess != null:
return registerSuccess(_that.user);case RegisterError() when registerError != null:
return registerError(_that.apiErrorModel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  registerLoading,required TResult Function( T user)  registerSuccess,required TResult Function( ApiErrorModel apiErrorModel)  registerError,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case RegisterLoading():
return registerLoading();case RegisterSuccess():
return registerSuccess(_that.user);case RegisterError():
return registerError(_that.apiErrorModel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  registerLoading,TResult? Function( T user)?  registerSuccess,TResult? Function( ApiErrorModel apiErrorModel)?  registerError,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case RegisterLoading() when registerLoading != null:
return registerLoading();case RegisterSuccess() when registerSuccess != null:
return registerSuccess(_that.user);case RegisterError() when registerError != null:
return registerError(_that.apiErrorModel);case _:
  return null;

}
}

}

/// @nodoc


class _Initial<T> implements RegisterState<T> {
  const _Initial();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'RegisterState<$T>.initial()';
}


}




/// @nodoc


class RegisterLoading<T> implements RegisterState<T> {
  const RegisterLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterLoading<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'RegisterState<$T>.registerLoading()';
}


}




/// @nodoc


class RegisterSuccess<T> implements RegisterState<T> {
  const RegisterSuccess(this.user);
  

 final  T user;

/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterSuccessCopyWith<T, RegisterSuccess<T>> get copyWith => _$RegisterSuccessCopyWithImpl<T, RegisterSuccess<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterSuccess<T>&&const DeepCollectionEquality().equals(other.user, user));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(user));
}

@override
String toString() {
    return 'RegisterState<$T>.registerSuccess(user: $user)';
}


}

/// @nodoc
abstract mixin class $RegisterSuccessCopyWith<T,$Res> implements $RegisterStateCopyWith<T, $Res> {
  factory $RegisterSuccessCopyWith(RegisterSuccess<T> value, $Res Function(RegisterSuccess<T>) _then) = _$RegisterSuccessCopyWithImpl;
@useResult
$Res call({
 T user
});




}
/// @nodoc
class _$RegisterSuccessCopyWithImpl<T,$Res>
    implements $RegisterSuccessCopyWith<T, $Res> {
  _$RegisterSuccessCopyWithImpl(this._self, this._then);

  final RegisterSuccess<T> _self;
  final $Res Function(RegisterSuccess<T>) _then;

/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? user = freezed,}) {
  return _then(RegisterSuccess<T>(
freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

/// @nodoc


class RegisterError<T> implements RegisterState<T> {
  const RegisterError(this.apiErrorModel);
  

 final  ApiErrorModel apiErrorModel;

/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterErrorCopyWith<T, RegisterError<T>> get copyWith => _$RegisterErrorCopyWithImpl<T, RegisterError<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterError<T>&&(identical(other.apiErrorModel, apiErrorModel) || other.apiErrorModel == apiErrorModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,apiErrorModel);
}

@override
String toString() {
    return 'RegisterState<$T>.registerError(apiErrorModel: $apiErrorModel)';
}


}

/// @nodoc
abstract mixin class $RegisterErrorCopyWith<T,$Res> implements $RegisterStateCopyWith<T, $Res> {
  factory $RegisterErrorCopyWith(RegisterError<T> value, $Res Function(RegisterError<T>) _then) = _$RegisterErrorCopyWithImpl;
@useResult
$Res call({
 ApiErrorModel apiErrorModel
});




}
/// @nodoc
class _$RegisterErrorCopyWithImpl<T,$Res>
    implements $RegisterErrorCopyWith<T, $Res> {
  _$RegisterErrorCopyWithImpl(this._self, this._then);

  final RegisterError<T> _self;
  final $Res Function(RegisterError<T>) _then;

/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? apiErrorModel = null,}) {
  return _then(RegisterError<T>(
null == apiErrorModel ? _self.apiErrorModel : apiErrorModel // ignore: cast_nullable_to_non_nullable
as ApiErrorModel,
  ));
}


}

// dart format on
