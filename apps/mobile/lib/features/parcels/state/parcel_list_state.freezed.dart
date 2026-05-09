// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parcel_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ParcelListState {

 bool get loading; List<ParcelSummary> get parcels; ParcelStatus? get filterStatus; String? get error;
/// Create a copy of ParcelListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParcelListStateCopyWith<ParcelListState> get copyWith => _$ParcelListStateCopyWithImpl<ParcelListState>(this as ParcelListState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParcelListState&&(identical(other.loading, loading) || other.loading == loading)&&const DeepCollectionEquality().equals(other.parcels, parcels)&&(identical(other.filterStatus, filterStatus) || other.filterStatus == filterStatus)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,loading,const DeepCollectionEquality().hash(parcels),filterStatus,error);

@override
String toString() {
  return 'ParcelListState(loading: $loading, parcels: $parcels, filterStatus: $filterStatus, error: $error)';
}


}

/// @nodoc
abstract mixin class $ParcelListStateCopyWith<$Res>  {
  factory $ParcelListStateCopyWith(ParcelListState value, $Res Function(ParcelListState) _then) = _$ParcelListStateCopyWithImpl;
@useResult
$Res call({
 bool loading, List<ParcelSummary> parcels, ParcelStatus? filterStatus, String? error
});




}
/// @nodoc
class _$ParcelListStateCopyWithImpl<$Res>
    implements $ParcelListStateCopyWith<$Res> {
  _$ParcelListStateCopyWithImpl(this._self, this._then);

  final ParcelListState _self;
  final $Res Function(ParcelListState) _then;

/// Create a copy of ParcelListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loading = null,Object? parcels = null,Object? filterStatus = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,parcels: null == parcels ? _self.parcels : parcels // ignore: cast_nullable_to_non_nullable
as List<ParcelSummary>,filterStatus: freezed == filterStatus ? _self.filterStatus : filterStatus // ignore: cast_nullable_to_non_nullable
as ParcelStatus?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ParcelListState].
extension ParcelListStatePatterns on ParcelListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParcelListState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParcelListState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParcelListState value)  $default,){
final _that = this;
switch (_that) {
case _ParcelListState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParcelListState value)?  $default,){
final _that = this;
switch (_that) {
case _ParcelListState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool loading,  List<ParcelSummary> parcels,  ParcelStatus? filterStatus,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParcelListState() when $default != null:
return $default(_that.loading,_that.parcels,_that.filterStatus,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool loading,  List<ParcelSummary> parcels,  ParcelStatus? filterStatus,  String? error)  $default,) {final _that = this;
switch (_that) {
case _ParcelListState():
return $default(_that.loading,_that.parcels,_that.filterStatus,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool loading,  List<ParcelSummary> parcels,  ParcelStatus? filterStatus,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _ParcelListState() when $default != null:
return $default(_that.loading,_that.parcels,_that.filterStatus,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _ParcelListState implements ParcelListState {
  const _ParcelListState({this.loading = false, final  List<ParcelSummary> parcels = const [], this.filterStatus, this.error}): _parcels = parcels;
  

@override@JsonKey() final  bool loading;
 final  List<ParcelSummary> _parcels;
@override@JsonKey() List<ParcelSummary> get parcels {
  if (_parcels is EqualUnmodifiableListView) return _parcels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_parcels);
}

@override final  ParcelStatus? filterStatus;
@override final  String? error;

/// Create a copy of ParcelListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParcelListStateCopyWith<_ParcelListState> get copyWith => __$ParcelListStateCopyWithImpl<_ParcelListState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParcelListState&&(identical(other.loading, loading) || other.loading == loading)&&const DeepCollectionEquality().equals(other._parcels, _parcels)&&(identical(other.filterStatus, filterStatus) || other.filterStatus == filterStatus)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,loading,const DeepCollectionEquality().hash(_parcels),filterStatus,error);

@override
String toString() {
  return 'ParcelListState(loading: $loading, parcels: $parcels, filterStatus: $filterStatus, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ParcelListStateCopyWith<$Res> implements $ParcelListStateCopyWith<$Res> {
  factory _$ParcelListStateCopyWith(_ParcelListState value, $Res Function(_ParcelListState) _then) = __$ParcelListStateCopyWithImpl;
@override @useResult
$Res call({
 bool loading, List<ParcelSummary> parcels, ParcelStatus? filterStatus, String? error
});




}
/// @nodoc
class __$ParcelListStateCopyWithImpl<$Res>
    implements _$ParcelListStateCopyWith<$Res> {
  __$ParcelListStateCopyWithImpl(this._self, this._then);

  final _ParcelListState _self;
  final $Res Function(_ParcelListState) _then;

/// Create a copy of ParcelListState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loading = null,Object? parcels = null,Object? filterStatus = freezed,Object? error = freezed,}) {
  return _then(_ParcelListState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,parcels: null == parcels ? _self._parcels : parcels // ignore: cast_nullable_to_non_nullable
as List<ParcelSummary>,filterStatus: freezed == filterStatus ? _self.filterStatus : filterStatus // ignore: cast_nullable_to_non_nullable
as ParcelStatus?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
