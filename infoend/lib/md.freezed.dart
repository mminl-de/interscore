// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'md.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Matchday _$MatchdayFromJson(Map<String, dynamic> json) {
  return _Matchday.fromJson(json);
}

/// @nodoc
mixin _$Matchday {
  Meta get meta => throw _privateConstructorUsedError;
  List<Team> get teams => throw _privateConstructorUsedError;
  List<Group> get groups => throw _privateConstructorUsedError;
  List<Game> get games => throw _privateConstructorUsedError;

  /// Serializes this Matchday to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Matchday
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchdayCopyWith<Matchday> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchdayCopyWith<$Res> {
  factory $MatchdayCopyWith(Matchday value, $Res Function(Matchday) then) =
      _$MatchdayCopyWithImpl<$Res, Matchday>;
  @useResult
  $Res call({
    Meta meta,
    List<Team> teams,
    List<Group> groups,
    List<Game> games,
  });

  $MetaCopyWith<$Res> get meta;
}

/// @nodoc
class _$MatchdayCopyWithImpl<$Res, $Val extends Matchday>
    implements $MatchdayCopyWith<$Res> {
  _$MatchdayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Matchday
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meta = null,
    Object? teams = null,
    Object? groups = null,
    Object? games = null,
  }) {
    return _then(
      _value.copyWith(
            meta: null == meta
                ? _value.meta
                : meta // ignore: cast_nullable_to_non_nullable
                      as Meta,
            teams: null == teams
                ? _value.teams
                : teams // ignore: cast_nullable_to_non_nullable
                      as List<Team>,
            groups: null == groups
                ? _value.groups
                : groups // ignore: cast_nullable_to_non_nullable
                      as List<Group>,
            games: null == games
                ? _value.games
                : games // ignore: cast_nullable_to_non_nullable
                      as List<Game>,
          )
          as $Val,
    );
  }

  /// Create a copy of Matchday
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MetaCopyWith<$Res> get meta {
    return $MetaCopyWith<$Res>(_value.meta, (value) {
      return _then(_value.copyWith(meta: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MatchdayImplCopyWith<$Res>
    implements $MatchdayCopyWith<$Res> {
  factory _$$MatchdayImplCopyWith(
    _$MatchdayImpl value,
    $Res Function(_$MatchdayImpl) then,
  ) = __$$MatchdayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Meta meta,
    List<Team> teams,
    List<Group> groups,
    List<Game> games,
  });

  @override
  $MetaCopyWith<$Res> get meta;
}

/// @nodoc
class __$$MatchdayImplCopyWithImpl<$Res>
    extends _$MatchdayCopyWithImpl<$Res, _$MatchdayImpl>
    implements _$$MatchdayImplCopyWith<$Res> {
  __$$MatchdayImplCopyWithImpl(
    _$MatchdayImpl _value,
    $Res Function(_$MatchdayImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Matchday
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meta = null,
    Object? teams = null,
    Object? groups = null,
    Object? games = null,
  }) {
    return _then(
      _$MatchdayImpl(
        null == meta
            ? _value.meta
            : meta // ignore: cast_nullable_to_non_nullable
                  as Meta,
        null == teams
            ? _value._teams
            : teams // ignore: cast_nullable_to_non_nullable
                  as List<Team>,
        null == groups
            ? _value._groups
            : groups // ignore: cast_nullable_to_non_nullable
                  as List<Group>,
        null == games
            ? _value._games
            : games // ignore: cast_nullable_to_non_nullable
                  as List<Game>,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$MatchdayImpl extends _Matchday {
  const _$MatchdayImpl(
    this.meta,
    final List<Team> teams,
    final List<Group> groups,
    final List<Game> games,
  ) : _teams = teams,
      _groups = groups,
      _games = games,
      super._();

  factory _$MatchdayImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchdayImplFromJson(json);

  @override
  final Meta meta;
  final List<Team> _teams;
  @override
  List<Team> get teams {
    if (_teams is EqualUnmodifiableListView) return _teams;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_teams);
  }

  final List<Group> _groups;
  @override
  List<Group> get groups {
    if (_groups is EqualUnmodifiableListView) return _groups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_groups);
  }

  final List<Game> _games;
  @override
  List<Game> get games {
    if (_games is EqualUnmodifiableListView) return _games;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_games);
  }

  @override
  String toString() {
    return 'Matchday(meta: $meta, teams: $teams, groups: $groups, games: $games)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchdayImpl &&
            (identical(other.meta, meta) || other.meta == meta) &&
            const DeepCollectionEquality().equals(other._teams, _teams) &&
            const DeepCollectionEquality().equals(other._groups, _groups) &&
            const DeepCollectionEquality().equals(other._games, _games));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    meta,
    const DeepCollectionEquality().hash(_teams),
    const DeepCollectionEquality().hash(_groups),
    const DeepCollectionEquality().hash(_games),
  );

  /// Create a copy of Matchday
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchdayImplCopyWith<_$MatchdayImpl> get copyWith =>
      __$$MatchdayImplCopyWithImpl<_$MatchdayImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchdayImplToJson(this);
  }
}

abstract class _Matchday extends Matchday {
  const factory _Matchday(
    final Meta meta,
    final List<Team> teams,
    final List<Group> groups,
    final List<Game> games,
  ) = _$MatchdayImpl;
  const _Matchday._() : super._();

  factory _Matchday.fromJson(Map<String, dynamic> json) =
      _$MatchdayImpl.fromJson;

  @override
  Meta get meta;
  @override
  List<Team> get teams;
  @override
  List<Group> get groups;
  @override
  List<Game> get games;

  /// Create a copy of Matchday
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchdayImplCopyWith<_$MatchdayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Meta _$MetaFromJson(Map<String, dynamic> json) {
  return _Meta.fromJson(json);
}

/// @nodoc
mixin _$Meta {
  @JsonKey(name: 'game_i', toJson: intOrNullNot0)
  int get gameIndex => throw _privateConstructorUsedError;
  @JsonKey(name: 'cur_gamepart', toJson: intOrNullNot0)
  int get currentGamepart => throw _privateConstructorUsedError; // This is for an EXTRA invert, not the normal side switching.
  // The normal side switching is done through formats!
  // This is still needed, because maybe the teams are standing the other way around at the beginning
  @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
  bool get sidesInverted => throw _privateConstructorUsedError;
  @JsonKey(toJson: boolOrNullFalse)
  bool get paused => throw _privateConstructorUsedError;
  @JsonKey(name: 'remaining_time')
  int get remainingTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_unpaused')
  int get lastUnpaused => throw _privateConstructorUsedError;
  @JsonKey(name: 'allow_remote_game_creation', toJson: boolOrNullTrue)
  bool get allowRemoteGameCreation => throw _privateConstructorUsedError;
  @JsonKey(name: 'delay', toJson: null)
  int get delay => throw _privateConstructorUsedError;
  bool get widgetScoreboard => throw _privateConstructorUsedError;
  bool get widgetGameplan => throw _privateConstructorUsedError;
  bool get widgetLiveplan => throw _privateConstructorUsedError;
  bool get widgetGamestart => throw _privateConstructorUsedError;
  bool get widgetAd => throw _privateConstructorUsedError;
  bool get streamStarted => throw _privateConstructorUsedError;
  bool get replayStarted => throw _privateConstructorUsedError;
  List<Format> get formats => throw _privateConstructorUsedError;

  /// Serializes this Meta to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Meta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MetaCopyWith<Meta> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MetaCopyWith<$Res> {
  factory $MetaCopyWith(Meta value, $Res Function(Meta) then) =
      _$MetaCopyWithImpl<$Res, Meta>;
  @useResult
  $Res call({
    @JsonKey(name: 'game_i', toJson: intOrNullNot0) int gameIndex,
    @JsonKey(name: 'cur_gamepart', toJson: intOrNullNot0) int currentGamepart,
    @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue) bool sidesInverted,
    @JsonKey(toJson: boolOrNullFalse) bool paused,
    @JsonKey(name: 'remaining_time') int remainingTime,
    @JsonKey(name: 'last_unpaused') int lastUnpaused,
    @JsonKey(name: 'allow_remote_game_creation', toJson: boolOrNullTrue)
    bool allowRemoteGameCreation,
    @JsonKey(name: 'delay', toJson: null) int delay,
    bool widgetScoreboard,
    bool widgetGameplan,
    bool widgetLiveplan,
    bool widgetGamestart,
    bool widgetAd,
    bool streamStarted,
    bool replayStarted,
    List<Format> formats,
  });
}

/// @nodoc
class _$MetaCopyWithImpl<$Res, $Val extends Meta>
    implements $MetaCopyWith<$Res> {
  _$MetaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Meta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameIndex = null,
    Object? currentGamepart = null,
    Object? sidesInverted = null,
    Object? paused = null,
    Object? remainingTime = null,
    Object? lastUnpaused = null,
    Object? allowRemoteGameCreation = null,
    Object? delay = null,
    Object? widgetScoreboard = null,
    Object? widgetGameplan = null,
    Object? widgetLiveplan = null,
    Object? widgetGamestart = null,
    Object? widgetAd = null,
    Object? streamStarted = null,
    Object? replayStarted = null,
    Object? formats = null,
  }) {
    return _then(
      _value.copyWith(
            gameIndex: null == gameIndex
                ? _value.gameIndex
                : gameIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            currentGamepart: null == currentGamepart
                ? _value.currentGamepart
                : currentGamepart // ignore: cast_nullable_to_non_nullable
                      as int,
            sidesInverted: null == sidesInverted
                ? _value.sidesInverted
                : sidesInverted // ignore: cast_nullable_to_non_nullable
                      as bool,
            paused: null == paused
                ? _value.paused
                : paused // ignore: cast_nullable_to_non_nullable
                      as bool,
            remainingTime: null == remainingTime
                ? _value.remainingTime
                : remainingTime // ignore: cast_nullable_to_non_nullable
                      as int,
            lastUnpaused: null == lastUnpaused
                ? _value.lastUnpaused
                : lastUnpaused // ignore: cast_nullable_to_non_nullable
                      as int,
            allowRemoteGameCreation: null == allowRemoteGameCreation
                ? _value.allowRemoteGameCreation
                : allowRemoteGameCreation // ignore: cast_nullable_to_non_nullable
                      as bool,
            delay: null == delay
                ? _value.delay
                : delay // ignore: cast_nullable_to_non_nullable
                      as int,
            widgetScoreboard: null == widgetScoreboard
                ? _value.widgetScoreboard
                : widgetScoreboard // ignore: cast_nullable_to_non_nullable
                      as bool,
            widgetGameplan: null == widgetGameplan
                ? _value.widgetGameplan
                : widgetGameplan // ignore: cast_nullable_to_non_nullable
                      as bool,
            widgetLiveplan: null == widgetLiveplan
                ? _value.widgetLiveplan
                : widgetLiveplan // ignore: cast_nullable_to_non_nullable
                      as bool,
            widgetGamestart: null == widgetGamestart
                ? _value.widgetGamestart
                : widgetGamestart // ignore: cast_nullable_to_non_nullable
                      as bool,
            widgetAd: null == widgetAd
                ? _value.widgetAd
                : widgetAd // ignore: cast_nullable_to_non_nullable
                      as bool,
            streamStarted: null == streamStarted
                ? _value.streamStarted
                : streamStarted // ignore: cast_nullable_to_non_nullable
                      as bool,
            replayStarted: null == replayStarted
                ? _value.replayStarted
                : replayStarted // ignore: cast_nullable_to_non_nullable
                      as bool,
            formats: null == formats
                ? _value.formats
                : formats // ignore: cast_nullable_to_non_nullable
                      as List<Format>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MetaImplCopyWith<$Res> implements $MetaCopyWith<$Res> {
  factory _$$MetaImplCopyWith(
    _$MetaImpl value,
    $Res Function(_$MetaImpl) then,
  ) = __$$MetaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'game_i', toJson: intOrNullNot0) int gameIndex,
    @JsonKey(name: 'cur_gamepart', toJson: intOrNullNot0) int currentGamepart,
    @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue) bool sidesInverted,
    @JsonKey(toJson: boolOrNullFalse) bool paused,
    @JsonKey(name: 'remaining_time') int remainingTime,
    @JsonKey(name: 'last_unpaused') int lastUnpaused,
    @JsonKey(name: 'allow_remote_game_creation', toJson: boolOrNullTrue)
    bool allowRemoteGameCreation,
    @JsonKey(name: 'delay', toJson: null) int delay,
    bool widgetScoreboard,
    bool widgetGameplan,
    bool widgetLiveplan,
    bool widgetGamestart,
    bool widgetAd,
    bool streamStarted,
    bool replayStarted,
    List<Format> formats,
  });
}

/// @nodoc
class __$$MetaImplCopyWithImpl<$Res>
    extends _$MetaCopyWithImpl<$Res, _$MetaImpl>
    implements _$$MetaImplCopyWith<$Res> {
  __$$MetaImplCopyWithImpl(_$MetaImpl _value, $Res Function(_$MetaImpl) _then)
    : super(_value, _then);

  /// Create a copy of Meta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameIndex = null,
    Object? currentGamepart = null,
    Object? sidesInverted = null,
    Object? paused = null,
    Object? remainingTime = null,
    Object? lastUnpaused = null,
    Object? allowRemoteGameCreation = null,
    Object? delay = null,
    Object? widgetScoreboard = null,
    Object? widgetGameplan = null,
    Object? widgetLiveplan = null,
    Object? widgetGamestart = null,
    Object? widgetAd = null,
    Object? streamStarted = null,
    Object? replayStarted = null,
    Object? formats = null,
  }) {
    return _then(
      _$MetaImpl(
        gameIndex: null == gameIndex
            ? _value.gameIndex
            : gameIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        currentGamepart: null == currentGamepart
            ? _value.currentGamepart
            : currentGamepart // ignore: cast_nullable_to_non_nullable
                  as int,
        sidesInverted: null == sidesInverted
            ? _value.sidesInverted
            : sidesInverted // ignore: cast_nullable_to_non_nullable
                  as bool,
        paused: null == paused
            ? _value.paused
            : paused // ignore: cast_nullable_to_non_nullable
                  as bool,
        remainingTime: null == remainingTime
            ? _value.remainingTime
            : remainingTime // ignore: cast_nullable_to_non_nullable
                  as int,
        lastUnpaused: null == lastUnpaused
            ? _value.lastUnpaused
            : lastUnpaused // ignore: cast_nullable_to_non_nullable
                  as int,
        allowRemoteGameCreation: null == allowRemoteGameCreation
            ? _value.allowRemoteGameCreation
            : allowRemoteGameCreation // ignore: cast_nullable_to_non_nullable
                  as bool,
        delay: null == delay
            ? _value.delay
            : delay // ignore: cast_nullable_to_non_nullable
                  as int,
        widgetScoreboard: null == widgetScoreboard
            ? _value.widgetScoreboard
            : widgetScoreboard // ignore: cast_nullable_to_non_nullable
                  as bool,
        widgetGameplan: null == widgetGameplan
            ? _value.widgetGameplan
            : widgetGameplan // ignore: cast_nullable_to_non_nullable
                  as bool,
        widgetLiveplan: null == widgetLiveplan
            ? _value.widgetLiveplan
            : widgetLiveplan // ignore: cast_nullable_to_non_nullable
                  as bool,
        widgetGamestart: null == widgetGamestart
            ? _value.widgetGamestart
            : widgetGamestart // ignore: cast_nullable_to_non_nullable
                  as bool,
        widgetAd: null == widgetAd
            ? _value.widgetAd
            : widgetAd // ignore: cast_nullable_to_non_nullable
                  as bool,
        streamStarted: null == streamStarted
            ? _value.streamStarted
            : streamStarted // ignore: cast_nullable_to_non_nullable
                  as bool,
        replayStarted: null == replayStarted
            ? _value.replayStarted
            : replayStarted // ignore: cast_nullable_to_non_nullable
                  as bool,
        formats: null == formats
            ? _value._formats
            : formats // ignore: cast_nullable_to_non_nullable
                  as List<Format>,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$MetaImpl implements _Meta {
  const _$MetaImpl({
    @JsonKey(name: 'game_i', toJson: intOrNullNot0) this.gameIndex = 0,
    @JsonKey(name: 'cur_gamepart', toJson: intOrNullNot0)
    this.currentGamepart = 0,
    @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
    this.sidesInverted = false,
    @JsonKey(toJson: boolOrNullFalse) this.paused = true,
    @JsonKey(name: 'remaining_time') this.remainingTime = 0,
    @JsonKey(name: 'last_unpaused') this.lastUnpaused = 0,
    @JsonKey(name: 'allow_remote_game_creation', toJson: boolOrNullTrue)
    this.allowRemoteGameCreation = false,
    @JsonKey(name: 'delay', toJson: null) this.delay = 0,
    this.widgetScoreboard = false,
    this.widgetGameplan = false,
    this.widgetLiveplan = false,
    this.widgetGamestart = false,
    this.widgetAd = false,
    this.streamStarted = false,
    this.replayStarted = false,
    required final List<Format> formats,
  }) : _formats = formats;

  factory _$MetaImpl.fromJson(Map<String, dynamic> json) =>
      _$$MetaImplFromJson(json);

  @override
  @JsonKey(name: 'game_i', toJson: intOrNullNot0)
  final int gameIndex;
  @override
  @JsonKey(name: 'cur_gamepart', toJson: intOrNullNot0)
  final int currentGamepart;
  // This is for an EXTRA invert, not the normal side switching.
  // The normal side switching is done through formats!
  // This is still needed, because maybe the teams are standing the other way around at the beginning
  @override
  @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
  final bool sidesInverted;
  @override
  @JsonKey(toJson: boolOrNullFalse)
  final bool paused;
  @override
  @JsonKey(name: 'remaining_time')
  final int remainingTime;
  @override
  @JsonKey(name: 'last_unpaused')
  final int lastUnpaused;
  @override
  @JsonKey(name: 'allow_remote_game_creation', toJson: boolOrNullTrue)
  final bool allowRemoteGameCreation;
  @override
  @JsonKey(name: 'delay', toJson: null)
  final int delay;
  @override
  @JsonKey()
  final bool widgetScoreboard;
  @override
  @JsonKey()
  final bool widgetGameplan;
  @override
  @JsonKey()
  final bool widgetLiveplan;
  @override
  @JsonKey()
  final bool widgetGamestart;
  @override
  @JsonKey()
  final bool widgetAd;
  @override
  @JsonKey()
  final bool streamStarted;
  @override
  @JsonKey()
  final bool replayStarted;
  final List<Format> _formats;
  @override
  List<Format> get formats {
    if (_formats is EqualUnmodifiableListView) return _formats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_formats);
  }

  @override
  String toString() {
    return 'Meta(gameIndex: $gameIndex, currentGamepart: $currentGamepart, sidesInverted: $sidesInverted, paused: $paused, remainingTime: $remainingTime, lastUnpaused: $lastUnpaused, allowRemoteGameCreation: $allowRemoteGameCreation, delay: $delay, widgetScoreboard: $widgetScoreboard, widgetGameplan: $widgetGameplan, widgetLiveplan: $widgetLiveplan, widgetGamestart: $widgetGamestart, widgetAd: $widgetAd, streamStarted: $streamStarted, replayStarted: $replayStarted, formats: $formats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MetaImpl &&
            (identical(other.gameIndex, gameIndex) ||
                other.gameIndex == gameIndex) &&
            (identical(other.currentGamepart, currentGamepart) ||
                other.currentGamepart == currentGamepart) &&
            (identical(other.sidesInverted, sidesInverted) ||
                other.sidesInverted == sidesInverted) &&
            (identical(other.paused, paused) || other.paused == paused) &&
            (identical(other.remainingTime, remainingTime) ||
                other.remainingTime == remainingTime) &&
            (identical(other.lastUnpaused, lastUnpaused) ||
                other.lastUnpaused == lastUnpaused) &&
            (identical(
                  other.allowRemoteGameCreation,
                  allowRemoteGameCreation,
                ) ||
                other.allowRemoteGameCreation == allowRemoteGameCreation) &&
            (identical(other.delay, delay) || other.delay == delay) &&
            (identical(other.widgetScoreboard, widgetScoreboard) ||
                other.widgetScoreboard == widgetScoreboard) &&
            (identical(other.widgetGameplan, widgetGameplan) ||
                other.widgetGameplan == widgetGameplan) &&
            (identical(other.widgetLiveplan, widgetLiveplan) ||
                other.widgetLiveplan == widgetLiveplan) &&
            (identical(other.widgetGamestart, widgetGamestart) ||
                other.widgetGamestart == widgetGamestart) &&
            (identical(other.widgetAd, widgetAd) ||
                other.widgetAd == widgetAd) &&
            (identical(other.streamStarted, streamStarted) ||
                other.streamStarted == streamStarted) &&
            (identical(other.replayStarted, replayStarted) ||
                other.replayStarted == replayStarted) &&
            const DeepCollectionEquality().equals(other._formats, _formats));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    gameIndex,
    currentGamepart,
    sidesInverted,
    paused,
    remainingTime,
    lastUnpaused,
    allowRemoteGameCreation,
    delay,
    widgetScoreboard,
    widgetGameplan,
    widgetLiveplan,
    widgetGamestart,
    widgetAd,
    streamStarted,
    replayStarted,
    const DeepCollectionEquality().hash(_formats),
  );

  /// Create a copy of Meta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MetaImplCopyWith<_$MetaImpl> get copyWith =>
      __$$MetaImplCopyWithImpl<_$MetaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MetaImplToJson(this);
  }
}

