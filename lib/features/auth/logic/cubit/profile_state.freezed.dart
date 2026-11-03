// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileState<T> {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileState<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ProfileState<$T>()';
}


}

/// @nodoc
class $ProfileStateCopyWith<T,$Res>  {
$ProfileStateCopyWith(ProfileState<T> _, $Res Function(ProfileState<T>) __);
}


/// Adds pattern-matching-related methods to [ProfileState].
extension ProfileStatePatterns<T> on ProfileState<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial<T> value)?  initial,TResult Function( ProfileLoading<T> value)?  profileLoading,TResult Function( ProfileSuccess<T> value)?  profileSuccess,TResult Function( ProfileUpdateLoading<T> value)?  profileUpdateLoading,TResult Function( ProfileUpdateSuccess<T> value)?  profileUpdateSuccess,TResult Function( ProfileError<T> value)?  profileError,TResult Function( ProfileUpdateError<T> value)?  profileUpdateError,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case ProfileLoading() when profileLoading != null:
return profileLoading(_that);case ProfileSuccess() when profileSuccess != null:
return profileSuccess(_that);case ProfileUpdateLoading() when profileUpdateLoading != null:
return profileUpdateLoading(_that);case ProfileUpdateSuccess() when profileUpdateSuccess != null:
return profileUpdateSuccess(_that);case ProfileError() when profileError != null:
return profileError(_that);case ProfileUpdateError() when profileUpdateError != null:
return profileUpdateError(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial<T> value)  initial,required TResult Function( ProfileLoading<T> value)  profileLoading,required TResult Function( ProfileSuccess<T> value)  profileSuccess,required TResult Function( ProfileUpdateLoading<T> value)  profileUpdateLoading,required TResult Function( ProfileUpdateSuccess<T> value)  profileUpdateSuccess,required TResult Function( ProfileError<T> value)  profileError,required TResult Function( ProfileUpdateError<T> value)  profileUpdateError,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case ProfileLoading():
return profileLoading(_that);case ProfileSuccess():
return profileSuccess(_that);case ProfileUpdateLoading():
return profileUpdateLoading(_that);case ProfileUpdateSuccess():
return profileUpdateSuccess(_that);case ProfileError():
return profileError(_that);case ProfileUpdateError():
return profileUpdateError(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial<T> value)?  initial,TResult? Function( ProfileLoading<T> value)?  profileLoading,TResult? Function( ProfileSuccess<T> value)?  profileSuccess,TResult? Function( ProfileUpdateLoading<T> value)?  profileUpdateLoading,TResult? Function( ProfileUpdateSuccess<T> value)?  profileUpdateSuccess,TResult? Function( ProfileError<T> value)?  profileError,TResult? Function( ProfileUpdateError<T> value)?  profileUpdateError,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case ProfileLoading() when profileLoading != null:
return profileLoading(_that);case ProfileSuccess() when profileSuccess != null:
return profileSuccess(_that);case ProfileUpdateLoading() when profileUpdateLoading != null:
return profileUpdateLoading(_that);case ProfileUpdateSuccess() when profileUpdateSuccess != null:
return profileUpdateSuccess(_that);case ProfileError() when profileError != null:
return profileError(_that);case ProfileUpdateError() when profileUpdateError != null:
return profileUpdateError(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  profileLoading,TResult Function( UserModel user)?  profileSuccess,TResult Function()?  profileUpdateLoading,TResult Function( String successMessage)?  profileUpdateSuccess,TResult Function( ApiErrorModel apiErrorModel)?  profileError,TResult Function( ApiErrorModel apiErrorModel)?  profileUpdateError,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case ProfileLoading() when profileLoading != null:
return profileLoading();case ProfileSuccess() when profileSuccess != null:
return profileSuccess(_that.user);case ProfileUpdateLoading() when profileUpdateLoading != null:
return profileUpdateLoading();case ProfileUpdateSuccess() when profileUpdateSuccess != null:
return profileUpdateSuccess(_that.successMessage);case ProfileError() when profileError != null:
return profileError(_that.apiErrorModel);case ProfileUpdateError() when profileUpdateError != null:
return profileUpdateError(_that.apiErrorModel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  profileLoading,required TResult Function( UserModel user)  profileSuccess,required TResult Function()  profileUpdateLoading,required TResult Function( String successMessage)  profileUpdateSuccess,required TResult Function( ApiErrorModel apiErrorModel)  profileError,required TResult Function( ApiErrorModel apiErrorModel)  profileUpdateError,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case ProfileLoading():
return profileLoading();case ProfileSuccess():
return profileSuccess(_that.user);case ProfileUpdateLoading():
return profileUpdateLoading();case ProfileUpdateSuccess():
return profileUpdateSuccess(_that.successMessage);case ProfileError():
return profileError(_that.apiErrorModel);case ProfileUpdateError():
return profileUpdateError(_that.apiErrorModel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  profileLoading,TResult? Function( UserModel user)?  profileSuccess,TResult? Function()?  profileUpdateLoading,TResult? Function( String successMessage)?  profileUpdateSuccess,TResult? Function( ApiErrorModel apiErrorModel)?  profileError,TResult? Function( ApiErrorModel apiErrorModel)?  profileUpdateError,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case ProfileLoading() when profileLoading != null:
return profileLoading();case ProfileSuccess() when profileSuccess != null:
return profileSuccess(_that.user);case ProfileUpdateLoading() when profileUpdateLoading != null:
return profileUpdateLoading();case ProfileUpdateSuccess() when profileUpdateSuccess != null:
return profileUpdateSuccess(_that.successMessage);case ProfileError() when profileError != null:
return profileError(_that.apiErrorModel);case ProfileUpdateError() when profileUpdateError != null:
return profileUpdateError(_that.apiErrorModel);case _:
  return null;

}
}

}

