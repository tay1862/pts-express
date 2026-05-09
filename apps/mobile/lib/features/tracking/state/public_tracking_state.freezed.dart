// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'public_tracking_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PublicTrackingState {

 bool get loading; TrackResult? get result; String? get error;
/// Create a copy of PublicTrackingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicTrackingStateCopyWith<PublicTrackingState> get copyWith => _$PublicTrackingStateCopyWithImpl<PublicTrackingState>(this as PublicTrackingState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicTrackingState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.result, result) || other.result == result)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,loading,result,error);

@override
String toString() {
  return 'PublicTrackingState(loading: $loading, result: $result, error: $error)';
}


}

/// @nodoc
abstract mixin class $PublicTrackingStateCopyWith<$Res>  {
  factory $PublicTrackingStateCopyWith(PublicTrackingState value, $Res Function(PublicTrackingState) _then) = _$PublicTrackingStateCopyWithImpl;
@useResult
$Res call({
 bool loading, TrackResult? result, String? error
});




}
/// @nodoc
class _$PublicTrackingStateCopyWithImpl<$Res>
    implements $PublicTrackingStateCopyWith<$Res> {
  _$PublicTrackingStateCopyWithImpl(this._self, this._then);

  final PublicTrackingState _self;
  final $Res Function(PublicTrackingState) _then;

/// Create a copy of PublicTrackingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loading = null,Object? result = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as TrackResult?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PublicTrackingState].
extension PublicTrackingStatePatterns on PublicTrackingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicTrackingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicTrackingState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicTrackingState value)  $default,){
final _that = this;
switch (_that) {
case _PublicTrackingState():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicTrackingState value)?  $default,){
final _that = this;
switch (_that) {
case _PublicTrackingState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool loading,  TrackResult? result,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicTrackingState() when $default != null:
return $default(_that.loading,_that.result,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool loading,  TrackResult? result,  String? error)  $default,) {final _that = this;
switch (_that) {
case _PublicTrackingState():
return $default(_that.loading,_that.result,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool loading,  TrackResult? result,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _PublicTrackingState() when $default != null:
return $default(_that.loading,_that.result,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _PublicTrackingState implements PublicTrackingState {
  const _PublicTrackingState({this.loading = false, this.result, this.error});
  

@override@JsonKey() final  bool loading;
@override final  TrackResult? result;
@override final  String? error;

/// Create a copy of PublicTrackingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicTrackingStateCopyWith<_PublicTrackingState> get copyWith => __$PublicTrackingStateCopyWithImpl<_PublicTrackingState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicTrackingState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.result, result) || other.result == result)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,loading,result,error);

@override
String toString() {
  return 'PublicTrackingState(loading: $loading, result: $result, error: $error)';
}


}

/// @nodoc
abstract mixin class _$PublicTrackingStateCopyWith<$Res> implements $PublicTrackingStateCopyWith<$Res> {
  factory _$PublicTrackingStateCopyWith(_PublicTrackingState value, $Res Function(_PublicTrackingState) _then) = __$PublicTrackingStateCopyWithImpl;
@override @useResult
$Res call({
 bool loading, TrackResult? result, String? error
});




}
/// @nodoc
class __$PublicTrackingStateCopyWithImpl<$Res>
    implements _$PublicTrackingStateCopyWith<$Res> {
  __$PublicTrackingStateCopyWithImpl(this._self, this._then);

  final _PublicTrackingState _self;
  final $Res Function(_PublicTrackingState) _then;

/// Create a copy of PublicTrackingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loading = null,Object? result = freezed,Object? error = freezed,}) {
  return _then(_PublicTrackingState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as TrackResult?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