abstract class _Meta implements Meta {
  const factory _Meta({
    @JsonKey(name: 'game_i', toJson: intOrNullNot0) final int gameIndex,
    @JsonKey(name: 'cur_gamepart', toJson: intOrNullNot0)
    final int currentGamepart,
    @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
    final bool sidesInverted,
    @JsonKey(toJson: boolOrNullFalse) final bool paused,
    @JsonKey(name: 'remaining_time') final int remainingTime,
    @JsonKey(name: 'last_unpaused') final int lastUnpaused,
    @JsonKey(name: 'allow_remote_game_creation', toJson: boolOrNullTrue)
    final bool allowRemoteGameCreation,
    @JsonKey(name: 'delay', toJson: null) final int delay,
    final bool widgetScoreboard,
    final bool widgetGameplan,
    final bool widgetLiveplan,
    final bool widgetGamestart,
    final bool widgetAd,
    final bool streamStarted,
    final bool replayStarted,
    required final List<Format> formats,
  }) = _$MetaImpl;

  factory _Meta.fromJson(Map<String, dynamic> json) = _$MetaImpl.fromJson;

  @override
  @JsonKey(name: 'game_i', toJson: intOrNullNot0)
  int get gameIndex;
  @override
  @JsonKey(name: 'cur_gamepart', toJson: intOrNullNot0)
  int get currentGamepart; // This is for an EXTRA invert, not the normal side switching.
  // The normal side switching is done through formats!
  // This is still needed, because maybe the teams are standing the other way around at the beginning
  @override
  @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
  bool get sidesInverted;
  @override
  @JsonKey(toJson: boolOrNullFalse)
  bool get paused;
  @override
  @JsonKey(name: 'remaining_time')
  int get remainingTime;
  @override
  @JsonKey(name: 'last_unpaused')
  int get lastUnpaused;
  @override
  @JsonKey(name: 'allow_remote_game_creation', toJson: boolOrNullTrue)
  bool get allowRemoteGameCreation;
  @override
  @JsonKey(name: 'delay', toJson: null)
  int get delay;
  @override
  bool get widgetScoreboard;
  @override
  bool get widgetGameplan;
  @override
  bool get widgetLiveplan;
  @override
  bool get widgetGamestart;
  @override
  bool get widgetAd;
  @override
  bool get streamStarted;
  @override
  bool get replayStarted;
  @override
  List<Format> get formats;

  /// Create a copy of Meta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MetaImplCopyWith<_$MetaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Game _$GameFromJson(Map<String, dynamic> json) {
  return _Game.fromJson(json);
}

/// @nodoc
mixin _$Game {
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: '1')
  GameTeamSlot get team1 => throw _privateConstructorUsedError;
  @JsonKey(name: '2')
  GameTeamSlot get team2 => throw _privateConstructorUsedError;
  List<String>? get groups => throw _privateConstructorUsedError;
  GameFormat get format => throw _privateConstructorUsedError;
  @JsonKey(toJson: boolOrNullTrue)
  bool get decider => throw _privateConstructorUsedError;
  bool get protected => throw _privateConstructorUsedError;
  List<GameAction>? get actions => throw _privateConstructorUsedError;

  /// Serializes this Game to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameCopyWith<Game> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameCopyWith<$Res> {
  factory $GameCopyWith(Game value, $Res Function(Game) then) =
      _$GameCopyWithImpl<$Res, Game>;
  @useResult
  $Res call({
    String name,
    @JsonKey(name: '1') GameTeamSlot team1,
    @JsonKey(name: '2') GameTeamSlot team2,
    List<String>? groups,
    GameFormat format,
    @JsonKey(toJson: boolOrNullTrue) bool decider,
    bool protected,
    List<GameAction>? actions,
  });

  $GameTeamSlotCopyWith<$Res> get team1;
  $GameTeamSlotCopyWith<$Res> get team2;
  $GameFormatCopyWith<$Res> get format;
}

/// @nodoc
class _$GameCopyWithImpl<$Res, $Val extends Game>
    implements $GameCopyWith<$Res> {
  _$GameCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? team1 = null,
    Object? team2 = null,
    Object? groups = freezed,
    Object? format = null,
    Object? decider = null,
    Object? protected = null,
    Object? actions = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            team1: null == team1
                ? _value.team1
                : team1 // ignore: cast_nullable_to_non_nullable
                      as GameTeamSlot,
            team2: null == team2
                ? _value.team2
                : team2 // ignore: cast_nullable_to_non_nullable
                      as GameTeamSlot,
            groups: freezed == groups
                ? _value.groups
                : groups // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            format: null == format
                ? _value.format
                : format // ignore: cast_nullable_to_non_nullable
                      as GameFormat,
            decider: null == decider
                ? _value.decider
                : decider // ignore: cast_nullable_to_non_nullable
                      as bool,
            protected: null == protected
                ? _value.protected
                : protected // ignore: cast_nullable_to_non_nullable
                      as bool,
            actions: freezed == actions
                ? _value.actions
                : actions // ignore: cast_nullable_to_non_nullable
                      as List<GameAction>?,
          )
          as $Val,
    );
  }

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameTeamSlotCopyWith<$Res> get team1 {
    return $GameTeamSlotCopyWith<$Res>(_value.team1, (value) {
      return _then(_value.copyWith(team1: value) as $Val);
    });
  }

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameTeamSlotCopyWith<$Res> get team2 {
    return $GameTeamSlotCopyWith<$Res>(_value.team2, (value) {
      return _then(_value.copyWith(team2: value) as $Val);
    });
  }

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameFormatCopyWith<$Res> get format {
    return $GameFormatCopyWith<$Res>(_value.format, (value) {
      return _then(_value.copyWith(format: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameImplCopyWith<$Res> implements $GameCopyWith<$Res> {
  factory _$$GameImplCopyWith(
    _$GameImpl value,
    $Res Function(_$GameImpl) then,
  ) = __$$GameImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    @JsonKey(name: '1') GameTeamSlot team1,
    @JsonKey(name: '2') GameTeamSlot team2,
    List<String>? groups,
    GameFormat format,
    @JsonKey(toJson: boolOrNullTrue) bool decider,
    bool protected,
    List<GameAction>? actions,
  });

  @override
  $GameTeamSlotCopyWith<$Res> get team1;
  @override
  $GameTeamSlotCopyWith<$Res> get team2;
  @override
  $GameFormatCopyWith<$Res> get format;
}

/// @nodoc
class __$$GameImplCopyWithImpl<$Res>
    extends _$GameCopyWithImpl<$Res, _$GameImpl>
    implements _$$GameImplCopyWith<$Res> {
  __$$GameImplCopyWithImpl(_$GameImpl _value, $Res Function(_$GameImpl) _then)
    : super(_value, _then);

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? team1 = null,
    Object? team2 = null,
    Object? groups = freezed,
    Object? format = null,
    Object? decider = null,
    Object? protected = null,
    Object? actions = freezed,
  }) {
    return _then(
      _$GameImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        team1: null == team1
            ? _value.team1
            : team1 // ignore: cast_nullable_to_non_nullable
                  as GameTeamSlot,
        team2: null == team2
            ? _value.team2
            : team2 // ignore: cast_nullable_to_non_nullable
                  as GameTeamSlot,
        groups: freezed == groups
            ? _value._groups
            : groups // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        format: null == format
            ? _value.format
            : format // ignore: cast_nullable_to_non_nullable
                  as GameFormat,
        decider: null == decider
            ? _value.decider
            : decider // ignore: cast_nullable_to_non_nullable
                  as bool,
        protected: null == protected
            ? _value.protected
            : protected // ignore: cast_nullable_to_non_nullable
                  as bool,
        actions: freezed == actions
            ? _value._actions
            : actions // ignore: cast_nullable_to_non_nullable
                  as List<GameAction>?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$GameImpl extends _Game {
  const _$GameImpl({
    required this.name,
    @JsonKey(name: '1') required this.team1,
    @JsonKey(name: '2') required this.team2,
    final List<String>? groups,
    required this.format,
    @JsonKey(toJson: boolOrNullTrue) this.decider = false,
    this.protected = true,
    final List<GameAction>? actions,
  }) : _groups = groups,
       _actions = actions,
       super._();

  factory _$GameImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey(name: '1')
  final GameTeamSlot team1;
  @override
  @JsonKey(name: '2')
  final GameTeamSlot team2;
  final List<String>? _groups;
  @override
  List<String>? get groups {
    final value = _groups;
    if (value == null) return null;
    if (_groups is EqualUnmodifiableListView) return _groups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final GameFormat format;
  @override
  @JsonKey(toJson: boolOrNullTrue)
  final bool decider;
  @override
  @JsonKey()
  final bool protected;
  final List<GameAction>? _actions;
  @override
  List<GameAction>? get actions {
    final value = _actions;
    if (value == null) return null;
    if (_actions is EqualUnmodifiableListView) return _actions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'Game(name: $name, team1: $team1, team2: $team2, groups: $groups, format: $format, decider: $decider, protected: $protected, actions: $actions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.team1, team1) || other.team1 == team1) &&
            (identical(other.team2, team2) || other.team2 == team2) &&
            const DeepCollectionEquality().equals(other._groups, _groups) &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.decider, decider) || other.decider == decider) &&
            (identical(other.protected, protected) ||
                other.protected == protected) &&
            const DeepCollectionEquality().equals(other._actions, _actions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    team1,
    team2,
    const DeepCollectionEquality().hash(_groups),
    format,
    decider,
    protected,
    const DeepCollectionEquality().hash(_actions),
  );

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameImplCopyWith<_$GameImpl> get copyWith =>
      __$$GameImplCopyWithImpl<_$GameImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameImplToJson(this);
  }
}

abstract class _Game extends Game {
  const factory _Game({
    required final String name,
    @JsonKey(name: '1') required final GameTeamSlot team1,
    @JsonKey(name: '2') required final GameTeamSlot team2,
    final List<String>? groups,
    required final GameFormat format,
    @JsonKey(toJson: boolOrNullTrue) final bool decider,
    final bool protected,
    final List<GameAction>? actions,
  }) = _$GameImpl;
  const _Game._() : super._();

  factory _Game.fromJson(Map<String, dynamic> json) = _$GameImpl.fromJson;

  @override
  String get name;
  @override
  @JsonKey(name: '1')
  GameTeamSlot get team1;
  @override
  @JsonKey(name: '2')
  GameTeamSlot get team2;
  @override
  List<String>? get groups;
  @override
  GameFormat get format;
  @override
  @JsonKey(toJson: boolOrNullTrue)
  bool get decider;
  @override
  bool get protected;
  @override
  List<GameAction>? get actions;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameImplCopyWith<_$GameImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameAction _$GameActionFromJson(Map<String, dynamic> json) {
  switch (json['type']) {
    case 'goal':
      return _GameActionGoal.fromJson(json);
    case 'foul':
      return _GameActionFoul.fromJson(json);
    case 'penalty':
      return _GameActionPenalty.fromJson(json);
    case 'outball':
      return _GameActionOutball.fromJson(json);

    default:
      throw CheckedFromJsonException(
        json,
        'type',
        'GameAction',
        'Invalid union type "${json['type']}"!',
      );
  }
}

/// @nodoc
mixin _$GameAction {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "time_game")
  int? get timeGame => throw _privateConstructorUsedError;
  @JsonKey(name: "timespan_game")
  int? get timespanGame => throw _privateConstructorUsedError;
  @JsonKey(name: "time_unix")
  int? get timeUnix => throw _privateConstructorUsedError;
  @JsonKey(name: "timespan_unix")
  int? get timespanUnix => throw _privateConstructorUsedError;
  List<GameActionPlayerInvolved>? get players_involved =>
      throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(toJson: boolOrNullFalse)
  bool get done => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      GameActionChange change,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )
    goal,
    required TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )
    foul,
    required TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )
    penalty,
    required TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      int team,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )
    outball,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      GameActionChange change,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    goal,
    TResult? Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    foul,
    TResult? Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    penalty,
    TResult? Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      int team,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    outball,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      GameActionChange change,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    goal,
    TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    foul,
    TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    penalty,
    TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      int team,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    outball,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GameActionGoal value) goal,
    required TResult Function(_GameActionFoul value) foul,
    required TResult Function(_GameActionPenalty value) penalty,
    required TResult Function(_GameActionOutball value) outball,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GameActionGoal value)? goal,
    TResult? Function(_GameActionFoul value)? foul,
    TResult? Function(_GameActionPenalty value)? penalty,
    TResult? Function(_GameActionOutball value)? outball,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GameActionGoal value)? goal,
    TResult Function(_GameActionFoul value)? foul,
    TResult Function(_GameActionPenalty value)? penalty,
    TResult Function(_GameActionOutball value)? outball,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this GameAction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameActionCopyWith<GameAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameActionCopyWith<$Res> {
  factory $GameActionCopyWith(
    GameAction value,
    $Res Function(GameAction) then,
  ) = _$GameActionCopyWithImpl<$Res, GameAction>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: "time_game") int? timeGame,
    @JsonKey(name: "timespan_game") int? timespanGame,
    @JsonKey(name: "time_unix") int? timeUnix,
    @JsonKey(name: "timespan_unix") int? timespanUnix,
    List<GameActionPlayerInvolved>? players_involved,
    String? description,
    @JsonKey(toJson: boolOrNullFalse) bool done,
  });
}

/// @nodoc
class _$GameActionCopyWithImpl<$Res, $Val extends GameAction>
    implements $GameActionCopyWith<$Res> {
  _$GameActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? timeGame = freezed,
    Object? timespanGame = freezed,
    Object? timeUnix = freezed,
    Object? timespanUnix = freezed,
    Object? players_involved = freezed,
    Object? description = freezed,
    Object? done = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            timeGame: freezed == timeGame
                ? _value.timeGame
                : timeGame // ignore: cast_nullable_to_non_nullable
                      as int?,
            timespanGame: freezed == timespanGame
                ? _value.timespanGame
                : timespanGame // ignore: cast_nullable_to_non_nullable
                      as int?,
            timeUnix: freezed == timeUnix
                ? _value.timeUnix
                : timeUnix // ignore: cast_nullable_to_non_nullable
                      as int?,
            timespanUnix: freezed == timespanUnix
                ? _value.timespanUnix
                : timespanUnix // ignore: cast_nullable_to_non_nullable
                      as int?,
            players_involved: freezed == players_involved
                ? _value.players_involved
                : players_involved // ignore: cast_nullable_to_non_nullable
                      as List<GameActionPlayerInvolved>?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            done: null == done
                ? _value.done
                : done // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameActionGoalImplCopyWith<$Res>
    implements $GameActionCopyWith<$Res> {
  factory _$$GameActionGoalImplCopyWith(
    _$GameActionGoalImpl value,
    $Res Function(_$GameActionGoalImpl) then,
  ) = __$$GameActionGoalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: "time_game") int? timeGame,
    @JsonKey(name: "timespan_game") int? timespanGame,
    @JsonKey(name: "time_unix") int? timeUnix,
    @JsonKey(name: "timespan_unix") int? timespanUnix,
    List<GameActionPlayerInvolved>? players_involved,
    GameActionChange change,
    @JsonKey(name: "triggers_action") int? triggersAction,
    String? description,
    @JsonKey(toJson: boolOrNullFalse) bool done,
  });

  $GameActionChangeCopyWith<$Res> get change;
}