/// @nodoc


class _Initial<T> implements ProfileState<T> {
  const _Initial();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ProfileState<$T>.initial()';
}


}




/// @nodoc


class ProfileLoading<T> implements ProfileState<T> {
  const ProfileLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileLoading<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ProfileState<$T>.profileLoading()';
}


}




/// @nodoc


class ProfileSuccess<T> implements ProfileState<T> {
  const ProfileSuccess(this.user);
  

 final  UserModel user;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileSuccessCopyWith<T, ProfileSuccess<T>> get copyWith => _$ProfileSuccessCopyWithImpl<T, ProfileSuccess<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileSuccess<T>&&(identical(other.user, user) || other.user == user));
}


@override
int get hashCode {
    return Object.hash(runtimeType,user);
}

@override
String toString() {
    return 'ProfileState<$T>.profileSuccess(user: $user)';
}


}

/// @nodoc
abstract mixin class $ProfileSuccessCopyWith<T,$Res> implements $ProfileStateCopyWith<T, $Res> {
  factory $ProfileSuccessCopyWith(ProfileSuccess<T> value, $Res Function(ProfileSuccess<T>) _then) = _$ProfileSuccessCopyWithImpl;
@useResult
$Res call({
 UserModel user
});




}
/// @nodoc
class _$ProfileSuccessCopyWithImpl<T,$Res>
    implements $ProfileSuccessCopyWith<T, $Res> {
  _$ProfileSuccessCopyWithImpl(this._self, this._then);

  final ProfileSuccess<T> _self;
  final $Res Function(ProfileSuccess<T>) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? user = null,}) {
  return _then(ProfileSuccess<T>(
null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserModel,
  ));
}


}

/// @nodoc


class ProfileUpdateLoading<T> implements ProfileState<T> {
  const ProfileUpdateLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileUpdateLoading<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ProfileState<$T>.profileUpdateLoading()';
}


}




/// @nodoc


class ProfileUpdateSuccess<T> implements ProfileState<T> {
  const ProfileUpdateSuccess(this.successMessage);
  

 final  String successMessage;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileUpdateSuccessCopyWith<T, ProfileUpdateSuccess<T>> get copyWith => _$ProfileUpdateSuccessCopyWithImpl<T, ProfileUpdateSuccess<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileUpdateSuccess<T>&&(identical(other.successMessage, successMessage) || other.successMessage == successMessage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,successMessage);
}

@override
String toString() {
    return 'ProfileState<$T>.profileUpdateSuccess(successMessage: $successMessage)';
}


}

