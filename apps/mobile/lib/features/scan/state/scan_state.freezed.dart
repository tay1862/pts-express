// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scan_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ScanState {

 ScanMode get mode; ScanSubmissionStatus get submissionStatus; int get pendingCount; bool get lastQueued; String? get message; String? get missingTrackingCode; ParcelSummary? get lastParcel;
/// Create a copy of ScanState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScanStateCopyWith<ScanState> get copyWith => _$ScanStateCopyWithImpl<ScanState>(this as ScanState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScanState&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.submissionStatus, submissionStatus) || other.submissionStatus == submissionStatus)&&(identical(other.pendingCount, pendingCount) || other.pendingCount == pendingCount)&&(identical(other.lastQueued, lastQueued) || other.lastQueued == lastQueued)&&(identical(other.message, message) || other.message == message)&&(identical(other.missingTrackingCode, missingTrackingCode) || other.missingTrackingCode == missingTrackingCode)&&(identical(other.lastParcel, lastParcel) || other.lastParcel == lastParcel));
}


@override
int get hashCode => Object.hash(runtimeType,mode,submissionStatus,pendingCount,lastQueued,message,missingTrackingCode,lastParcel);

@override
String toString() {
  return 'ScanState(mode: $mode, submissionStatus: $submissionStatus, pendingCount: $pendingCount, lastQueued: $lastQueued, message: $message, missingTrackingCode: $missingTrackingCode, lastParcel: $lastParcel)';
}


}

/// @nodoc
abstract mixin class $ScanStateCopyWith<$Res>  {
  factory $ScanStateCopyWith(ScanState value, $Res Function(ScanState) _then) = _$ScanStateCopyWithImpl;
@useResult
$Res call({
 ScanMode mode, ScanSubmissionStatus submissionStatus, int pendingCount, bool lastQueued, String? message, String? missingTrackingCode, ParcelSummary? lastParcel
});




}
/// @nodoc
class _$ScanStateCopyWithImpl<$Res>
    implements $ScanStateCopyWith<$Res> {
  _$ScanStateCopyWithImpl(this._self, this._then);

  final ScanState _self;
  final $Res Function(ScanState) _then;

/// Create a copy of ScanState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? submissionStatus = null,Object? pendingCount = null,Object? lastQueued = null,Object? message = freezed,Object? missingTrackingCode = freezed,Object? lastParcel = freezed,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ScanMode,submissionStatus: null == submissionStatus ? _self.submissionStatus : submissionStatus // ignore: cast_nullable_to_non_nullable
as ScanSubmissionStatus,pendingCount: null == pendingCount ? _self.pendingCount : pendingCount // ignore: cast_nullable_to_non_nullable
as int,lastQueued: null == lastQueued ? _self.lastQueued : lastQueued // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,missingTrackingCode: freezed == missingTrackingCode ? _self.missingTrackingCode : missingTrackingCode // ignore: cast_nullable_to_non_nullable
as String?,lastParcel: freezed == lastParcel ? _self.lastParcel : lastParcel // ignore: cast_nullable_to_non_nullable
as ParcelSummary?,
  ));
}

}