/// @nodoc
class __$$GameActionGoalImplCopyWithImpl<$Res>
    extends _$GameActionCopyWithImpl<$Res, _$GameActionGoalImpl>
    implements _$$GameActionGoalImplCopyWith<$Res> {
  __$$GameActionGoalImplCopyWithImpl(
    _$GameActionGoalImpl _value,
    $Res Function(_$GameActionGoalImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? timeGame = freezed,
    Object? timespanGame = freezed,
    Object? timeUnix = freezed,
    Object? timespanUnix = freezed,
    Object? players_involved = freezed,
    Object? change = null,
    Object? triggersAction = freezed,
    Object? description = freezed,
    Object? done = null,
  }) {
    return _then(
      _$GameActionGoalImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        timeGame: freezed == timeGame
            ? _value.timeGame
            : timeGame // ignore: cast_nullable_to_non_nullable
                  as int?,
        timespanGame: freezed == timespanGame
            ? _value.timespanGame
            : timespanGame // ignore: cast_nullable_to_non_nullable
                  as int?,
        timeUnix: freezed == timeUnix
            ? _value.timeUnix
            : timeUnix // ignore: cast_nullable_to_non_nullable
                  as int?,
        timespanUnix: freezed == timespanUnix
            ? _value.timespanUnix
            : timespanUnix // ignore: cast_nullable_to_non_nullable
                  as int?,
        players_involved: freezed == players_involved
            ? _value._players_involved
            : players_involved // ignore: cast_nullable_to_non_nullable
                  as List<GameActionPlayerInvolved>?,
        change: null == change
            ? _value.change
            : change // ignore: cast_nullable_to_non_nullable
                  as GameActionChange,
        triggersAction: freezed == triggersAction
            ? _value.triggersAction
            : triggersAction // ignore: cast_nullable_to_non_nullable
                  as int?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        done: null == done
            ? _value.done
            : done // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameActionChangeCopyWith<$Res> get change {
    return $GameActionChangeCopyWith<$Res>(_value.change, (value) {
      return _then(_value.copyWith(change: value));
    });
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$GameActionGoalImpl implements _GameActionGoal {
  const _$GameActionGoalImpl({
    required this.id,
    @JsonKey(name: "time_game") this.timeGame,
    @JsonKey(name: "timespan_game") this.timespanGame,
    @JsonKey(name: "time_unix") this.timeUnix,
    @JsonKey(name: "timespan_unix") this.timespanUnix,
    final List<GameActionPlayerInvolved>? players_involved,
    required this.change,
    @JsonKey(name: "triggers_action") this.triggersAction,
    this.description,
    @JsonKey(toJson: boolOrNullFalse) this.done = true,
    final String? $type,
  }) : _players_involved = players_involved,
       $type = $type ?? 'goal';

  factory _$GameActionGoalImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameActionGoalImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: "time_game")
  final int? timeGame;
  @override
  @JsonKey(name: "timespan_game")
  final int? timespanGame;
  @override
  @JsonKey(name: "time_unix")
  final int? timeUnix;
  @override
  @JsonKey(name: "timespan_unix")
  final int? timespanUnix;
  final List<GameActionPlayerInvolved>? _players_involved;
  @override
  List<GameActionPlayerInvolved>? get players_involved {
    final value = _players_involved;
    if (value == null) return null;
    if (_players_involved is EqualUnmodifiableListView)
      return _players_involved;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final GameActionChange change;
  @override
  @JsonKey(name: "triggers_action")
  final int? triggersAction;
  @override
  final String? description;
  @override
  @JsonKey(toJson: boolOrNullFalse)
  final bool done;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'GameAction.goal(id: $id, timeGame: $timeGame, timespanGame: $timespanGame, timeUnix: $timeUnix, timespanUnix: $timespanUnix, players_involved: $players_involved, change: $change, triggersAction: $triggersAction, description: $description, done: $done)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameActionGoalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.timeGame, timeGame) ||
                other.timeGame == timeGame) &&
            (identical(other.timespanGame, timespanGame) ||
                other.timespanGame == timespanGame) &&
            (identical(other.timeUnix, timeUnix) ||
                other.timeUnix == timeUnix) &&
            (identical(other.timespanUnix, timespanUnix) ||
                other.timespanUnix == timespanUnix) &&
            const DeepCollectionEquality().equals(
              other._players_involved,
              _players_involved,
            ) &&
            (identical(other.change, change) || other.change == change) &&
            (identical(other.triggersAction, triggersAction) ||
                other.triggersAction == triggersAction) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.done, done) || other.done == done));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    timeGame,
    timespanGame,
    timeUnix,
    timespanUnix,
    const DeepCollectionEquality().hash(_players_involved),
    change,
    triggersAction,
    description,
    done,
  );

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameActionGoalImplCopyWith<_$GameActionGoalImpl> get copyWith =>
      __$$GameActionGoalImplCopyWithImpl<_$GameActionGoalImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      GameActionChange change,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )
    goal,
    required TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )
    foul,
    required TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )
    penalty,
    required TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      int team,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )
    outball,
  }) {
    return goal(
      id,
      timeGame,
      timespanGame,
      timeUnix,
      timespanUnix,
      players_involved,
      change,
      triggersAction,
      description,
      done,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      GameActionChange change,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    goal,
    TResult? Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    foul,
    TResult? Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    penalty,
    TResult? Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      int team,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    outball,
  }) {
    return goal?.call(
      id,
      timeGame,
      timespanGame,
      timeUnix,
      timespanUnix,
      players_involved,
      change,
      triggersAction,
      description,
      done,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      GameActionChange change,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    goal,
    TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    foul,
    TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    penalty,
    TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      int team,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    outball,
    required TResult orElse(),
  }) {
    if (goal != null) {
      return goal(
        id,
        timeGame,
        timespanGame,
        timeUnix,
        timespanUnix,
        players_involved,
        change,
        triggersAction,
        description,
        done,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GameActionGoal value) goal,
    required TResult Function(_GameActionFoul value) foul,
    required TResult Function(_GameActionPenalty value) penalty,
    required TResult Function(_GameActionOutball value) outball,
  }) {
    return goal(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GameActionGoal value)? goal,
    TResult? Function(_GameActionFoul value)? foul,
    TResult? Function(_GameActionPenalty value)? penalty,
    TResult? Function(_GameActionOutball value)? outball,
  }) {
    return goal?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GameActionGoal value)? goal,
    TResult Function(_GameActionFoul value)? foul,
    TResult Function(_GameActionPenalty value)? penalty,
    TResult Function(_GameActionOutball value)? outball,
    required TResult orElse(),
  }) {
    if (goal != null) {
      return goal(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$GameActionGoalImplToJson(this);
  }
}

abstract class _GameActionGoal implements GameAction {
  const factory _GameActionGoal({
    required final int id,
    @JsonKey(name: "time_game") final int? timeGame,
    @JsonKey(name: "timespan_game") final int? timespanGame,
    @JsonKey(name: "time_unix") final int? timeUnix,
    @JsonKey(name: "timespan_unix") final int? timespanUnix,
    final List<GameActionPlayerInvolved>? players_involved,
    required final GameActionChange change,
    @JsonKey(name: "triggers_action") final int? triggersAction,
    final String? description,
    @JsonKey(toJson: boolOrNullFalse) final bool done,
  }) = _$GameActionGoalImpl;

  factory _GameActionGoal.fromJson(Map<String, dynamic> json) =
      _$GameActionGoalImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: "time_game")
  int? get timeGame;
  @override
  @JsonKey(name: "timespan_game")
  int? get timespanGame;
  @override
  @JsonKey(name: "time_unix")
  int? get timeUnix;
  @override
  @JsonKey(name: "timespan_unix")
  int? get timespanUnix;
  @override
  List<GameActionPlayerInvolved>? get players_involved;
  GameActionChange get change;
  @JsonKey(name: "triggers_action")
  int? get triggersAction;
  @override
  String? get description;
  @override
  @JsonKey(toJson: boolOrNullFalse)
  bool get done;

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameActionGoalImplCopyWith<_$GameActionGoalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GameActionFoulImplCopyWith<$Res>
    implements $GameActionCopyWith<$Res> {
  factory _$$GameActionFoulImplCopyWith(
    _$GameActionFoulImpl value,
    $Res Function(_$GameActionFoulImpl) then,
  ) = __$$GameActionFoulImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: "time_game") int? timeGame,
    @JsonKey(name: "timespan_game") int? timespanGame,
    @JsonKey(name: "time_unix") int? timeUnix,
    @JsonKey(name: "timespan_unix") int? timespanUnix,
    List<GameActionPlayerInvolved>? players_involved,
    @JsonKey(name: "triggers_action") int? triggersAction,
    String? description,
    @JsonKey(toJson: boolOrNullFalse) bool done,
  });
}

/// @nodoc
class __$$GameActionFoulImplCopyWithImpl<$Res>
    extends _$GameActionCopyWithImpl<$Res, _$GameActionFoulImpl>
    implements _$$GameActionFoulImplCopyWith<$Res> {
  __$$GameActionFoulImplCopyWithImpl(
    _$GameActionFoulImpl _value,
    $Res Function(_$GameActionFoulImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? timeGame = freezed,
    Object? timespanGame = freezed,
    Object? timeUnix = freezed,
    Object? timespanUnix = freezed,
    Object? players_involved = freezed,
    Object? triggersAction = freezed,
    Object? description = freezed,
    Object? done = null,
  }) {
    return _then(
      _$GameActionFoulImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        timeGame: freezed == timeGame
            ? _value.timeGame
            : timeGame // ignore: cast_nullable_to_non_nullable
                  as int?,
        timespanGame: freezed == timespanGame
            ? _value.timespanGame
            : timespanGame // ignore: cast_nullable_to_non_nullable
                  as int?,
        timeUnix: freezed == timeUnix
            ? _value.timeUnix
            : timeUnix // ignore: cast_nullable_to_non_nullable
                  as int?,
        timespanUnix: freezed == timespanUnix
            ? _value.timespanUnix
            : timespanUnix // ignore: cast_nullable_to_non_nullable
                  as int?,
        players_involved: freezed == players_involved
            ? _value._players_involved
            : players_involved // ignore: cast_nullable_to_non_nullable
                  as List<GameActionPlayerInvolved>?,
        triggersAction: freezed == triggersAction
            ? _value.triggersAction
            : triggersAction // ignore: cast_nullable_to_non_nullable
                  as int?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        done: null == done
            ? _value.done
            : done // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$GameActionFoulImpl implements _GameActionFoul {
  const _$GameActionFoulImpl({
    required this.id,
    @JsonKey(name: "time_game") this.timeGame,
    @JsonKey(name: "timespan_game") this.timespanGame,
    @JsonKey(name: "time_unix") this.timeUnix,
    @JsonKey(name: "timespan_unix") this.timespanUnix,
    final List<GameActionPlayerInvolved>? players_involved,
    @JsonKey(name: "triggers_action") this.triggersAction,
    this.description,
    @JsonKey(toJson: boolOrNullFalse) this.done = true,
    final String? $type,
  }) : _players_involved = players_involved,
       $type = $type ?? 'foul';

  factory _$GameActionFoulImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameActionFoulImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: "time_game")
  final int? timeGame;
  @override
  @JsonKey(name: "timespan_game")
  final int? timespanGame;
  @override
  @JsonKey(name: "time_unix")
  final int? timeUnix;
  @override
  @JsonKey(name: "timespan_unix")
  final int? timespanUnix;
  final List<GameActionPlayerInvolved>? _players_involved;
  @override
  List<GameActionPlayerInvolved>? get players_involved {
    final value = _players_involved;
    if (value == null) return null;
    if (_players_involved is EqualUnmodifiableListView)
      return _players_involved;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: "triggers_action")
  final int? triggersAction;
  @override
  final String? description;
  @override
  @JsonKey(toJson: boolOrNullFalse)
  final bool done;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'GameAction.foul(id: $id, timeGame: $timeGame, timespanGame: $timespanGame, timeUnix: $timeUnix, timespanUnix: $timespanUnix, players_involved: $players_involved, triggersAction: $triggersAction, description: $description, done: $done)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameActionFoulImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.timeGame, timeGame) ||
                other.timeGame == timeGame) &&
            (identical(other.timespanGame, timespanGame) ||
                other.timespanGame == timespanGame) &&
            (identical(other.timeUnix, timeUnix) ||
                other.timeUnix == timeUnix) &&
            (identical(other.timespanUnix, timespanUnix) ||
                other.timespanUnix == timespanUnix) &&
            const DeepCollectionEquality().equals(
              other._players_involved,
              _players_involved,
            ) &&
            (identical(other.triggersAction, triggersAction) ||
                other.triggersAction == triggersAction) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.done, done) || other.done == done));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    timeGame,
    timespanGame,
    timeUnix,
    timespanUnix,
    const DeepCollectionEquality().hash(_players_involved),
    triggersAction,
    description,
    done,
  );

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameActionFoulImplCopyWith<_$GameActionFoulImpl> get copyWith =>
      __$$GameActionFoulImplCopyWithImpl<_$GameActionFoulImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      GameActionChange change,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )
    goal,
    required TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )
    foul,
    required TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )
    penalty,
    required TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      int team,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )
    outball,
  }) {
    return foul(
      id,
      timeGame,
      timespanGame,
      timeUnix,
      timespanUnix,
      players_involved,
      triggersAction,
      description,
      done,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      GameActionChange change,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    goal,
    TResult? Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    foul,
    TResult? Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    penalty,
    TResult? Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      int team,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    outball,
  }) {
    return foul?.call(
      id,
      timeGame,
      timespanGame,
      timeUnix,
      timespanUnix,
      players_involved,
      triggersAction,
      description,
      done,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      GameActionChange change,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    goal,
    TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    foul,
    TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    penalty,
    TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      int team,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    outball,
    required TResult orElse(),
  }) {
    if (foul != null) {
      return foul(
        id,
        timeGame,
        timespanGame,
        timeUnix,
        timespanUnix,
        players_involved,
        triggersAction,
        description,
        done,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GameActionGoal value) goal,
    required TResult Function(_GameActionFoul value) foul,
    required TResult Function(_GameActionPenalty value) penalty,
    required TResult Function(_GameActionOutball value) outball,
  }) {
    return foul(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GameActionGoal value)? goal,
    TResult? Function(_GameActionFoul value)? foul,
    TResult? Function(_GameActionPenalty value)? penalty,
    TResult? Function(_GameActionOutball value)? outball,
  }) {
    return foul?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GameActionGoal value)? goal,
    TResult Function(_GameActionFoul value)? foul,
    TResult Function(_GameActionPenalty value)? penalty,
    TResult Function(_GameActionOutball value)? outball,
    required TResult orElse(),
  }) {
    if (foul != null) {
      return foul(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$GameActionFoulImplToJson(this);
  }
}

abstract class _GameActionFoul implements GameAction {
  const factory _GameActionFoul({
    required final int id,
    @JsonKey(name: "time_game") final int? timeGame,
    @JsonKey(name: "timespan_game") final int? timespanGame,
    @JsonKey(name: "time_unix") final int? timeUnix,
    @JsonKey(name: "timespan_unix") final int? timespanUnix,
    final List<GameActionPlayerInvolved>? players_involved,
    @JsonKey(name: "triggers_action") final int? triggersAction,
    final String? description,
    @JsonKey(toJson: boolOrNullFalse) final bool done,
  }) = _$GameActionFoulImpl;

  factory _GameActionFoul.fromJson(Map<String, dynamic> json) =
      _$GameActionFoulImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: "time_game")
  int? get timeGame;
  @override
  @JsonKey(name: "timespan_game")
  int? get timespanGame;
  @override
  @JsonKey(name: "time_unix")
  int? get timeUnix;
  @override
  @JsonKey(name: "timespan_unix")
  int? get timespanUnix;
  @override
  List<GameActionPlayerInvolved>? get players_involved;
  @JsonKey(name: "triggers_action")
  int? get triggersAction;
  @override
  String? get description;
  @override
  @JsonKey(toJson: boolOrNullFalse)
  bool get done;

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameActionFoulImplCopyWith<_$GameActionFoulImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GameActionPenaltyImplCopyWith<$Res>
    implements $GameActionCopyWith<$Res> {
  factory _$$GameActionPenaltyImplCopyWith(
    _$GameActionPenaltyImpl value,
    $Res Function(_$GameActionPenaltyImpl) then,
  ) = __$$GameActionPenaltyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: "time_game") int? timeGame,
    @JsonKey(name: "timespan_game") int? timespanGame,
    @JsonKey(name: "time_unix") int? timeUnix,
    @JsonKey(name: "timespan_unix") int? timespanUnix,
    List<GameActionPlayerInvolved>? players_involved,
    String? description,
    @JsonKey(toJson: boolOrNullFalse) bool done,
  });
}