/// @nodoc
abstract mixin class $ProfileUpdateSuccessCopyWith<T,$Res> implements $ProfileStateCopyWith<T, $Res> {
  factory $ProfileUpdateSuccessCopyWith(ProfileUpdateSuccess<T> value, $Res Function(ProfileUpdateSuccess<T>) _then) = _$ProfileUpdateSuccessCopyWithImpl;
@useResult
$Res call({
 String successMessage
});




}
/// @nodoc
class _$ProfileUpdateSuccessCopyWithImpl<T,$Res>
    implements $ProfileUpdateSuccessCopyWith<T, $Res> {
  _$ProfileUpdateSuccessCopyWithImpl(this._self, this._then);

  final ProfileUpdateSuccess<T> _self;
  final $Res Function(ProfileUpdateSuccess<T>) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? successMessage = null,}) {
  return _then(ProfileUpdateSuccess<T>(
null == successMessage ? _self.successMessage : successMessage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ProfileError<T> implements ProfileState<T> {
  const ProfileError(this.apiErrorModel);
  

 final  ApiErrorModel apiErrorModel;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileErrorCopyWith<T, ProfileError<T>> get copyWith => _$ProfileErrorCopyWithImpl<T, ProfileError<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileError<T>&&(identical(other.apiErrorModel, apiErrorModel) || other.apiErrorModel == apiErrorModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,apiErrorModel);
}

@override
String toString() {
    return 'ProfileState<$T>.profileError(apiErrorModel: $apiErrorModel)';
}


}

/// @nodoc
abstract mixin class $ProfileErrorCopyWith<T,$Res> implements $ProfileStateCopyWith<T, $Res> {
  factory $ProfileErrorCopyWith(ProfileError<T> value, $Res Function(ProfileError<T>) _then) = _$ProfileErrorCopyWithImpl;
@useResult
$Res call({
 ApiErrorModel apiErrorModel
});




}
/// @nodoc
class _$ProfileErrorCopyWithImpl<T,$Res>
    implements $ProfileErrorCopyWith<T, $Res> {
  _$ProfileErrorCopyWithImpl(this._self, this._then);

  final ProfileError<T> _self;
  final $Res Function(ProfileError<T>) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? apiErrorModel = null,}) {
  return _then(ProfileError<T>(
null == apiErrorModel ? _self.apiErrorModel : apiErrorModel // ignore: cast_nullable_to_non_nullable
as ApiErrorModel,
  ));
}


}

/// @nodoc


class ProfileUpdateError<T> implements ProfileState<T> {
  const ProfileUpdateError(this.apiErrorModel);
  

 final  ApiErrorModel apiErrorModel;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileUpdateErrorCopyWith<T, ProfileUpdateError<T>> get copyWith => _$ProfileUpdateErrorCopyWithImpl<T, ProfileUpdateError<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileUpdateError<T>&&(identical(other.apiErrorModel, apiErrorModel) || other.apiErrorModel == apiErrorModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,apiErrorModel);
}

@override
String toString() {
    return 'ProfileState<$T>.profileUpdateError(apiErrorModel: $apiErrorModel)';
}


}

/// @nodoc
abstract mixin class $ProfileUpdateErrorCopyWith<T,$Res> implements $ProfileStateCopyWith<T, $Res> {
  factory $ProfileUpdateErrorCopyWith(ProfileUpdateError<T> value, $Res Function(ProfileUpdateError<T>) _then) = _$ProfileUpdateErrorCopyWithImpl;
@useResult
$Res call({
 ApiErrorModel apiErrorModel
});




}
/// @nodoc
class _$ProfileUpdateErrorCopyWithImpl<T,$Res>
    implements $ProfileUpdateErrorCopyWith<T, $Res> {
  _$ProfileUpdateErrorCopyWithImpl(this._self, this._then);

  final ProfileUpdateError<T> _self;
  final $Res Function(ProfileUpdateError<T>) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? apiErrorModel = null,}) {
  return _then(ProfileUpdateError<T>(
null == apiErrorModel ? _self.apiErrorModel : apiErrorModel // ignore: cast_nullable_to_non_nullable
as ApiErrorModel,
  ));
}


}

// dart format on