/// Adds pattern-matching-related methods to [ScanState].
extension ScanStatePatterns on ScanState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScanState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScanState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScanState value)  $default,){
final _that = this;
switch (_that) {
case _ScanState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScanState value)?  $default,){
final _that = this;
switch (_that) {
case _ScanState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ScanMode mode,  ScanSubmissionStatus submissionStatus,  int pendingCount,  bool lastQueued,  String? message,  String? missingTrackingCode,  ParcelSummary? lastParcel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScanState() when $default != null:
return $default(_that.mode,_that.submissionStatus,_that.pendingCount,_that.lastQueued,_that.message,_that.missingTrackingCode,_that.lastParcel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ScanMode mode,  ScanSubmissionStatus submissionStatus,  int pendingCount,  bool lastQueued,  String? message,  String? missingTrackingCode,  ParcelSummary? lastParcel)  $default,) {final _that = this;
switch (_that) {
case _ScanState():
return $default(_that.mode,_that.submissionStatus,_that.pendingCount,_that.lastQueued,_that.message,_that.missingTrackingCode,_that.lastParcel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ScanMode mode,  ScanSubmissionStatus submissionStatus,  int pendingCount,  bool lastQueued,  String? message,  String? missingTrackingCode,  ParcelSummary? lastParcel)?  $default,) {final _that = this;
switch (_that) {
case _ScanState() when $default != null:
return $default(_that.mode,_that.submissionStatus,_that.pendingCount,_that.lastQueued,_that.message,_that.missingTrackingCode,_that.lastParcel);case _:
  return null;

}
}

}

/// @nodoc


class _ScanState implements ScanState {
  const _ScanState({this.mode = ScanMode.receive, this.submissionStatus = ScanSubmissionStatus.idle, this.pendingCount = 0, this.lastQueued = false, this.message, this.missingTrackingCode, this.lastParcel});
  

@override@JsonKey() final  ScanMode mode;
@override@JsonKey() final  ScanSubmissionStatus submissionStatus;
@override@JsonKey() final  int pendingCount;
@override@JsonKey() final  bool lastQueued;
@override final  String? message;
@override final  String? missingTrackingCode;
@override final  ParcelSummary? lastParcel;

/// Create a copy of ScanState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScanStateCopyWith<_ScanState> get copyWith => __$ScanStateCopyWithImpl<_ScanState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScanState&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.submissionStatus, submissionStatus) || other.submissionStatus == submissionStatus)&&(identical(other.pendingCount, pendingCount) || other.pendingCount == pendingCount)&&(identical(other.lastQueued, lastQueued) || other.lastQueued == lastQueued)&&(identical(other.message, message) || other.message == message)&&(identical(other.missingTrackingCode, missingTrackingCode) || other.missingTrackingCode == missingTrackingCode)&&(identical(other.lastParcel, lastParcel) || other.lastParcel == lastParcel));
}


@override
int get hashCode => Object.hash(runtimeType,mode,submissionStatus,pendingCount,lastQueued,message,missingTrackingCode,lastParcel);

@override
String toString() {
  return 'ScanState(mode: $mode, submissionStatus: $submissionStatus, pendingCount: $pendingCount, lastQueued: $lastQueued, message: $message, missingTrackingCode: $missingTrackingCode, lastParcel: $lastParcel)';
}


}

/// @nodoc
abstract mixin class _$ScanStateCopyWith<$Res> implements $ScanStateCopyWith<$Res> {
  factory _$ScanStateCopyWith(_ScanState value, $Res Function(_ScanState) _then) = __$ScanStateCopyWithImpl;
@override @useResult
$Res call({
 ScanMode mode, ScanSubmissionStatus submissionStatus, int pendingCount, bool lastQueued, String? message, String? missingTrackingCode, ParcelSummary? lastParcel
});




}
/// @nodoc
class __$ScanStateCopyWithImpl<$Res>
    implements _$ScanStateCopyWith<$Res> {
  __$ScanStateCopyWithImpl(this._self, this._then);

  final _ScanState _self;
  final $Res Function(_ScanState) _then;

/// Create a copy of ScanState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? submissionStatus = null,Object? pendingCount = null,Object? lastQueued = null,Object? message = freezed,Object? missingTrackingCode = freezed,Object? lastParcel = freezed,}) {
  return _then(_ScanState(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ScanMode,submissionStatus: null == submissionStatus ? _self.submissionStatus : submissionStatus // ignore: cast_nullable_to_non_nullable
as ScanSubmissionStatus,pendingCount: null == pendingCount ? _self.pendingCount : pendingCount // ignore: cast_nullable_to_non_nullable
as int,lastQueued: null == lastQueued ? _self.lastQueued : lastQueued // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,missingTrackingCode: freezed == missingTrackingCode ? _self.missingTrackingCode : missingTrackingCode // ignore: cast_nullable_to_non_nullable
as String?,lastParcel: freezed == lastParcel ? _self.lastParcel : lastParcel // ignore: cast_nullable_to_non_nullable
as ParcelSummary?,
  ));
}


}

// dart format on