/// @nodoc
class __$$GameActionPenaltyImplCopyWithImpl<$Res>
    extends _$GameActionCopyWithImpl<$Res, _$GameActionPenaltyImpl>
    implements _$$GameActionPenaltyImplCopyWith<$Res> {
  __$$GameActionPenaltyImplCopyWithImpl(
    _$GameActionPenaltyImpl _value,
    $Res Function(_$GameActionPenaltyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? timeGame = freezed,
    Object? timespanGame = freezed,
    Object? timeUnix = freezed,
    Object? timespanUnix = freezed,
    Object? players_involved = freezed,
    Object? description = freezed,
    Object? done = null,
  }) {
    return _then(
      _$GameActionPenaltyImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        timeGame: freezed == timeGame
            ? _value.timeGame
            : timeGame // ignore: cast_nullable_to_non_nullable
                  as int?,
        timespanGame: freezed == timespanGame
            ? _value.timespanGame
            : timespanGame // ignore: cast_nullable_to_non_nullable
                  as int?,
        timeUnix: freezed == timeUnix
            ? _value.timeUnix
            : timeUnix // ignore: cast_nullable_to_non_nullable
                  as int?,
        timespanUnix: freezed == timespanUnix
            ? _value.timespanUnix
            : timespanUnix // ignore: cast_nullable_to_non_nullable
                  as int?,
        players_involved: freezed == players_involved
            ? _value._players_involved
            : players_involved // ignore: cast_nullable_to_non_nullable
                  as List<GameActionPlayerInvolved>?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        done: null == done
            ? _value.done
            : done // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$GameActionPenaltyImpl implements _GameActionPenalty {
  const _$GameActionPenaltyImpl({
    required this.id,
    @JsonKey(name: "time_game") this.timeGame,
    @JsonKey(name: "timespan_game") this.timespanGame,
    @JsonKey(name: "time_unix") this.timeUnix,
    @JsonKey(name: "timespan_unix") this.timespanUnix,
    final List<GameActionPlayerInvolved>? players_involved,
    this.description,
    @JsonKey(toJson: boolOrNullFalse) this.done = true,
    final String? $type,
  }) : _players_involved = players_involved,
       $type = $type ?? 'penalty';

  factory _$GameActionPenaltyImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameActionPenaltyImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: "time_game")
  final int? timeGame;
  @override
  @JsonKey(name: "timespan_game")
  final int? timespanGame;
  @override
  @JsonKey(name: "time_unix")
  final int? timeUnix;
  @override
  @JsonKey(name: "timespan_unix")
  final int? timespanUnix;
  final List<GameActionPlayerInvolved>? _players_involved;
  @override
  List<GameActionPlayerInvolved>? get players_involved {
    final value = _players_involved;
    if (value == null) return null;
    if (_players_involved is EqualUnmodifiableListView)
      return _players_involved;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? description;
  @override
  @JsonKey(toJson: boolOrNullFalse)
  final bool done;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'GameAction.penalty(id: $id, timeGame: $timeGame, timespanGame: $timespanGame, timeUnix: $timeUnix, timespanUnix: $timespanUnix, players_involved: $players_involved, description: $description, done: $done)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameActionPenaltyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.timeGame, timeGame) ||
                other.timeGame == timeGame) &&
            (identical(other.timespanGame, timespanGame) ||
                other.timespanGame == timespanGame) &&
            (identical(other.timeUnix, timeUnix) ||
                other.timeUnix == timeUnix) &&
            (identical(other.timespanUnix, timespanUnix) ||
                other.timespanUnix == timespanUnix) &&
            const DeepCollectionEquality().equals(
              other._players_involved,
              _players_involved,
            ) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.done, done) || other.done == done));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    timeGame,
    timespanGame,
    timeUnix,
    timespanUnix,
    const DeepCollectionEquality().hash(_players_involved),
    description,
    done,
  );

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameActionPenaltyImplCopyWith<_$GameActionPenaltyImpl> get copyWith =>
      __$$GameActionPenaltyImplCopyWithImpl<_$GameActionPenaltyImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      GameActionChange change,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )
    goal,
    required TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )
    foul,
    required TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )
    penalty,
    required TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      int team,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )
    outball,
  }) {
    return penalty(
      id,
      timeGame,
      timespanGame,
      timeUnix,
      timespanUnix,
      players_involved,
      description,
      done,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      GameActionChange change,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    goal,
    TResult? Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    foul,
    TResult? Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    penalty,
    TResult? Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      int team,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    outball,
  }) {
    return penalty?.call(
      id,
      timeGame,
      timespanGame,
      timeUnix,
      timespanUnix,
      players_involved,
      description,
      done,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      GameActionChange change,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    goal,
    TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    foul,
    TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    penalty,
    TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      int team,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    outball,
    required TResult orElse(),
  }) {
    if (penalty != null) {
      return penalty(
        id,
        timeGame,
        timespanGame,
        timeUnix,
        timespanUnix,
        players_involved,
        description,
        done,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GameActionGoal value) goal,
    required TResult Function(_GameActionFoul value) foul,
    required TResult Function(_GameActionPenalty value) penalty,
    required TResult Function(_GameActionOutball value) outball,
  }) {
    return penalty(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GameActionGoal value)? goal,
    TResult? Function(_GameActionFoul value)? foul,
    TResult? Function(_GameActionPenalty value)? penalty,
    TResult? Function(_GameActionOutball value)? outball,
  }) {
    return penalty?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GameActionGoal value)? goal,
    TResult Function(_GameActionFoul value)? foul,
    TResult Function(_GameActionPenalty value)? penalty,
    TResult Function(_GameActionOutball value)? outball,
    required TResult orElse(),
  }) {
    if (penalty != null) {
      return penalty(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$GameActionPenaltyImplToJson(this);
  }
}

abstract class _GameActionPenalty implements GameAction {
  const factory _GameActionPenalty({
    required final int id,
    @JsonKey(name: "time_game") final int? timeGame,
    @JsonKey(name: "timespan_game") final int? timespanGame,
    @JsonKey(name: "time_unix") final int? timeUnix,
    @JsonKey(name: "timespan_unix") final int? timespanUnix,
    final List<GameActionPlayerInvolved>? players_involved,
    final String? description,
    @JsonKey(toJson: boolOrNullFalse) final bool done,
  }) = _$GameActionPenaltyImpl;

  factory _GameActionPenalty.fromJson(Map<String, dynamic> json) =
      _$GameActionPenaltyImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: "time_game")
  int? get timeGame;
  @override
  @JsonKey(name: "timespan_game")
  int? get timespanGame;
  @override
  @JsonKey(name: "time_unix")
  int? get timeUnix;
  @override
  @JsonKey(name: "timespan_unix")
  int? get timespanUnix;
  @override
  List<GameActionPlayerInvolved>? get players_involved;
  @override
  String? get description;
  @override
  @JsonKey(toJson: boolOrNullFalse)
  bool get done;

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameActionPenaltyImplCopyWith<_$GameActionPenaltyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GameActionOutballImplCopyWith<$Res>
    implements $GameActionCopyWith<$Res> {
  factory _$$GameActionOutballImplCopyWith(
    _$GameActionOutballImpl value,
    $Res Function(_$GameActionOutballImpl) then,
  ) = __$$GameActionOutballImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: "time_game") int? timeGame,
    @JsonKey(name: "timespan_game") int? timespanGame,
    @JsonKey(name: "time_unix") int? timeUnix,
    @JsonKey(name: "timespan_unix") int? timespanUnix,
    List<GameActionPlayerInvolved>? players_involved,
    int team,
    String? description,
    @JsonKey(toJson: boolOrNullFalse) bool done,
  });
}

/// @nodoc
class __$$GameActionOutballImplCopyWithImpl<$Res>
    extends _$GameActionCopyWithImpl<$Res, _$GameActionOutballImpl>
    implements _$$GameActionOutballImplCopyWith<$Res> {
  __$$GameActionOutballImplCopyWithImpl(
    _$GameActionOutballImpl _value,
    $Res Function(_$GameActionOutballImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? timeGame = freezed,
    Object? timespanGame = freezed,
    Object? timeUnix = freezed,
    Object? timespanUnix = freezed,
    Object? players_involved = freezed,
    Object? team = null,
    Object? description = freezed,
    Object? done = null,
  }) {
    return _then(
      _$GameActionOutballImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        timeGame: freezed == timeGame
            ? _value.timeGame
            : timeGame // ignore: cast_nullable_to_non_nullable
                  as int?,
        timespanGame: freezed == timespanGame
            ? _value.timespanGame
            : timespanGame // ignore: cast_nullable_to_non_nullable
                  as int?,
        timeUnix: freezed == timeUnix
            ? _value.timeUnix
            : timeUnix // ignore: cast_nullable_to_non_nullable
                  as int?,
        timespanUnix: freezed == timespanUnix
            ? _value.timespanUnix
            : timespanUnix // ignore: cast_nullable_to_non_nullable
                  as int?,
        players_involved: freezed == players_involved
            ? _value._players_involved
            : players_involved // ignore: cast_nullable_to_non_nullable
                  as List<GameActionPlayerInvolved>?,
        team: null == team
            ? _value.team
            : team // ignore: cast_nullable_to_non_nullable
                  as int,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        done: null == done
            ? _value.done
            : done // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$GameActionOutballImpl implements _GameActionOutball {
  const _$GameActionOutballImpl({
    required this.id,
    @JsonKey(name: "time_game") this.timeGame,
    @JsonKey(name: "timespan_game") this.timespanGame,
    @JsonKey(name: "time_unix") this.timeUnix,
    @JsonKey(name: "timespan_unix") this.timespanUnix,
    final List<GameActionPlayerInvolved>? players_involved,
    required this.team,
    this.description,
    @JsonKey(toJson: boolOrNullFalse) this.done = true,
    final String? $type,
  }) : _players_involved = players_involved,
       $type = $type ?? 'outball';

  factory _$GameActionOutballImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameActionOutballImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: "time_game")
  final int? timeGame;
  @override
  @JsonKey(name: "timespan_game")
  final int? timespanGame;
  @override
  @JsonKey(name: "time_unix")
  final int? timeUnix;
  @override
  @JsonKey(name: "timespan_unix")
  final int? timespanUnix;
  final List<GameActionPlayerInvolved>? _players_involved;
  @override
  List<GameActionPlayerInvolved>? get players_involved {
    final value = _players_involved;
    if (value == null) return null;
    if (_players_involved is EqualUnmodifiableListView)
      return _players_involved;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int team;
  // either 1 or 2 for the equivalent team
  @override
  final String? description;
  @override
  @JsonKey(toJson: boolOrNullFalse)
  final bool done;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'GameAction.outball(id: $id, timeGame: $timeGame, timespanGame: $timespanGame, timeUnix: $timeUnix, timespanUnix: $timespanUnix, players_involved: $players_involved, team: $team, description: $description, done: $done)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameActionOutballImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.timeGame, timeGame) ||
                other.timeGame == timeGame) &&
            (identical(other.timespanGame, timespanGame) ||
                other.timespanGame == timespanGame) &&
            (identical(other.timeUnix, timeUnix) ||
                other.timeUnix == timeUnix) &&
            (identical(other.timespanUnix, timespanUnix) ||
                other.timespanUnix == timespanUnix) &&
            const DeepCollectionEquality().equals(
              other._players_involved,
              _players_involved,
            ) &&
            (identical(other.team, team) || other.team == team) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.done, done) || other.done == done));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    timeGame,
    timespanGame,
    timeUnix,
    timespanUnix,
    const DeepCollectionEquality().hash(_players_involved),
    team,
    description,
    done,
  );

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameActionOutballImplCopyWith<_$GameActionOutballImpl> get copyWith =>
      __$$GameActionOutballImplCopyWithImpl<_$GameActionOutballImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      GameActionChange change,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )
    goal,
    required TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )
    foul,
    required TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )
    penalty,
    required TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      int team,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )
    outball,
  }) {
    return outball(
      id,
      timeGame,
      timespanGame,
      timeUnix,
      timespanUnix,
      players_involved,
      team,
      description,
      done,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      GameActionChange change,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    goal,
    TResult? Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    foul,
    TResult? Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    penalty,
    TResult? Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      int team,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    outball,
  }) {
    return outball?.call(
      id,
      timeGame,
      timespanGame,
      timeUnix,
      timespanUnix,
      players_involved,
      team,
      description,
      done,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      GameActionChange change,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    goal,
    TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      @JsonKey(name: "triggers_action") int? triggersAction,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    foul,
    TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    penalty,
    TResult Function(
      int id,
      @JsonKey(name: "time_game") int? timeGame,
      @JsonKey(name: "timespan_game") int? timespanGame,
      @JsonKey(name: "time_unix") int? timeUnix,
      @JsonKey(name: "timespan_unix") int? timespanUnix,
      List<GameActionPlayerInvolved>? players_involved,
      int team,
      String? description,
      @JsonKey(toJson: boolOrNullFalse) bool done,
    )?
    outball,
    required TResult orElse(),
  }) {
    if (outball != null) {
      return outball(
        id,
        timeGame,
        timespanGame,
        timeUnix,
        timespanUnix,
        players_involved,
        team,
        description,
        done,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GameActionGoal value) goal,
    required TResult Function(_GameActionFoul value) foul,
    required TResult Function(_GameActionPenalty value) penalty,
    required TResult Function(_GameActionOutball value) outball,
  }) {
    return outball(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GameActionGoal value)? goal,
    TResult? Function(_GameActionFoul value)? foul,
    TResult? Function(_GameActionPenalty value)? penalty,
    TResult? Function(_GameActionOutball value)? outball,
  }) {
    return outball?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GameActionGoal value)? goal,
    TResult Function(_GameActionFoul value)? foul,
    TResult Function(_GameActionPenalty value)? penalty,
    TResult Function(_GameActionOutball value)? outball,
    required TResult orElse(),
  }) {
    if (outball != null) {
      return outball(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$GameActionOutballImplToJson(this);
  }
}

abstract class _GameActionOutball implements GameAction {
  const factory _GameActionOutball({
    required final int id,
    @JsonKey(name: "time_game") final int? timeGame,
    @JsonKey(name: "timespan_game") final int? timespanGame,
    @JsonKey(name: "time_unix") final int? timeUnix,
    @JsonKey(name: "timespan_unix") final int? timespanUnix,
    final List<GameActionPlayerInvolved>? players_involved,
    required final int team,
    final String? description,
    @JsonKey(toJson: boolOrNullFalse) final bool done,
  }) = _$GameActionOutballImpl;

  factory _GameActionOutball.fromJson(Map<String, dynamic> json) =
      _$GameActionOutballImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: "time_game")
  int? get timeGame;
  @override
  @JsonKey(name: "timespan_game")
  int? get timespanGame;
  @override
  @JsonKey(name: "time_unix")
  int? get timeUnix;
  @override
  @JsonKey(name: "timespan_unix")
  int? get timespanUnix;
  @override
  List<GameActionPlayerInvolved>? get players_involved;
  int get team; // either 1 or 2 for the equivalent team
  @override
  String? get description;
  @override
  @JsonKey(toJson: boolOrNullFalse)
  bool get done;

  /// Create a copy of GameAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameActionOutballImplCopyWith<_$GameActionOutballImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameActionPlayerInvolved _$GameActionPlayerInvolvedFromJson(
  Map<String, dynamic> json,
) {
  return _GameActionPlayerInvolved.fromJson(json);
}

/// @nodoc
mixin _$GameActionPlayerInvolved {
  String get name => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;

  /// Serializes this GameActionPlayerInvolved to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameActionPlayerInvolved
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameActionPlayerInvolvedCopyWith<GameActionPlayerInvolved> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameActionPlayerInvolvedCopyWith<$Res> {
  factory $GameActionPlayerInvolvedCopyWith(
    GameActionPlayerInvolved value,
    $Res Function(GameActionPlayerInvolved) then,
  ) = _$GameActionPlayerInvolvedCopyWithImpl<$Res, GameActionPlayerInvolved>;
  @useResult
  $Res call({String name, String role});
}

/// @nodoc
class _$GameActionPlayerInvolvedCopyWithImpl<
  $Res,
  $Val extends GameActionPlayerInvolved
>
    implements $GameActionPlayerInvolvedCopyWith<$Res> {
  _$GameActionPlayerInvolvedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameActionPlayerInvolved
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? role = null}) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameActionPlayerInvolvedImplCopyWith<$Res>
    implements $GameActionPlayerInvolvedCopyWith<$Res> {
  factory _$$GameActionPlayerInvolvedImplCopyWith(
    _$GameActionPlayerInvolvedImpl value,
    $Res Function(_$GameActionPlayerInvolvedImpl) then,
  ) = __$$GameActionPlayerInvolvedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String role});
}

/// @nodoc
class __$$GameActionPlayerInvolvedImplCopyWithImpl<$Res>
    extends
        _$GameActionPlayerInvolvedCopyWithImpl<
          $Res,
          _$GameActionPlayerInvolvedImpl
        >
    implements _$$GameActionPlayerInvolvedImplCopyWith<$Res> {
  __$$GameActionPlayerInvolvedImplCopyWithImpl(
    _$GameActionPlayerInvolvedImpl _value,
    $Res Function(_$GameActionPlayerInvolvedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameActionPlayerInvolved
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? role = null}) {
    return _then(
      _$GameActionPlayerInvolvedImpl(
        null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$GameActionPlayerInvolvedImpl implements _GameActionPlayerInvolved {
  const _$GameActionPlayerInvolvedImpl(this.name, this.role);

  factory _$GameActionPlayerInvolvedImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameActionPlayerInvolvedImplFromJson(json);

  @override
  final String name;
  @override
  final String role;

  @override
  String toString() {
    return 'GameActionPlayerInvolved(name: $name, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameActionPlayerInvolvedImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, role);

  /// Create a copy of GameActionPlayerInvolved
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameActionPlayerInvolvedImplCopyWith<_$GameActionPlayerInvolvedImpl>
  get copyWith =>
      __$$GameActionPlayerInvolvedImplCopyWithImpl<
        _$GameActionPlayerInvolvedImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameActionPlayerInvolvedImplToJson(this);
  }
}

abstract class _GameActionPlayerInvolved implements GameActionPlayerInvolved {
  const factory _GameActionPlayerInvolved(
    final String name,
    final String role,
  ) = _$GameActionPlayerInvolvedImpl;

  factory _GameActionPlayerInvolved.fromJson(Map<String, dynamic> json) =
      _$GameActionPlayerInvolvedImpl.fromJson;

  @override
  String get name;
  @override
  String get role;

  /// Create a copy of GameActionPlayerInvolved
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameActionPlayerInvolvedImplCopyWith<_$GameActionPlayerInvolvedImpl>
  get copyWith => throw _privateConstructorUsedError;
}

GameActionChange _$GameActionChangeFromJson(Map<String, dynamic> json) {
  return _GameActionChange.fromJson(json);
}

/// @nodoc
mixin _$GameActionChange {
  GameActionChangeScore get score => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(GameActionChangeScore score) score,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(GameActionChangeScore score)? score,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(GameActionChangeScore score)? score,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GameActionChange value) score,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GameActionChange value)? score,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GameActionChange value)? score,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this GameActionChange to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameActionChange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameActionChangeCopyWith<GameActionChange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameActionChangeCopyWith<$Res> {
  factory $GameActionChangeCopyWith(
    GameActionChange value,
    $Res Function(GameActionChange) then,
  ) = _$GameActionChangeCopyWithImpl<$Res, GameActionChange>;
  @useResult
  $Res call({GameActionChangeScore score});

  $GameActionChangeScoreCopyWith<$Res> get score;
}

/// @nodoc
class _$GameActionChangeCopyWithImpl<$Res, $Val extends GameActionChange>
    implements $GameActionChangeCopyWith<$Res> {
  _$GameActionChangeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameActionChange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? score = null}) {
    return _then(
      _value.copyWith(
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as GameActionChangeScore,
          )
          as $Val,
    );
  }

  /// Create a copy of GameActionChange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameActionChangeScoreCopyWith<$Res> get score {
    return $GameActionChangeScoreCopyWith<$Res>(_value.score, (value) {
      return _then(_value.copyWith(score: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameActionChangeImplCopyWith<$Res>
    implements $GameActionChangeCopyWith<$Res> {
  factory _$$GameActionChangeImplCopyWith(
    _$GameActionChangeImpl value,
    $Res Function(_$GameActionChangeImpl) then,
  ) = __$$GameActionChangeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({GameActionChangeScore score});

  @override
  $GameActionChangeScoreCopyWith<$Res> get score;
}

/// @nodoc
class __$$GameActionChangeImplCopyWithImpl<$Res>
    extends _$GameActionChangeCopyWithImpl<$Res, _$GameActionChangeImpl>
    implements _$$GameActionChangeImplCopyWith<$Res> {
  __$$GameActionChangeImplCopyWithImpl(
    _$GameActionChangeImpl _value,
    $Res Function(_$GameActionChangeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameActionChange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? score = null}) {
    return _then(
      _$GameActionChangeImpl(
        null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as GameActionChangeScore,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$GameActionChangeImpl implements _GameActionChange {
  const _$GameActionChangeImpl(this.score);

  factory _$GameActionChangeImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameActionChangeImplFromJson(json);

  @override
  final GameActionChangeScore score;

  @override
  String toString() {
    return 'GameActionChange.score(score: $score)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameActionChangeImpl &&
            (identical(other.score, score) || other.score == score));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, score);

  /// Create a copy of GameActionChange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameActionChangeImplCopyWith<_$GameActionChangeImpl> get copyWith =>
      __$$GameActionChangeImplCopyWithImpl<_$GameActionChangeImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(GameActionChangeScore score) score,
  }) {
    return score(this.score);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(GameActionChangeScore score)? score,
  }) {
    return score?.call(this.score);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(GameActionChangeScore score)? score,
    required TResult orElse(),
  }) {
    if (score != null) {
      return score(this.score);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GameActionChange value) score,
  }) {
    return score(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GameActionChange value)? score,
  }) {
    return score?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GameActionChange value)? score,
    required TResult orElse(),
  }) {
    if (score != null) {
      return score(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$GameActionChangeImplToJson(this);
  }
}

abstract class _GameActionChange implements GameActionChange {
  const factory _GameActionChange(final GameActionChangeScore score) =
      _$GameActionChangeImpl;

  factory _GameActionChange.fromJson(Map<String, dynamic> json) =
      _$GameActionChangeImpl.fromJson;

  @override
  GameActionChangeScore get score;

  /// Create a copy of GameActionChange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameActionChangeImplCopyWith<_$GameActionChangeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameActionChangeScore _$GameActionChangeScoreFromJson(
  Map<String, dynamic> json,
) {
  return _GameActionChangeScore.fromJson(json);
}

/// @nodoc
mixin _$GameActionChangeScore {
  @JsonKey(name: '1', toJson: intOrNullNot0)
  int get t1 => throw _privateConstructorUsedError;
  @JsonKey(name: '2', toJson: intOrNullNot0)
  int get t2 => throw _privateConstructorUsedError;

  /// Serializes this GameActionChangeScore to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameActionChangeScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameActionChangeScoreCopyWith<GameActionChangeScore> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameActionChangeScoreCopyWith<$Res> {
  factory $GameActionChangeScoreCopyWith(
    GameActionChangeScore value,
    $Res Function(GameActionChangeScore) then,
  ) = _$GameActionChangeScoreCopyWithImpl<$Res, GameActionChangeScore>;
  @useResult
  $Res call({
    @JsonKey(name: '1', toJson: intOrNullNot0) int t1,
    @JsonKey(name: '2', toJson: intOrNullNot0) int t2,
  });
}

/// @nodoc
class _$GameActionChangeScoreCopyWithImpl<
  $Res,
  $Val extends GameActionChangeScore
>
    implements $GameActionChangeScoreCopyWith<$Res> {
  _$GameActionChangeScoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameActionChangeScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? t1 = null, Object? t2 = null}) {
    return _then(
      _value.copyWith(
            t1: null == t1
                ? _value.t1
                : t1 // ignore: cast_nullable_to_non_nullable
                      as int,
            t2: null == t2
                ? _value.t2
                : t2 // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameActionChangeScoreImplCopyWith<$Res>
    implements $GameActionChangeScoreCopyWith<$Res> {
  factory _$$GameActionChangeScoreImplCopyWith(
    _$GameActionChangeScoreImpl value,
    $Res Function(_$GameActionChangeScoreImpl) then,
  ) = __$$GameActionChangeScoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: '1', toJson: intOrNullNot0) int t1,
    @JsonKey(name: '2', toJson: intOrNullNot0) int t2,
  });
}

/// @nodoc
class __$$GameActionChangeScoreImplCopyWithImpl<$Res>
    extends
        _$GameActionChangeScoreCopyWithImpl<$Res, _$GameActionChangeScoreImpl>
    implements _$$GameActionChangeScoreImplCopyWith<$Res> {
  __$$GameActionChangeScoreImplCopyWithImpl(
    _$GameActionChangeScoreImpl _value,
    $Res Function(_$GameActionChangeScoreImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameActionChangeScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? t1 = null, Object? t2 = null}) {
    return _then(
      _$GameActionChangeScoreImpl(
        t1: null == t1
            ? _value.t1
            : t1 // ignore: cast_nullable_to_non_nullable
                  as int,
        t2: null == t2
            ? _value.t2
            : t2 // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$GameActionChangeScoreImpl implements _GameActionChangeScore {
  const _$GameActionChangeScoreImpl({
    @JsonKey(name: '1', toJson: intOrNullNot0) this.t1 = 0,
    @JsonKey(name: '2', toJson: intOrNullNot0) this.t2 = 0,
  });

  factory _$GameActionChangeScoreImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameActionChangeScoreImplFromJson(json);

  @override
  @JsonKey(name: '1', toJson: intOrNullNot0)
  final int t1;
  @override
  @JsonKey(name: '2', toJson: intOrNullNot0)
  final int t2;

  @override
  String toString() {
    return 'GameActionChangeScore(t1: $t1, t2: $t2)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameActionChangeScoreImpl &&
            (identical(other.t1, t1) || other.t1 == t1) &&
            (identical(other.t2, t2) || other.t2 == t2));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, t1, t2);

  /// Create a copy of GameActionChangeScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameActionChangeScoreImplCopyWith<_$GameActionChangeScoreImpl>
  get copyWith =>
      __$$GameActionChangeScoreImplCopyWithImpl<_$GameActionChangeScoreImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GameActionChangeScoreImplToJson(this);
  }
}

abstract class _GameActionChangeScore implements GameActionChangeScore {
  const factory _GameActionChangeScore({
    @JsonKey(name: '1', toJson: intOrNullNot0) final int t1,
    @JsonKey(name: '2', toJson: intOrNullNot0) final int t2,
  }) = _$GameActionChangeScoreImpl;

  factory _GameActionChangeScore.fromJson(Map<String, dynamic> json) =
      _$GameActionChangeScoreImpl.fromJson;

  @override
  @JsonKey(name: '1', toJson: intOrNullNot0)
  int get t1;
  @override
  @JsonKey(name: '2', toJson: intOrNullNot0)
  int get t2;

  /// Create a copy of GameActionChangeScore
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameActionChangeScoreImplCopyWith<_$GameActionChangeScoreImpl>
  get copyWith => throw _privateConstructorUsedError;
}

GameFormat _$GameFormatFromJson(Map<String, dynamic> json) {
  return _GameFormat.fromJson(json);
}

/// @nodoc
mixin _$GameFormat {
  String get name => throw _privateConstructorUsedError;
  @JsonKey(toJson: boolOrNullTrue)
  bool get decider => throw _privateConstructorUsedError;

  /// Serializes this GameFormat to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameFormat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameFormatCopyWith<GameFormat> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameFormatCopyWith<$Res> {
  factory $GameFormatCopyWith(
    GameFormat value,
    $Res Function(GameFormat) then,
  ) = _$GameFormatCopyWithImpl<$Res, GameFormat>;
  @useResult
  $Res call({String name, @JsonKey(toJson: boolOrNullTrue) bool decider});
}

/// @nodoc
class _$GameFormatCopyWithImpl<$Res, $Val extends GameFormat>
    implements $GameFormatCopyWith<$Res> {
  _$GameFormatCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameFormat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? decider = null}) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            decider: null == decider
                ? _value.decider
                : decider // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameFormatImplCopyWith<$Res>
    implements $GameFormatCopyWith<$Res> {
  factory _$$GameFormatImplCopyWith(
    _$GameFormatImpl value,
    $Res Function(_$GameFormatImpl) then,
  ) = __$$GameFormatImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, @JsonKey(toJson: boolOrNullTrue) bool decider});
}

/// @nodoc
class __$$GameFormatImplCopyWithImpl<$Res>
    extends _$GameFormatCopyWithImpl<$Res, _$GameFormatImpl>
    implements _$$GameFormatImplCopyWith<$Res> {
  __$$GameFormatImplCopyWithImpl(
    _$GameFormatImpl _value,
    $Res Function(_$GameFormatImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameFormat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? decider = null}) {
    return _then(
      _$GameFormatImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        decider: null == decider
            ? _value.decider
            : decider // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$GameFormatImpl implements _GameFormat {
  const _$GameFormatImpl({
    required this.name,
    @JsonKey(toJson: boolOrNullTrue) this.decider = false,
  });

  factory _$GameFormatImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameFormatImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey(toJson: boolOrNullTrue)
  final bool decider;

  @override
  String toString() {
    return 'GameFormat(name: $name, decider: $decider)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameFormatImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.decider, decider) || other.decider == decider));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, decider);

  /// Create a copy of GameFormat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameFormatImplCopyWith<_$GameFormatImpl> get copyWith =>
      __$$GameFormatImplCopyWithImpl<_$GameFormatImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameFormatImplToJson(this);
  }
}

abstract class _GameFormat implements GameFormat {
  const factory _GameFormat({
    required final String name,
    @JsonKey(toJson: boolOrNullTrue) final bool decider,
  }) = _$GameFormatImpl;

  factory _GameFormat.fromJson(Map<String, dynamic> json) =
      _$GameFormatImpl.fromJson;

  @override
  String get name;
  @override
  @JsonKey(toJson: boolOrNullTrue)
  bool get decider;

  /// Create a copy of GameFormat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameFormatImplCopyWith<_$GameFormatImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameTeamSlot _$GameTeamSlotFromJson(Map<String, dynamic> json) {
  switch (json['type']) {
    case 'byName':
      return _GameTeamSlotByName.fromJson(json);
    case 'byQuery':
      return _GameTeamSlotByQuery.fromJson(json);
    case 'byQueryResolved':
      return _GameTeamSlotByQueryResolved.fromJson(json);

    default:
      throw CheckedFromJsonException(
        json,
        'type',
        'GameTeamSlot',
        'Invalid union type "${json['type']}"!',
      );
  }
}

/// @nodoc
mixin _$GameTeamSlot {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, MissingInfo? missing) byName,
    required TResult Function(GameQuery query, MissingInfo? missing) byQuery,
    required TResult Function(String name, _GameTeamSlotByQuery q)
    byQueryResolved,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, MissingInfo? missing)? byName,
    TResult? Function(GameQuery query, MissingInfo? missing)? byQuery,
    TResult? Function(String name, _GameTeamSlotByQuery q)? byQueryResolved,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, MissingInfo? missing)? byName,
    TResult Function(GameQuery query, MissingInfo? missing)? byQuery,
    TResult Function(String name, _GameTeamSlotByQuery q)? byQueryResolved,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GameTeamSlotByName value) byName,
    required TResult Function(_GameTeamSlotByQuery value) byQuery,
    required TResult Function(_GameTeamSlotByQueryResolved value)
    byQueryResolved,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GameTeamSlotByName value)? byName,
    TResult? Function(_GameTeamSlotByQuery value)? byQuery,
    TResult? Function(_GameTeamSlotByQueryResolved value)? byQueryResolved,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GameTeamSlotByName value)? byName,
    TResult Function(_GameTeamSlotByQuery value)? byQuery,
    TResult Function(_GameTeamSlotByQueryResolved value)? byQueryResolved,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this GameTeamSlot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameTeamSlotCopyWith<$Res> {
  factory $GameTeamSlotCopyWith(
    GameTeamSlot value,
    $Res Function(GameTeamSlot) then,
  ) = _$GameTeamSlotCopyWithImpl<$Res, GameTeamSlot>;
}

/// @nodoc
class _$GameTeamSlotCopyWithImpl<$Res, $Val extends GameTeamSlot>
    implements $GameTeamSlotCopyWith<$Res> {
  _$GameTeamSlotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameTeamSlot
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$GameTeamSlotByNameImplCopyWith<$Res> {
  factory _$$GameTeamSlotByNameImplCopyWith(
    _$GameTeamSlotByNameImpl value,
    $Res Function(_$GameTeamSlotByNameImpl) then,
  ) = __$$GameTeamSlotByNameImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String name, MissingInfo? missing});

  $MissingInfoCopyWith<$Res>? get missing;
}

/// @nodoc
class __$$GameTeamSlotByNameImplCopyWithImpl<$Res>
    extends _$GameTeamSlotCopyWithImpl<$Res, _$GameTeamSlotByNameImpl>
    implements _$$GameTeamSlotByNameImplCopyWith<$Res> {
  __$$GameTeamSlotByNameImplCopyWithImpl(
    _$GameTeamSlotByNameImpl _value,
    $Res Function(_$GameTeamSlotByNameImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameTeamSlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? missing = freezed}) {
    return _then(
      _$GameTeamSlotByNameImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        missing: freezed == missing
            ? _value.missing
            : missing // ignore: cast_nullable_to_non_nullable
                  as MissingInfo?,
      ),
    );
  }

  /// Create a copy of GameTeamSlot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MissingInfoCopyWith<$Res>? get missing {
    if (_value.missing == null) {
      return null;
    }

    return $MissingInfoCopyWith<$Res>(_value.missing!, (value) {
      return _then(_value.copyWith(missing: value));
    });
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$GameTeamSlotByNameImpl implements _GameTeamSlotByName {
  const _$GameTeamSlotByNameImpl({
    required this.name,
    this.missing,
    final String? $type,
  }) : $type = $type ?? 'byName';

  factory _$GameTeamSlotByNameImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameTeamSlotByNameImplFromJson(json);

  @override
  final String name;
  @override
  final MissingInfo? missing;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'GameTeamSlot.byName(name: $name, missing: $missing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameTeamSlotByNameImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.missing, missing) || other.missing == missing));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, missing);

  /// Create a copy of GameTeamSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameTeamSlotByNameImplCopyWith<_$GameTeamSlotByNameImpl> get copyWith =>
      __$$GameTeamSlotByNameImplCopyWithImpl<_$GameTeamSlotByNameImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, MissingInfo? missing) byName,
    required TResult Function(GameQuery query, MissingInfo? missing) byQuery,
    required TResult Function(String name, _GameTeamSlotByQuery q)
    byQueryResolved,
  }) {
    return byName(name, missing);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, MissingInfo? missing)? byName,
    TResult? Function(GameQuery query, MissingInfo? missing)? byQuery,
    TResult? Function(String name, _GameTeamSlotByQuery q)? byQueryResolved,
  }) {
    return byName?.call(name, missing);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, MissingInfo? missing)? byName,
    TResult Function(GameQuery query, MissingInfo? missing)? byQuery,
    TResult Function(String name, _GameTeamSlotByQuery q)? byQueryResolved,
    required TResult orElse(),
  }) {
    if (byName != null) {
      return byName(name, missing);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GameTeamSlotByName value) byName,
    required TResult Function(_GameTeamSlotByQuery value) byQuery,
    required TResult Function(_GameTeamSlotByQueryResolved value)
    byQueryResolved,
  }) {
    return byName(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GameTeamSlotByName value)? byName,
    TResult? Function(_GameTeamSlotByQuery value)? byQuery,
    TResult? Function(_GameTeamSlotByQueryResolved value)? byQueryResolved,
  }) {
    return byName?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GameTeamSlotByName value)? byName,
    TResult Function(_GameTeamSlotByQuery value)? byQuery,
    TResult Function(_GameTeamSlotByQueryResolved value)? byQueryResolved,
    required TResult orElse(),
  }) {
    if (byName != null) {
      return byName(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$GameTeamSlotByNameImplToJson(this);
  }
}

abstract class _GameTeamSlotByName implements GameTeamSlot {
  const factory _GameTeamSlotByName({
    required final String name,
    final MissingInfo? missing,
  }) = _$GameTeamSlotByNameImpl;

  factory _GameTeamSlotByName.fromJson(Map<String, dynamic> json) =
      _$GameTeamSlotByNameImpl.fromJson;

  String get name;
  MissingInfo? get missing;

  /// Create a copy of GameTeamSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameTeamSlotByNameImplCopyWith<_$GameTeamSlotByNameImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GameTeamSlotByQueryImplCopyWith<$Res> {
  factory _$$GameTeamSlotByQueryImplCopyWith(
    _$GameTeamSlotByQueryImpl value,
    $Res Function(_$GameTeamSlotByQueryImpl) then,
  ) = __$$GameTeamSlotByQueryImplCopyWithImpl<$Res>;
  @useResult
  $Res call({GameQuery query, MissingInfo? missing});

  $GameQueryCopyWith<$Res> get query;
  $MissingInfoCopyWith<$Res>? get missing;
}

/// @nodoc
class __$$GameTeamSlotByQueryImplCopyWithImpl<$Res>
    extends _$GameTeamSlotCopyWithImpl<$Res, _$GameTeamSlotByQueryImpl>
    implements _$$GameTeamSlotByQueryImplCopyWith<$Res> {
  __$$GameTeamSlotByQueryImplCopyWithImpl(
    _$GameTeamSlotByQueryImpl _value,
    $Res Function(_$GameTeamSlotByQueryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameTeamSlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? query = null, Object? missing = freezed}) {
    return _then(
      _$GameTeamSlotByQueryImpl(
        query: null == query
            ? _value.query
            : query // ignore: cast_nullable_to_non_nullable
                  as GameQuery,
        missing: freezed == missing
            ? _value.missing
            : missing // ignore: cast_nullable_to_non_nullable
                  as MissingInfo?,
      ),
    );
  }

  /// Create a copy of GameTeamSlot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameQueryCopyWith<$Res> get query {
    return $GameQueryCopyWith<$Res>(_value.query, (value) {
      return _then(_value.copyWith(query: value));
    });
  }

  /// Create a copy of GameTeamSlot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MissingInfoCopyWith<$Res>? get missing {
    if (_value.missing == null) {
      return null;
    }

    return $MissingInfoCopyWith<$Res>(_value.missing!, (value) {
      return _then(_value.copyWith(missing: value));
    });
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$GameTeamSlotByQueryImpl implements _GameTeamSlotByQuery {
  const _$GameTeamSlotByQueryImpl({
    required this.query,
    this.missing,
    final String? $type,
  }) : $type = $type ?? 'byQuery';

  factory _$GameTeamSlotByQueryImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameTeamSlotByQueryImplFromJson(json);

  @override
  final GameQuery query;
  @override
  final MissingInfo? missing;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'GameTeamSlot.byQuery(query: $query, missing: $missing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameTeamSlotByQueryImpl &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.missing, missing) || other.missing == missing));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, query, missing);

  /// Create a copy of GameTeamSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameTeamSlotByQueryImplCopyWith<_$GameTeamSlotByQueryImpl> get copyWith =>
      __$$GameTeamSlotByQueryImplCopyWithImpl<_$GameTeamSlotByQueryImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, MissingInfo? missing) byName,
    required TResult Function(GameQuery query, MissingInfo? missing) byQuery,
    required TResult Function(String name, _GameTeamSlotByQuery q)
    byQueryResolved,
  }) {
    return byQuery(query, missing);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, MissingInfo? missing)? byName,
    TResult? Function(GameQuery query, MissingInfo? missing)? byQuery,
    TResult? Function(String name, _GameTeamSlotByQuery q)? byQueryResolved,
  }) {
    return byQuery?.call(query, missing);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, MissingInfo? missing)? byName,
    TResult Function(GameQuery query, MissingInfo? missing)? byQuery,
    TResult Function(String name, _GameTeamSlotByQuery q)? byQueryResolved,
    required TResult orElse(),
  }) {
    if (byQuery != null) {
      return byQuery(query, missing);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GameTeamSlotByName value) byName,
    required TResult Function(_GameTeamSlotByQuery value) byQuery,
    required TResult Function(_GameTeamSlotByQueryResolved value)
    byQueryResolved,
  }) {
    return byQuery(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GameTeamSlotByName value)? byName,
    TResult? Function(_GameTeamSlotByQuery value)? byQuery,
    TResult? Function(_GameTeamSlotByQueryResolved value)? byQueryResolved,
  }) {
    return byQuery?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GameTeamSlotByName value)? byName,
    TResult Function(_GameTeamSlotByQuery value)? byQuery,
    TResult Function(_GameTeamSlotByQueryResolved value)? byQueryResolved,
    required TResult orElse(),
  }) {
    if (byQuery != null) {
      return byQuery(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$GameTeamSlotByQueryImplToJson(this);
  }
}

abstract class _GameTeamSlotByQuery implements GameTeamSlot {
  const factory _GameTeamSlotByQuery({
    required final GameQuery query,
    final MissingInfo? missing,
  }) = _$GameTeamSlotByQueryImpl;

  factory _GameTeamSlotByQuery.fromJson(Map<String, dynamic> json) =
      _$GameTeamSlotByQueryImpl.fromJson;

  GameQuery get query;
  MissingInfo? get missing;

  /// Create a copy of GameTeamSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameTeamSlotByQueryImplCopyWith<_$GameTeamSlotByQueryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GameTeamSlotByQueryResolvedImplCopyWith<$Res> {
  factory _$$GameTeamSlotByQueryResolvedImplCopyWith(
    _$GameTeamSlotByQueryResolvedImpl value,
    $Res Function(_$GameTeamSlotByQueryResolvedImpl) then,
  ) = __$$GameTeamSlotByQueryResolvedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String name, _GameTeamSlotByQuery q});
}

/// @nodoc
class __$$GameTeamSlotByQueryResolvedImplCopyWithImpl<$Res>
    extends _$GameTeamSlotCopyWithImpl<$Res, _$GameTeamSlotByQueryResolvedImpl>
    implements _$$GameTeamSlotByQueryResolvedImplCopyWith<$Res> {
  __$$GameTeamSlotByQueryResolvedImplCopyWithImpl(
    _$GameTeamSlotByQueryResolvedImpl _value,
    $Res Function(_$GameTeamSlotByQueryResolvedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameTeamSlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? q = freezed}) {
    return _then(
      _$GameTeamSlotByQueryResolvedImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        q: freezed == q
            ? _value.q
            : q // ignore: cast_nullable_to_non_nullable
                  as _GameTeamSlotByQuery,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$GameTeamSlotByQueryResolvedImpl
    implements _GameTeamSlotByQueryResolved {
  const _$GameTeamSlotByQueryResolvedImpl({
    required this.name,
    required this.q,
    final String? $type,
  }) : $type = $type ?? 'byQueryResolved';

  factory _$GameTeamSlotByQueryResolvedImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$GameTeamSlotByQueryResolvedImplFromJson(json);

  @override
  final String name;
  @override
  final _GameTeamSlotByQuery q;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'GameTeamSlot.byQueryResolved(name: $name, q: $q)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameTeamSlotByQueryResolvedImpl &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other.q, q));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, const DeepCollectionEquality().hash(q));

  /// Create a copy of GameTeamSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameTeamSlotByQueryResolvedImplCopyWith<_$GameTeamSlotByQueryResolvedImpl>
  get copyWith =>
      __$$GameTeamSlotByQueryResolvedImplCopyWithImpl<
        _$GameTeamSlotByQueryResolvedImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, MissingInfo? missing) byName,
    required TResult Function(GameQuery query, MissingInfo? missing) byQuery,
    required TResult Function(String name, _GameTeamSlotByQuery q)
    byQueryResolved,
  }) {
    return byQueryResolved(name, q);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, MissingInfo? missing)? byName,
    TResult? Function(GameQuery query, MissingInfo? missing)? byQuery,
    TResult? Function(String name, _GameTeamSlotByQuery q)? byQueryResolved,
  }) {
    return byQueryResolved?.call(name, q);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, MissingInfo? missing)? byName,
    TResult Function(GameQuery query, MissingInfo? missing)? byQuery,
    TResult Function(String name, _GameTeamSlotByQuery q)? byQueryResolved,
    required TResult orElse(),
  }) {
    if (byQueryResolved != null) {
      return byQueryResolved(name, q);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GameTeamSlotByName value) byName,
    required TResult Function(_GameTeamSlotByQuery value) byQuery,
    required TResult Function(_GameTeamSlotByQueryResolved value)
    byQueryResolved,
  }) {
    return byQueryResolved(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GameTeamSlotByName value)? byName,
    TResult? Function(_GameTeamSlotByQuery value)? byQuery,
    TResult? Function(_GameTeamSlotByQueryResolved value)? byQueryResolved,
  }) {
    return byQueryResolved?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GameTeamSlotByName value)? byName,
    TResult Function(_GameTeamSlotByQuery value)? byQuery,
    TResult Function(_GameTeamSlotByQueryResolved value)? byQueryResolved,
    required TResult orElse(),
  }) {
    if (byQueryResolved != null) {
      return byQueryResolved(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$GameTeamSlotByQueryResolvedImplToJson(this);
  }
}

abstract class _GameTeamSlotByQueryResolved implements GameTeamSlot {
  const factory _GameTeamSlotByQueryResolved({
    required final String name,
    required final _GameTeamSlotByQuery q,
  }) = _$GameTeamSlotByQueryResolvedImpl;

  factory _GameTeamSlotByQueryResolved.fromJson(Map<String, dynamic> json) =
      _$GameTeamSlotByQueryResolvedImpl.fromJson;

  String get name;
  _GameTeamSlotByQuery get q;

  /// Create a copy of GameTeamSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameTeamSlotByQueryResolvedImplCopyWith<_$GameTeamSlotByQueryResolvedImpl>
  get copyWith => throw _privateConstructorUsedError;
}

GameQuery _$GameQueryFromJson(Map<String, dynamic> json) {
  switch (json['type']) {
    case 'groupPlace':
      return _GameQueryByGroupPlace.fromJson(json);
    case 'gameWinner':
      return _GameQueryByGameWinner.fromJson(json);
    case 'gameLoser':
      return _GameQueryByGameLoser.fromJson(json);

    default:
      throw CheckedFromJsonException(
        json,
        'type',
        'GameQuery',
        'Invalid union type "${json['type']}"!',
      );
  }
}

/// @nodoc
mixin _$GameQuery {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String group, int place) groupPlace,
    required TResult Function(int gameIndex) gameWinner,
    required TResult Function(int gameIndex) gameLoser,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String group, int place)? groupPlace,
    TResult? Function(int gameIndex)? gameWinner,
    TResult? Function(int gameIndex)? gameLoser,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String group, int place)? groupPlace,
    TResult Function(int gameIndex)? gameWinner,
    TResult Function(int gameIndex)? gameLoser,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GameQueryByGroupPlace value) groupPlace,
    required TResult Function(_GameQueryByGameWinner value) gameWinner,
    required TResult Function(_GameQueryByGameLoser value) gameLoser,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GameQueryByGroupPlace value)? groupPlace,
    TResult? Function(_GameQueryByGameWinner value)? gameWinner,
    TResult? Function(_GameQueryByGameLoser value)? gameLoser,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GameQueryByGroupPlace value)? groupPlace,
    TResult Function(_GameQueryByGameWinner value)? gameWinner,
    TResult Function(_GameQueryByGameLoser value)? gameLoser,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this GameQuery to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameQueryCopyWith<$Res> {
  factory $GameQueryCopyWith(GameQuery value, $Res Function(GameQuery) then) =
      _$GameQueryCopyWithImpl<$Res, GameQuery>;
}

/// @nodoc
class _$GameQueryCopyWithImpl<$Res, $Val extends GameQuery>
    implements $GameQueryCopyWith<$Res> {
  _$GameQueryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameQuery
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$GameQueryByGroupPlaceImplCopyWith<$Res> {
  factory _$$GameQueryByGroupPlaceImplCopyWith(
    _$GameQueryByGroupPlaceImpl value,
    $Res Function(_$GameQueryByGroupPlaceImpl) then,
  ) = __$$GameQueryByGroupPlaceImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String group, int place});
}

/// @nodoc
class __$$GameQueryByGroupPlaceImplCopyWithImpl<$Res>
    extends _$GameQueryCopyWithImpl<$Res, _$GameQueryByGroupPlaceImpl>
    implements _$$GameQueryByGroupPlaceImplCopyWith<$Res> {
  __$$GameQueryByGroupPlaceImplCopyWithImpl(
    _$GameQueryByGroupPlaceImpl _value,
    $Res Function(_$GameQueryByGroupPlaceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameQuery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? group = null, Object? place = null}) {
    return _then(
      _$GameQueryByGroupPlaceImpl(
        null == group
            ? _value.group
            : group // ignore: cast_nullable_to_non_nullable
                  as String,
        null == place
            ? _value.place
            : place // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$GameQueryByGroupPlaceImpl implements _GameQueryByGroupPlace {
  const _$GameQueryByGroupPlaceImpl(
    this.group,
    this.place, {
    final String? $type,
  }) : $type = $type ?? 'groupPlace';

  factory _$GameQueryByGroupPlaceImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameQueryByGroupPlaceImplFromJson(json);

  @override
  final String group;
  @override
  final int place;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'GameQuery.groupPlace(group: $group, place: $place)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameQueryByGroupPlaceImpl &&
            (identical(other.group, group) || other.group == group) &&
            (identical(other.place, place) || other.place == place));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, group, place);

  /// Create a copy of GameQuery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameQueryByGroupPlaceImplCopyWith<_$GameQueryByGroupPlaceImpl>
  get copyWith =>
      __$$GameQueryByGroupPlaceImplCopyWithImpl<_$GameQueryByGroupPlaceImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String group, int place) groupPlace,
    required TResult Function(int gameIndex) gameWinner,
    required TResult Function(int gameIndex) gameLoser,
  }) {
    return groupPlace(group, place);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String group, int place)? groupPlace,
    TResult? Function(int gameIndex)? gameWinner,
    TResult? Function(int gameIndex)? gameLoser,
  }) {
    return groupPlace?.call(group, place);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String group, int place)? groupPlace,
    TResult Function(int gameIndex)? gameWinner,
    TResult Function(int gameIndex)? gameLoser,
    required TResult orElse(),
  }) {
    if (groupPlace != null) {
      return groupPlace(group, place);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GameQueryByGroupPlace value) groupPlace,
    required TResult Function(_GameQueryByGameWinner value) gameWinner,
    required TResult Function(_GameQueryByGameLoser value) gameLoser,
  }) {
    return groupPlace(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GameQueryByGroupPlace value)? groupPlace,
    TResult? Function(_GameQueryByGameWinner value)? gameWinner,
    TResult? Function(_GameQueryByGameLoser value)? gameLoser,
  }) {
    return groupPlace?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GameQueryByGroupPlace value)? groupPlace,
    TResult Function(_GameQueryByGameWinner value)? gameWinner,
    TResult Function(_GameQueryByGameLoser value)? gameLoser,
    required TResult orElse(),
  }) {
    if (groupPlace != null) {
      return groupPlace(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$GameQueryByGroupPlaceImplToJson(this);
  }
}

abstract class _GameQueryByGroupPlace implements GameQuery {
  const factory _GameQueryByGroupPlace(final String group, final int place) =
      _$GameQueryByGroupPlaceImpl;

  factory _GameQueryByGroupPlace.fromJson(Map<String, dynamic> json) =
      _$GameQueryByGroupPlaceImpl.fromJson;

  String get group;
  int get place;

  /// Create a copy of GameQuery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameQueryByGroupPlaceImplCopyWith<_$GameQueryByGroupPlaceImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GameQueryByGameWinnerImplCopyWith<$Res> {
  factory _$$GameQueryByGameWinnerImplCopyWith(
    _$GameQueryByGameWinnerImpl value,
    $Res Function(_$GameQueryByGameWinnerImpl) then,
  ) = __$$GameQueryByGameWinnerImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int gameIndex});
}

/// @nodoc
class __$$GameQueryByGameWinnerImplCopyWithImpl<$Res>
    extends _$GameQueryCopyWithImpl<$Res, _$GameQueryByGameWinnerImpl>
    implements _$$GameQueryByGameWinnerImplCopyWith<$Res> {
  __$$GameQueryByGameWinnerImplCopyWithImpl(
    _$GameQueryByGameWinnerImpl _value,
    $Res Function(_$GameQueryByGameWinnerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameQuery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? gameIndex = null}) {
    return _then(
      _$GameQueryByGameWinnerImpl(
        null == gameIndex
            ? _value.gameIndex
            : gameIndex // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$GameQueryByGameWinnerImpl implements _GameQueryByGameWinner {
  const _$GameQueryByGameWinnerImpl(this.gameIndex, {final String? $type})
    : $type = $type ?? 'gameWinner';

  factory _$GameQueryByGameWinnerImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameQueryByGameWinnerImplFromJson(json);

  @override
  final int gameIndex;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'GameQuery.gameWinner(gameIndex: $gameIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameQueryByGameWinnerImpl &&
            (identical(other.gameIndex, gameIndex) ||
                other.gameIndex == gameIndex));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, gameIndex);

  /// Create a copy of GameQuery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameQueryByGameWinnerImplCopyWith<_$GameQueryByGameWinnerImpl>
  get copyWith =>
      __$$GameQueryByGameWinnerImplCopyWithImpl<_$GameQueryByGameWinnerImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String group, int place) groupPlace,
    required TResult Function(int gameIndex) gameWinner,
    required TResult Function(int gameIndex) gameLoser,
  }) {
    return gameWinner(gameIndex);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String group, int place)? groupPlace,
    TResult? Function(int gameIndex)? gameWinner,
    TResult? Function(int gameIndex)? gameLoser,
  }) {
    return gameWinner?.call(gameIndex);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String group, int place)? groupPlace,
    TResult Function(int gameIndex)? gameWinner,
    TResult Function(int gameIndex)? gameLoser,
    required TResult orElse(),
  }) {
    if (gameWinner != null) {
      return gameWinner(gameIndex);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GameQueryByGroupPlace value) groupPlace,
    required TResult Function(_GameQueryByGameWinner value) gameWinner,
    required TResult Function(_GameQueryByGameLoser value) gameLoser,
  }) {
    return gameWinner(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GameQueryByGroupPlace value)? groupPlace,
    TResult? Function(_GameQueryByGameWinner value)? gameWinner,
    TResult? Function(_GameQueryByGameLoser value)? gameLoser,
  }) {
    return gameWinner?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GameQueryByGroupPlace value)? groupPlace,
    TResult Function(_GameQueryByGameWinner value)? gameWinner,
    TResult Function(_GameQueryByGameLoser value)? gameLoser,
    required TResult orElse(),
  }) {
    if (gameWinner != null) {
      return gameWinner(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$GameQueryByGameWinnerImplToJson(this);
  }
}

abstract class _GameQueryByGameWinner implements GameQuery {
  const factory _GameQueryByGameWinner(final int gameIndex) =
      _$GameQueryByGameWinnerImpl;

  factory _GameQueryByGameWinner.fromJson(Map<String, dynamic> json) =
      _$GameQueryByGameWinnerImpl.fromJson;

  int get gameIndex;

  /// Create a copy of GameQuery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameQueryByGameWinnerImplCopyWith<_$GameQueryByGameWinnerImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GameQueryByGameLoserImplCopyWith<$Res> {
  factory _$$GameQueryByGameLoserImplCopyWith(
    _$GameQueryByGameLoserImpl value,
    $Res Function(_$GameQueryByGameLoserImpl) then,
  ) = __$$GameQueryByGameLoserImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int gameIndex});
}

/// @nodoc
class __$$GameQueryByGameLoserImplCopyWithImpl<$Res>
    extends _$GameQueryCopyWithImpl<$Res, _$GameQueryByGameLoserImpl>
    implements _$$GameQueryByGameLoserImplCopyWith<$Res> {
  __$$GameQueryByGameLoserImplCopyWithImpl(
    _$GameQueryByGameLoserImpl _value,
    $Res Function(_$GameQueryByGameLoserImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameQuery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? gameIndex = null}) {
    return _then(
      _$GameQueryByGameLoserImpl(
        null == gameIndex
            ? _value.gameIndex
            : gameIndex // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$GameQueryByGameLoserImpl implements _GameQueryByGameLoser {
  const _$GameQueryByGameLoserImpl(this.gameIndex, {final String? $type})
    : $type = $type ?? 'gameLoser';

  factory _$GameQueryByGameLoserImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameQueryByGameLoserImplFromJson(json);

  @override
  final int gameIndex;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'GameQuery.gameLoser(gameIndex: $gameIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameQueryByGameLoserImpl &&
            (identical(other.gameIndex, gameIndex) ||
                other.gameIndex == gameIndex));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, gameIndex);

  /// Create a copy of GameQuery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameQueryByGameLoserImplCopyWith<_$GameQueryByGameLoserImpl>
  get copyWith =>
      __$$GameQueryByGameLoserImplCopyWithImpl<_$GameQueryByGameLoserImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String group, int place) groupPlace,
    required TResult Function(int gameIndex) gameWinner,
    required TResult Function(int gameIndex) gameLoser,
  }) {
    return gameLoser(gameIndex);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String group, int place)? groupPlace,
    TResult? Function(int gameIndex)? gameWinner,
    TResult? Function(int gameIndex)? gameLoser,
  }) {
    return gameLoser?.call(gameIndex);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String group, int place)? groupPlace,
    TResult Function(int gameIndex)? gameWinner,
    TResult Function(int gameIndex)? gameLoser,
    required TResult orElse(),
  }) {
    if (gameLoser != null) {
      return gameLoser(gameIndex);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GameQueryByGroupPlace value) groupPlace,
    required TResult Function(_GameQueryByGameWinner value) gameWinner,
    required TResult Function(_GameQueryByGameLoser value) gameLoser,
  }) {
    return gameLoser(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GameQueryByGroupPlace value)? groupPlace,
    TResult? Function(_GameQueryByGameWinner value)? gameWinner,
    TResult? Function(_GameQueryByGameLoser value)? gameLoser,
  }) {
    return gameLoser?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GameQueryByGroupPlace value)? groupPlace,
    TResult Function(_GameQueryByGameWinner value)? gameWinner,
    TResult Function(_GameQueryByGameLoser value)? gameLoser,
    required TResult orElse(),
  }) {
    if (gameLoser != null) {
      return gameLoser(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$GameQueryByGameLoserImplToJson(this);
  }
}

abstract class _GameQueryByGameLoser implements GameQuery {
  const factory _GameQueryByGameLoser(final int gameIndex) =
      _$GameQueryByGameLoserImpl;

  factory _GameQueryByGameLoser.fromJson(Map<String, dynamic> json) =
      _$GameQueryByGameLoserImpl.fromJson;

  int get gameIndex;

  /// Create a copy of GameQuery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameQueryByGameLoserImplCopyWith<_$GameQueryByGameLoserImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MissingInfo _$MissingInfoFromJson(Map<String, dynamic> json) {
  return _MissingInfo.fromJson(json);
}

/// @nodoc
mixin _$MissingInfo {
  String get reason => throw _privateConstructorUsedError;

  /// Serializes this MissingInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MissingInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MissingInfoCopyWith<MissingInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MissingInfoCopyWith<$Res> {
  factory $MissingInfoCopyWith(
    MissingInfo value,
    $Res Function(MissingInfo) then,
  ) = _$MissingInfoCopyWithImpl<$Res, MissingInfo>;
  @useResult
  $Res call({String reason});
}

/// @nodoc
class _$MissingInfoCopyWithImpl<$Res, $Val extends MissingInfo>
    implements $MissingInfoCopyWith<$Res> {
  _$MissingInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MissingInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? reason = null}) {
    return _then(
      _value.copyWith(
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MissingInfoImplCopyWith<$Res>
    implements $MissingInfoCopyWith<$Res> {
  factory _$$MissingInfoImplCopyWith(
    _$MissingInfoImpl value,
    $Res Function(_$MissingInfoImpl) then,
  ) = __$$MissingInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String reason});
}

/// @nodoc
class __$$MissingInfoImplCopyWithImpl<$Res>
    extends _$MissingInfoCopyWithImpl<$Res, _$MissingInfoImpl>
    implements _$$MissingInfoImplCopyWith<$Res> {
  __$$MissingInfoImplCopyWithImpl(
    _$MissingInfoImpl _value,
    $Res Function(_$MissingInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MissingInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? reason = null}) {
    return _then(
      _$MissingInfoImpl(
        null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$MissingInfoImpl implements _MissingInfo {
  const _$MissingInfoImpl(this.reason);

  factory _$MissingInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$MissingInfoImplFromJson(json);

  @override
  final String reason;

  @override
  String toString() {
    return 'MissingInfo(reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MissingInfoImpl &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, reason);

  /// Create a copy of MissingInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MissingInfoImplCopyWith<_$MissingInfoImpl> get copyWith =>
      __$$MissingInfoImplCopyWithImpl<_$MissingInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MissingInfoImplToJson(this);
  }
}

abstract class _MissingInfo implements MissingInfo {
  const factory _MissingInfo(final String reason) = _$MissingInfoImpl;

  factory _MissingInfo.fromJson(Map<String, dynamic> json) =
      _$MissingInfoImpl.fromJson;

  @override
  String get reason;

  /// Create a copy of MissingInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MissingInfoImplCopyWith<_$MissingInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Player _$PlayerFromJson(Map<String, dynamic> json) {
  return _Player.fromJson(json);
}

/// @nodoc
mixin _$Player {
  String get name => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;

  /// Serializes this Player to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Player
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayerCopyWith<Player> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerCopyWith<$Res> {
  factory $PlayerCopyWith(Player value, $Res Function(Player) then) =
      _$PlayerCopyWithImpl<$Res, Player>;
  @useResult
  $Res call({String name, String role});
}

/// @nodoc
class _$PlayerCopyWithImpl<$Res, $Val extends Player>
    implements $PlayerCopyWith<$Res> {
  _$PlayerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Player
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? role = null}) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlayerImplCopyWith<$Res> implements $PlayerCopyWith<$Res> {
  factory _$$PlayerImplCopyWith(
    _$PlayerImpl value,
    $Res Function(_$PlayerImpl) then,
  ) = __$$PlayerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String role});
}

/// @nodoc
class __$$PlayerImplCopyWithImpl<$Res>
    extends _$PlayerCopyWithImpl<$Res, _$PlayerImpl>
    implements _$$PlayerImplCopyWith<$Res> {
  __$$PlayerImplCopyWithImpl(
    _$PlayerImpl _value,
    $Res Function(_$PlayerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Player
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? role = null}) {
    return _then(
      _$PlayerImpl(
        null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$PlayerImpl implements _Player {
  const _$PlayerImpl(this.name, this.role);

  factory _$PlayerImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayerImplFromJson(json);

  @override
  final String name;
  @override
  final String role;

  @override
  String toString() {
    return 'Player(name: $name, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, role);

  /// Create a copy of Player
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerImplCopyWith<_$PlayerImpl> get copyWith =>
      __$$PlayerImplCopyWithImpl<_$PlayerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayerImplToJson(this);
  }
}

abstract class _Player implements Player {
  const factory _Player(final String name, final String role) = _$PlayerImpl;

  factory _Player.fromJson(Map<String, dynamic> json) = _$PlayerImpl.fromJson;

  @override
  String get name;
  @override
  String get role;

  /// Create a copy of Player
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayerImplCopyWith<_$PlayerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Team _$TeamFromJson(Map<String, dynamic> json) {
  return _Team.fromJson(json);
}

/// @nodoc
mixin _$Team {
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo_uri')
  String get logoUri => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;
  List<Player> get players => throw _privateConstructorUsedError;

  /// Serializes this Team to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeamCopyWith<Team> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeamCopyWith<$Res> {
  factory $TeamCopyWith(Team value, $Res Function(Team) then) =
      _$TeamCopyWithImpl<$Res, Team>;
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'logo_uri') String logoUri,
    String color,
    List<Player> players,
  });
}

/// @nodoc
class _$TeamCopyWithImpl<$Res, $Val extends Team>
    implements $TeamCopyWith<$Res> {
  _$TeamCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? logoUri = null,
    Object? color = null,
    Object? players = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            logoUri: null == logoUri
                ? _value.logoUri
                : logoUri // ignore: cast_nullable_to_non_nullable
                      as String,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String,
            players: null == players
                ? _value.players
                : players // ignore: cast_nullable_to_non_nullable
                      as List<Player>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeamImplCopyWith<$Res> implements $TeamCopyWith<$Res> {
  factory _$$TeamImplCopyWith(
    _$TeamImpl value,
    $Res Function(_$TeamImpl) then,
  ) = __$$TeamImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'logo_uri') String logoUri,
    String color,
    List<Player> players,
  });
}

/// @nodoc
class __$$TeamImplCopyWithImpl<$Res>
    extends _$TeamCopyWithImpl<$Res, _$TeamImpl>
    implements _$$TeamImplCopyWith<$Res> {
  __$$TeamImplCopyWithImpl(_$TeamImpl _value, $Res Function(_$TeamImpl) _then)
    : super(_value, _then);

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? logoUri = null,
    Object? color = null,
    Object? players = null,
  }) {
    return _then(
      _$TeamImpl(
        null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        null == logoUri
            ? _value.logoUri
            : logoUri // ignore: cast_nullable_to_non_nullable
                  as String,
        null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String,
        null == players
            ? _value._players
            : players // ignore: cast_nullable_to_non_nullable
                  as List<Player>,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$TeamImpl implements _Team {
  const _$TeamImpl(
    this.name,
    @JsonKey(name: 'logo_uri') this.logoUri,
    this.color,
    final List<Player> players,
  ) : _players = players;

  factory _$TeamImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeamImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey(name: 'logo_uri')
  final String logoUri;
  @override
  final String color;
  final List<Player> _players;
  @override
  List<Player> get players {
    if (_players is EqualUnmodifiableListView) return _players;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_players);
  }

  @override
  String toString() {
    return 'Team(name: $name, logoUri: $logoUri, color: $color, players: $players)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeamImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.logoUri, logoUri) || other.logoUri == logoUri) &&
            (identical(other.color, color) || other.color == color) &&
            const DeepCollectionEquality().equals(other._players, _players));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    logoUri,
    color,
    const DeepCollectionEquality().hash(_players),
  );

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeamImplCopyWith<_$TeamImpl> get copyWith =>
      __$$TeamImplCopyWithImpl<_$TeamImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeamImplToJson(this);
  }
}

abstract class _Team implements Team {
  const factory _Team(
    final String name,
    @JsonKey(name: 'logo_uri') final String logoUri,
    final String color,
    final List<Player> players,
  ) = _$TeamImpl;

  factory _Team.fromJson(Map<String, dynamic> json) = _$TeamImpl.fromJson;

  @override
  String get name;
  @override
  @JsonKey(name: 'logo_uri')
  String get logoUri;
  @override
  String get color;
  @override
  List<Player> get players;

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeamImplCopyWith<_$TeamImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Group _$GroupFromJson(Map<String, dynamic> json) {
  return _Group.fromJson(json);
}

/// @nodoc
mixin _$Group {
  String get name => throw _privateConstructorUsedError;
  List<String> get members => throw _privateConstructorUsedError;

  /// Serializes this Group to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupCopyWith<Group> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupCopyWith<$Res> {
  factory $GroupCopyWith(Group value, $Res Function(Group) then) =
      _$GroupCopyWithImpl<$Res, Group>;
  @useResult
  $Res call({String name, List<String> members});
}

/// @nodoc
class _$GroupCopyWithImpl<$Res, $Val extends Group>
    implements $GroupCopyWith<$Res> {
  _$GroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? members = null}) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            members: null == members
                ? _value.members
                : members // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GroupImplCopyWith<$Res> implements $GroupCopyWith<$Res> {
  factory _$$GroupImplCopyWith(
    _$GroupImpl value,
    $Res Function(_$GroupImpl) then,
  ) = __$$GroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, List<String> members});
}

/// @nodoc
class __$$GroupImplCopyWithImpl<$Res>
    extends _$GroupCopyWithImpl<$Res, _$GroupImpl>
    implements _$$GroupImplCopyWith<$Res> {
  __$$GroupImplCopyWithImpl(
    _$GroupImpl _value,
    $Res Function(_$GroupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? members = null}) {
    return _then(
      _$GroupImpl(
        null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        null == members
            ? _value._members
            : members // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$GroupImpl implements _Group {
  const _$GroupImpl(this.name, final List<String> members) : _members = members;

  factory _$GroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupImplFromJson(json);

  @override
  final String name;
  final List<String> _members;
  @override
  List<String> get members {
    if (_members is EqualUnmodifiableListView) return _members;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_members);
  }

  @override
  String toString() {
    return 'Group(name: $name, members: $members)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupImpl &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._members, _members));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    const DeepCollectionEquality().hash(_members),
  );

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupImplCopyWith<_$GroupImpl> get copyWith =>
      __$$GroupImplCopyWithImpl<_$GroupImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupImplToJson(this);
  }
}

abstract class _Group implements Group {
  const factory _Group(final String name, final List<String> members) =
      _$GroupImpl;

  factory _Group.fromJson(Map<String, dynamic> json) = _$GroupImpl.fromJson;

  @override
  String get name;
  @override
  List<String> get members;

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupImplCopyWith<_$GroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Format _$FormatFromJson(Map<String, dynamic> json) {
  return _Format.fromJson(json);
}

/// @nodoc
mixin _$Format {
  String get name => throw _privateConstructorUsedError;
  List<Gamepart> get gameparts => throw _privateConstructorUsedError;

  /// Serializes this Format to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Format
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FormatCopyWith<Format> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FormatCopyWith<$Res> {
  factory $FormatCopyWith(Format value, $Res Function(Format) then) =
      _$FormatCopyWithImpl<$Res, Format>;
  @useResult
  $Res call({String name, List<Gamepart> gameparts});
}

/// @nodoc
class _$FormatCopyWithImpl<$Res, $Val extends Format>
    implements $FormatCopyWith<$Res> {
  _$FormatCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Format
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? gameparts = null}) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            gameparts: null == gameparts
                ? _value.gameparts
                : gameparts // ignore: cast_nullable_to_non_nullable
                      as List<Gamepart>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FormatImplCopyWith<$Res> implements $FormatCopyWith<$Res> {
  factory _$$FormatImplCopyWith(
    _$FormatImpl value,
    $Res Function(_$FormatImpl) then,
  ) = __$$FormatImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, List<Gamepart> gameparts});
}

/// @nodoc
class __$$FormatImplCopyWithImpl<$Res>
    extends _$FormatCopyWithImpl<$Res, _$FormatImpl>
    implements _$$FormatImplCopyWith<$Res> {
  __$$FormatImplCopyWithImpl(
    _$FormatImpl _value,
    $Res Function(_$FormatImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Format
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? gameparts = null}) {
    return _then(
      _$FormatImpl(
        null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        null == gameparts
            ? _value._gameparts
            : gameparts // ignore: cast_nullable_to_non_nullable
                  as List<Gamepart>,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$FormatImpl implements _Format {
  const _$FormatImpl(this.name, final List<Gamepart> gameparts)
    : _gameparts = gameparts;

  factory _$FormatImpl.fromJson(Map<String, dynamic> json) =>
      _$$FormatImplFromJson(json);

  @override
  final String name;
  final List<Gamepart> _gameparts;
  @override
  List<Gamepart> get gameparts {
    if (_gameparts is EqualUnmodifiableListView) return _gameparts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_gameparts);
  }

  @override
  String toString() {
    return 'Format(name: $name, gameparts: $gameparts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FormatImpl &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(
              other._gameparts,
              _gameparts,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    const DeepCollectionEquality().hash(_gameparts),
  );

  /// Create a copy of Format
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FormatImplCopyWith<_$FormatImpl> get copyWith =>
      __$$FormatImplCopyWithImpl<_$FormatImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FormatImplToJson(this);
  }
}

abstract class _Format implements Format {
  const factory _Format(final String name, final List<Gamepart> gameparts) =
      _$FormatImpl;

  factory _Format.fromJson(Map<String, dynamic> json) = _$FormatImpl.fromJson;

  @override
  String get name;
  @override
  List<Gamepart> get gameparts;

  /// Create a copy of Format
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FormatImplCopyWith<_$FormatImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Gamepart _$GamepartFromJson(Map<String, dynamic> json) {
  switch (json['type']) {
    case 'timed':
      return _GamepartTimed.fromJson(json);
    case 'format':
      return _GamepartFormat.fromJson(json);
    case 'penalty':
      return _GamepartPenalty.fromJson(json);

    default:
      throw CheckedFromJsonException(
        json,
        'type',
        'Gamepart',
        'Invalid union type "${json['type']}"!',
      );
  }
}

/// @nodoc
mixin _$Gamepart {
  @JsonKey(toJson: boolOrNullTrue)
  bool get repeat => throw _privateConstructorUsedError;
  @JsonKey(toJson: boolOrNullTrue)
  bool get decider => throw _privateConstructorUsedError;
  @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
  bool get sidesInverted => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String name,
      int length,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )
    timed,
    required TResult Function(
      String format,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )
    format,
    required TResult Function(
      String name,
      Penalty penalty,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )
    penalty,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String name,
      int length,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )?
    timed,
    TResult? Function(
      String format,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )?
    format,
    TResult? Function(
      String name,
      Penalty penalty,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )?
    penalty,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String name,
      int length,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )?
    timed,
    TResult Function(
      String format,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )?
    format,
    TResult Function(
      String name,
      Penalty penalty,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )?
    penalty,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GamepartTimed value) timed,
    required TResult Function(_GamepartFormat value) format,
    required TResult Function(_GamepartPenalty value) penalty,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GamepartTimed value)? timed,
    TResult? Function(_GamepartFormat value)? format,
    TResult? Function(_GamepartPenalty value)? penalty,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GamepartTimed value)? timed,
    TResult Function(_GamepartFormat value)? format,
    TResult Function(_GamepartPenalty value)? penalty,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this Gamepart to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Gamepart
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GamepartCopyWith<Gamepart> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GamepartCopyWith<$Res> {
  factory $GamepartCopyWith(Gamepart value, $Res Function(Gamepart) then) =
      _$GamepartCopyWithImpl<$Res, Gamepart>;
  @useResult
  $Res call({
    @JsonKey(toJson: boolOrNullTrue) bool repeat,
    @JsonKey(toJson: boolOrNullTrue) bool decider,
    @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue) bool sidesInverted,
  });
}

/// @nodoc
class _$GamepartCopyWithImpl<$Res, $Val extends Gamepart>
    implements $GamepartCopyWith<$Res> {
  _$GamepartCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Gamepart
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? repeat = null,
    Object? decider = null,
    Object? sidesInverted = null,
  }) {
    return _then(
      _value.copyWith(
            repeat: null == repeat
                ? _value.repeat
                : repeat // ignore: cast_nullable_to_non_nullable
                      as bool,
            decider: null == decider
                ? _value.decider
                : decider // ignore: cast_nullable_to_non_nullable
                      as bool,
            sidesInverted: null == sidesInverted
                ? _value.sidesInverted
                : sidesInverted // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GamepartTimedImplCopyWith<$Res>
    implements $GamepartCopyWith<$Res> {
  factory _$$GamepartTimedImplCopyWith(
    _$GamepartTimedImpl value,
    $Res Function(_$GamepartTimedImpl) then,
  ) = __$$GamepartTimedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    int length,
    @JsonKey(toJson: boolOrNullTrue) bool repeat,
    @JsonKey(toJson: boolOrNullTrue) bool decider,
    @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue) bool sidesInverted,
  });
}

/// @nodoc
class __$$GamepartTimedImplCopyWithImpl<$Res>
    extends _$GamepartCopyWithImpl<$Res, _$GamepartTimedImpl>
    implements _$$GamepartTimedImplCopyWith<$Res> {
  __$$GamepartTimedImplCopyWithImpl(
    _$GamepartTimedImpl _value,
    $Res Function(_$GamepartTimedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Gamepart
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? length = null,
    Object? repeat = null,
    Object? decider = null,
    Object? sidesInverted = null,
  }) {
    return _then(
      _$GamepartTimedImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        length: null == length
            ? _value.length
            : length // ignore: cast_nullable_to_non_nullable
                  as int,
        repeat: null == repeat
            ? _value.repeat
            : repeat // ignore: cast_nullable_to_non_nullable
                  as bool,
        decider: null == decider
            ? _value.decider
            : decider // ignore: cast_nullable_to_non_nullable
                  as bool,
        sidesInverted: null == sidesInverted
            ? _value.sidesInverted
            : sidesInverted // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$GamepartTimedImpl implements _GamepartTimed {
  const _$GamepartTimedImpl({
    required this.name,
    required this.length,
    @JsonKey(toJson: boolOrNullTrue) this.repeat = false,
    @JsonKey(toJson: boolOrNullTrue) this.decider = false,
    @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
    this.sidesInverted = false,
    final String? $type,
  }) : $type = $type ?? 'timed';

  factory _$GamepartTimedImpl.fromJson(Map<String, dynamic> json) =>
      _$$GamepartTimedImplFromJson(json);

  @override
  final String name;
  @override
  final int length;
  @override
  @JsonKey(toJson: boolOrNullTrue)
  final bool repeat;
  @override
  @JsonKey(toJson: boolOrNullTrue)
  final bool decider;
  @override
  @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
  final bool sidesInverted;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'Gamepart.timed(name: $name, length: $length, repeat: $repeat, decider: $decider, sidesInverted: $sidesInverted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GamepartTimedImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.length, length) || other.length == length) &&
            (identical(other.repeat, repeat) || other.repeat == repeat) &&
            (identical(other.decider, decider) || other.decider == decider) &&
            (identical(other.sidesInverted, sidesInverted) ||
                other.sidesInverted == sidesInverted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, length, repeat, decider, sidesInverted);

  /// Create a copy of Gamepart
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GamepartTimedImplCopyWith<_$GamepartTimedImpl> get copyWith =>
      __$$GamepartTimedImplCopyWithImpl<_$GamepartTimedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String name,
      int length,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )
    timed,
    required TResult Function(
      String format,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )
    format,
    required TResult Function(
      String name,
      Penalty penalty,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )
    penalty,
  }) {
    return timed(name, length, repeat, decider, sidesInverted);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String name,
      int length,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )?
    timed,
    TResult? Function(
      String format,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )?
    format,
    TResult? Function(
      String name,
      Penalty penalty,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )?
    penalty,
  }) {
    return timed?.call(name, length, repeat, decider, sidesInverted);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String name,
      int length,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )?
    timed,
    TResult Function(
      String format,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )?
    format,
    TResult Function(
      String name,
      Penalty penalty,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )?
    penalty,
    required TResult orElse(),
  }) {
    if (timed != null) {
      return timed(name, length, repeat, decider, sidesInverted);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GamepartTimed value) timed,
    required TResult Function(_GamepartFormat value) format,
    required TResult Function(_GamepartPenalty value) penalty,
  }) {
    return timed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GamepartTimed value)? timed,
    TResult? Function(_GamepartFormat value)? format,
    TResult? Function(_GamepartPenalty value)? penalty,
  }) {
    return timed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GamepartTimed value)? timed,
    TResult Function(_GamepartFormat value)? format,
    TResult Function(_GamepartPenalty value)? penalty,
    required TResult orElse(),
  }) {
    if (timed != null) {
      return timed(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$GamepartTimedImplToJson(this);
  }
}

abstract class _GamepartTimed implements Gamepart {
  const factory _GamepartTimed({
    required final String name,
    required final int length,
    @JsonKey(toJson: boolOrNullTrue) final bool repeat,
    @JsonKey(toJson: boolOrNullTrue) final bool decider,
    @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
    final bool sidesInverted,
  }) = _$GamepartTimedImpl;

  factory _GamepartTimed.fromJson(Map<String, dynamic> json) =
      _$GamepartTimedImpl.fromJson;

  String get name;
  int get length;
  @override
  @JsonKey(toJson: boolOrNullTrue)
  bool get repeat;
  @override
  @JsonKey(toJson: boolOrNullTrue)
  bool get decider;
  @override
  @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
  bool get sidesInverted;

  /// Create a copy of Gamepart
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GamepartTimedImplCopyWith<_$GamepartTimedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GamepartFormatImplCopyWith<$Res>
    implements $GamepartCopyWith<$Res> {
  factory _$$GamepartFormatImplCopyWith(
    _$GamepartFormatImpl value,
    $Res Function(_$GamepartFormatImpl) then,
  ) = __$$GamepartFormatImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String format,
    @JsonKey(toJson: boolOrNullTrue) bool repeat,
    @JsonKey(toJson: boolOrNullTrue) bool decider,
    @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue) bool sidesInverted,
  });
}

/// @nodoc
class __$$GamepartFormatImplCopyWithImpl<$Res>
    extends _$GamepartCopyWithImpl<$Res, _$GamepartFormatImpl>
    implements _$$GamepartFormatImplCopyWith<$Res> {
  __$$GamepartFormatImplCopyWithImpl(
    _$GamepartFormatImpl _value,
    $Res Function(_$GamepartFormatImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Gamepart
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? format = null,
    Object? repeat = null,
    Object? decider = null,
    Object? sidesInverted = null,
  }) {
    return _then(
      _$GamepartFormatImpl(
        format: null == format
            ? _value.format
            : format // ignore: cast_nullable_to_non_nullable
                  as String,
        repeat: null == repeat
            ? _value.repeat
            : repeat // ignore: cast_nullable_to_non_nullable
                  as bool,
        decider: null == decider
            ? _value.decider
            : decider // ignore: cast_nullable_to_non_nullable
                  as bool,
        sidesInverted: null == sidesInverted
            ? _value.sidesInverted
            : sidesInverted // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$GamepartFormatImpl implements _GamepartFormat {
  const _$GamepartFormatImpl({
    required this.format,
    @JsonKey(toJson: boolOrNullTrue) this.repeat = false,
    @JsonKey(toJson: boolOrNullTrue) this.decider = false,
    @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
    this.sidesInverted = false,
    final String? $type,
  }) : $type = $type ?? 'format';

  factory _$GamepartFormatImpl.fromJson(Map<String, dynamic> json) =>
      _$$GamepartFormatImplFromJson(json);

  @override
  final String format;
  // nested reference to another format
  @override
  @JsonKey(toJson: boolOrNullTrue)
  final bool repeat;
  @override
  @JsonKey(toJson: boolOrNullTrue)
  final bool decider;
  @override
  @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
  final bool sidesInverted;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'Gamepart.format(format: $format, repeat: $repeat, decider: $decider, sidesInverted: $sidesInverted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GamepartFormatImpl &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.repeat, repeat) || other.repeat == repeat) &&
            (identical(other.decider, decider) || other.decider == decider) &&
            (identical(other.sidesInverted, sidesInverted) ||
                other.sidesInverted == sidesInverted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, format, repeat, decider, sidesInverted);

  /// Create a copy of Gamepart
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GamepartFormatImplCopyWith<_$GamepartFormatImpl> get copyWith =>
      __$$GamepartFormatImplCopyWithImpl<_$GamepartFormatImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String name,
      int length,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )
    timed,
    required TResult Function(
      String format,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )
    format,
    required TResult Function(
      String name,
      Penalty penalty,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )
    penalty,
  }) {
    return format(this.format, repeat, decider, sidesInverted);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String name,
      int length,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )?
    timed,
    TResult? Function(
      String format,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )?
    format,
    TResult? Function(
      String name,
      Penalty penalty,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )?
    penalty,
  }) {
    return format?.call(this.format, repeat, decider, sidesInverted);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String name,
      int length,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )?
    timed,
    TResult Function(
      String format,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )?
    format,
    TResult Function(
      String name,
      Penalty penalty,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )?
    penalty,
    required TResult orElse(),
  }) {
    if (format != null) {
      return format(this.format, repeat, decider, sidesInverted);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GamepartTimed value) timed,
    required TResult Function(_GamepartFormat value) format,
    required TResult Function(_GamepartPenalty value) penalty,
  }) {
    return format(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GamepartTimed value)? timed,
    TResult? Function(_GamepartFormat value)? format,
    TResult? Function(_GamepartPenalty value)? penalty,
  }) {
    return format?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GamepartTimed value)? timed,
    TResult Function(_GamepartFormat value)? format,
    TResult Function(_GamepartPenalty value)? penalty,
    required TResult orElse(),
  }) {
    if (format != null) {
      return format(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$GamepartFormatImplToJson(this);
  }
}

abstract class _GamepartFormat implements Gamepart {
  const factory _GamepartFormat({
    required final String format,
    @JsonKey(toJson: boolOrNullTrue) final bool repeat,
    @JsonKey(toJson: boolOrNullTrue) final bool decider,
    @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
    final bool sidesInverted,
  }) = _$GamepartFormatImpl;

  factory _GamepartFormat.fromJson(Map<String, dynamic> json) =
      _$GamepartFormatImpl.fromJson;

  String get format; // nested reference to another format
  @override
  @JsonKey(toJson: boolOrNullTrue)
  bool get repeat;
  @override
  @JsonKey(toJson: boolOrNullTrue)
  bool get decider;
  @override
  @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
  bool get sidesInverted;

  /// Create a copy of Gamepart
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GamepartFormatImplCopyWith<_$GamepartFormatImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GamepartPenaltyImplCopyWith<$Res>
    implements $GamepartCopyWith<$Res> {
  factory _$$GamepartPenaltyImplCopyWith(
    _$GamepartPenaltyImpl value,
    $Res Function(_$GamepartPenaltyImpl) then,
  ) = __$$GamepartPenaltyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    Penalty penalty,
    @JsonKey(toJson: boolOrNullTrue) bool repeat,
    @JsonKey(toJson: boolOrNullTrue) bool decider,
    @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue) bool sidesInverted,
  });

  $PenaltyCopyWith<$Res> get penalty;
}

/// @nodoc
class __$$GamepartPenaltyImplCopyWithImpl<$Res>
    extends _$GamepartCopyWithImpl<$Res, _$GamepartPenaltyImpl>
    implements _$$GamepartPenaltyImplCopyWith<$Res> {
  __$$GamepartPenaltyImplCopyWithImpl(
    _$GamepartPenaltyImpl _value,
    $Res Function(_$GamepartPenaltyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Gamepart
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? penalty = null,
    Object? repeat = null,
    Object? decider = null,
    Object? sidesInverted = null,
  }) {
    return _then(
      _$GamepartPenaltyImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        penalty: null == penalty
            ? _value.penalty
            : penalty // ignore: cast_nullable_to_non_nullable
                  as Penalty,
        repeat: null == repeat
            ? _value.repeat
            : repeat // ignore: cast_nullable_to_non_nullable
                  as bool,
        decider: null == decider
            ? _value.decider
            : decider // ignore: cast_nullable_to_non_nullable
                  as bool,
        sidesInverted: null == sidesInverted
            ? _value.sidesInverted
            : sidesInverted // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }

  /// Create a copy of Gamepart
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PenaltyCopyWith<$Res> get penalty {
    return $PenaltyCopyWith<$Res>(_value.penalty, (value) {
      return _then(_value.copyWith(penalty: value));
    });
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$GamepartPenaltyImpl implements _GamepartPenalty {
  const _$GamepartPenaltyImpl({
    required this.name,
    required this.penalty,
    @JsonKey(toJson: boolOrNullTrue) this.repeat = false,
    @JsonKey(toJson: boolOrNullTrue) this.decider = false,
    @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
    this.sidesInverted = false,
    final String? $type,
  }) : $type = $type ?? 'penalty';

  factory _$GamepartPenaltyImpl.fromJson(Map<String, dynamic> json) =>
      _$$GamepartPenaltyImplFromJson(json);

  @override
  final String name;
  @override
  final Penalty penalty;
  @override
  @JsonKey(toJson: boolOrNullTrue)
  final bool repeat;
  @override
  @JsonKey(toJson: boolOrNullTrue)
  final bool decider;
  @override
  @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
  final bool sidesInverted;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'Gamepart.penalty(name: $name, penalty: $penalty, repeat: $repeat, decider: $decider, sidesInverted: $sidesInverted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GamepartPenaltyImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.penalty, penalty) || other.penalty == penalty) &&
            (identical(other.repeat, repeat) || other.repeat == repeat) &&
            (identical(other.decider, decider) || other.decider == decider) &&
            (identical(other.sidesInverted, sidesInverted) ||
                other.sidesInverted == sidesInverted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, penalty, repeat, decider, sidesInverted);

  /// Create a copy of Gamepart
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GamepartPenaltyImplCopyWith<_$GamepartPenaltyImpl> get copyWith =>
      __$$GamepartPenaltyImplCopyWithImpl<_$GamepartPenaltyImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String name,
      int length,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )
    timed,
    required TResult Function(
      String format,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )
    format,
    required TResult Function(
      String name,
      Penalty penalty,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )
    penalty,
  }) {
    return penalty(name, this.penalty, repeat, decider, sidesInverted);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String name,
      int length,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )?
    timed,
    TResult? Function(
      String format,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )?
    format,
    TResult? Function(
      String name,
      Penalty penalty,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )?
    penalty,
  }) {
    return penalty?.call(name, this.penalty, repeat, decider, sidesInverted);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String name,
      int length,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )?
    timed,
    TResult Function(
      String format,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )?
    format,
    TResult Function(
      String name,
      Penalty penalty,
      @JsonKey(toJson: boolOrNullTrue) bool repeat,
      @JsonKey(toJson: boolOrNullTrue) bool decider,
      @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
      bool sidesInverted,
    )?
    penalty,
    required TResult orElse(),
  }) {
    if (penalty != null) {
      return penalty(name, this.penalty, repeat, decider, sidesInverted);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GamepartTimed value) timed,
    required TResult Function(_GamepartFormat value) format,
    required TResult Function(_GamepartPenalty value) penalty,
  }) {
    return penalty(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GamepartTimed value)? timed,
    TResult? Function(_GamepartFormat value)? format,
    TResult? Function(_GamepartPenalty value)? penalty,
  }) {
    return penalty?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GamepartTimed value)? timed,
    TResult Function(_GamepartFormat value)? format,
    TResult Function(_GamepartPenalty value)? penalty,
    required TResult orElse(),
  }) {
    if (penalty != null) {
      return penalty(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$GamepartPenaltyImplToJson(this);
  }
}

abstract class _GamepartPenalty implements Gamepart {
  const factory _GamepartPenalty({
    required final String name,
    required final Penalty penalty,
    @JsonKey(toJson: boolOrNullTrue) final bool repeat,
    @JsonKey(toJson: boolOrNullTrue) final bool decider,
    @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
    final bool sidesInverted,
  }) = _$GamepartPenaltyImpl;

  factory _GamepartPenalty.fromJson(Map<String, dynamic> json) =
      _$GamepartPenaltyImpl.fromJson;

  String get name;
  Penalty get penalty;
  @override
  @JsonKey(toJson: boolOrNullTrue)
  bool get repeat;
  @override
  @JsonKey(toJson: boolOrNullTrue)
  bool get decider;
  @override
  @JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue)
  bool get sidesInverted;

  /// Create a copy of Gamepart
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GamepartPenaltyImplCopyWith<_$GamepartPenaltyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Penalty _$PenaltyFromJson(Map<String, dynamic> json) {
  return _Penalty.fromJson(json);
}

/// @nodoc
mixin _$Penalty {
  Shooting get shooting => throw _privateConstructorUsedError;

  /// Serializes this Penalty to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Penalty
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PenaltyCopyWith<Penalty> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PenaltyCopyWith<$Res> {
  factory $PenaltyCopyWith(Penalty value, $Res Function(Penalty) then) =
      _$PenaltyCopyWithImpl<$Res, Penalty>;
  @useResult
  $Res call({Shooting shooting});

  $ShootingCopyWith<$Res> get shooting;
}

/// @nodoc
class _$PenaltyCopyWithImpl<$Res, $Val extends Penalty>
    implements $PenaltyCopyWith<$Res> {
  _$PenaltyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Penalty
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? shooting = null}) {
    return _then(
      _value.copyWith(
            shooting: null == shooting
                ? _value.shooting
                : shooting // ignore: cast_nullable_to_non_nullable
                      as Shooting,
          )
          as $Val,
    );
  }

  /// Create a copy of Penalty
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ShootingCopyWith<$Res> get shooting {
    return $ShootingCopyWith<$Res>(_value.shooting, (value) {
      return _then(_value.copyWith(shooting: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PenaltyImplCopyWith<$Res> implements $PenaltyCopyWith<$Res> {
  factory _$$PenaltyImplCopyWith(
    _$PenaltyImpl value,
    $Res Function(_$PenaltyImpl) then,
  ) = __$$PenaltyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Shooting shooting});

  @override
  $ShootingCopyWith<$Res> get shooting;
}

/// @nodoc
class __$$PenaltyImplCopyWithImpl<$Res>
    extends _$PenaltyCopyWithImpl<$Res, _$PenaltyImpl>
    implements _$$PenaltyImplCopyWith<$Res> {
  __$$PenaltyImplCopyWithImpl(
    _$PenaltyImpl _value,
    $Res Function(_$PenaltyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Penalty
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? shooting = null}) {
    return _then(
      _$PenaltyImpl(
        null == shooting
            ? _value.shooting
            : shooting // ignore: cast_nullable_to_non_nullable
                  as Shooting,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$PenaltyImpl implements _Penalty {
  const _$PenaltyImpl(this.shooting);

  factory _$PenaltyImpl.fromJson(Map<String, dynamic> json) =>
      _$$PenaltyImplFromJson(json);

  @override
  final Shooting shooting;

  @override
  String toString() {
    return 'Penalty(shooting: $shooting)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PenaltyImpl &&
            (identical(other.shooting, shooting) ||
                other.shooting == shooting));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, shooting);

  /// Create a copy of Penalty
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PenaltyImplCopyWith<_$PenaltyImpl> get copyWith =>
      __$$PenaltyImplCopyWithImpl<_$PenaltyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PenaltyImplToJson(this);
  }
}

abstract class _Penalty implements Penalty {
  const factory _Penalty(final Shooting shooting) = _$PenaltyImpl;

  factory _Penalty.fromJson(Map<String, dynamic> json) = _$PenaltyImpl.fromJson;

  @override
  Shooting get shooting;

  /// Create a copy of Penalty
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PenaltyImplCopyWith<_$PenaltyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Shooting _$ShootingFromJson(Map<String, dynamic> json) {
  return _Shooting.fromJson(json);
}

/// @nodoc
mixin _$Shooting {
  int get team => throw _privateConstructorUsedError;
  int get player => throw _privateConstructorUsedError;

  /// Serializes this Shooting to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Shooting
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShootingCopyWith<Shooting> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShootingCopyWith<$Res> {
  factory $ShootingCopyWith(Shooting value, $Res Function(Shooting) then) =
      _$ShootingCopyWithImpl<$Res, Shooting>;
  @useResult
  $Res call({int team, int player});
}

/// @nodoc
class _$ShootingCopyWithImpl<$Res, $Val extends Shooting>
    implements $ShootingCopyWith<$Res> {
  _$ShootingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Shooting
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? team = null, Object? player = null}) {
    return _then(
      _value.copyWith(
            team: null == team
                ? _value.team
                : team // ignore: cast_nullable_to_non_nullable
                      as int,
            player: null == player
                ? _value.player
                : player // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShootingImplCopyWith<$Res>
    implements $ShootingCopyWith<$Res> {
  factory _$$ShootingImplCopyWith(
    _$ShootingImpl value,
    $Res Function(_$ShootingImpl) then,
  ) = __$$ShootingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int team, int player});
}

/// @nodoc
class __$$ShootingImplCopyWithImpl<$Res>
    extends _$ShootingCopyWithImpl<$Res, _$ShootingImpl>
    implements _$$ShootingImplCopyWith<$Res> {
  __$$ShootingImplCopyWithImpl(
    _$ShootingImpl _value,
    $Res Function(_$ShootingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Shooting
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? team = null, Object? player = null}) {
    return _then(
      _$ShootingImpl(
        null == team
            ? _value.team
            : team // ignore: cast_nullable_to_non_nullable
                  as int,
        null == player
            ? _value.player
            : player // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$ShootingImpl implements _Shooting {
  const _$ShootingImpl(this.team, this.player);

  factory _$ShootingImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShootingImplFromJson(json);

  @override
  final int team;
  @override
  final int player;

  @override
  String toString() {
    return 'Shooting(team: $team, player: $player)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShootingImpl &&
            (identical(other.team, team) || other.team == team) &&
            (identical(other.player, player) || other.player == player));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, team, player);

  /// Create a copy of Shooting
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShootingImplCopyWith<_$ShootingImpl> get copyWith =>
      __$$ShootingImplCopyWithImpl<_$ShootingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShootingImplToJson(this);
  }
}

abstract class _Shooting implements Shooting {
  const factory _Shooting(final int team, final int player) = _$ShootingImpl;

  factory _Shooting.fromJson(Map<String, dynamic> json) =
      _$ShootingImpl.fromJson;

  @override
  int get team;
  @override
  int get player;

  /// Create a copy of Shooting
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShootingImplCopyWith<_$ShootingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
