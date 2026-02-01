// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'md.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchdayImpl _$$MatchdayImplFromJson(Map<String, dynamic> json) =>
    _$MatchdayImpl(
      Meta.fromJson(json['meta'] as Map<String, dynamic>),
      (json['teams'] as List<dynamic>)
          .map((e) => Team.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['groups'] as List<dynamic>)
          .map((e) => Group.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['games'] as List<dynamic>)
          .map((e) => Game.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$MatchdayImplToJson(_$MatchdayImpl instance) =>
    <String, dynamic>{
      'meta': instance.meta,
      'teams': instance.teams,
      'groups': instance.groups,
      'games': instance.games,
    };

_$MetaImpl _$$MetaImplFromJson(Map<String, dynamic> json) => _$MetaImpl(
  gameIndex: (json['game_i'] as num?)?.toInt() ?? 0,
  currentGamepart: (json['cur_gamepart'] as num?)?.toInt() ?? 0,
  sidesInverted: json['sides_inverted'] as bool? ?? false,
  paused: json['paused'] as bool? ?? true,
  remainingTime: (json['remaining_time'] as num?)?.toInt() ?? 0,
  lastUnpaused: (json['last_unpaused'] as num?)?.toInt() ?? 0,
  allowRemoteGameCreation: json['allow_remote_game_creation'] as bool? ?? false,
  delay: (json['delay'] as num?)?.toInt() ?? 0,
  widgetScoreboard: json['widgetScoreboard'] as bool? ?? false,
  widgetGameplan: json['widgetGameplan'] as bool? ?? false,
  widgetLiveplan: json['widgetLiveplan'] as bool? ?? false,
  widgetGamestart: json['widgetGamestart'] as bool? ?? false,
  widgetAd: json['widgetAd'] as bool? ?? false,
  streamStarted: json['streamStarted'] as bool? ?? false,
  replayStarted: json['replayStarted'] as bool? ?? false,
  formats: (json['formats'] as List<dynamic>)
      .map((e) => Format.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$MetaImplToJson(_$MetaImpl instance) =>
    <String, dynamic>{
      if (intOrNullNot0(instance.gameIndex) case final value?) 'game_i': value,
      if (intOrNullNot0(instance.currentGamepart) case final value?)
        'cur_gamepart': value,
      if (boolOrNullTrue(instance.sidesInverted) case final value?)
        'sides_inverted': value,
      if (boolOrNullFalse(instance.paused) case final value?) 'paused': value,
      'remaining_time': instance.remainingTime,
      'last_unpaused': instance.lastUnpaused,
      if (boolOrNullTrue(instance.allowRemoteGameCreation) case final value?)
        'allow_remote_game_creation': value,
      'delay': instance.delay,
      'widgetScoreboard': instance.widgetScoreboard,
      'widgetGameplan': instance.widgetGameplan,
      'widgetLiveplan': instance.widgetLiveplan,
      'widgetGamestart': instance.widgetGamestart,
      'widgetAd': instance.widgetAd,
      'streamStarted': instance.streamStarted,
      'replayStarted': instance.replayStarted,
      'formats': instance.formats,
    };

_$GameImpl _$$GameImplFromJson(Map<String, dynamic> json) => _$GameImpl(
  name: json['name'] as String,
  team1: GameTeamSlot.fromJson(json['1'] as Map<String, dynamic>),
  team2: GameTeamSlot.fromJson(json['2'] as Map<String, dynamic>),
  groups: (json['groups'] as List<dynamic>?)?.map((e) => e as String).toList(),
  format: GameFormat.fromJson(json['format'] as Map<String, dynamic>),
  decider: json['decider'] as bool? ?? false,
  protected: json['protected'] as bool? ?? true,
  actions: (json['actions'] as List<dynamic>?)
      ?.map((e) => GameAction.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$GameImplToJson(_$GameImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      '1': instance.team1,
      '2': instance.team2,
      if (instance.groups case final value?) 'groups': value,
      'format': instance.format,
      if (boolOrNullTrue(instance.decider) case final value?) 'decider': value,
      'protected': instance.protected,
      if (instance.actions case final value?) 'actions': value,
    };

_$GameActionGoalImpl _$$GameActionGoalImplFromJson(Map<String, dynamic> json) =>
    _$GameActionGoalImpl(
      id: (json['id'] as num).toInt(),
      timeGame: (json['time_game'] as num?)?.toInt(),
      timespanGame: (json['timespan_game'] as num?)?.toInt(),
      timeUnix: (json['time_unix'] as num?)?.toInt(),
      timespanUnix: (json['timespan_unix'] as num?)?.toInt(),
      players_involved: (json['players_involved'] as List<dynamic>?)
          ?.map(
            (e) => GameActionPlayerInvolved.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      change: GameActionChange.fromJson(json['change'] as Map<String, dynamic>),
      triggersAction: (json['triggers_action'] as num?)?.toInt(),
      description: json['description'] as String?,
      done: json['done'] as bool? ?? true,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$GameActionGoalImplToJson(
  _$GameActionGoalImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  if (instance.timeGame case final value?) 'time_game': value,
  if (instance.timespanGame case final value?) 'timespan_game': value,
  if (instance.timeUnix case final value?) 'time_unix': value,
  if (instance.timespanUnix case final value?) 'timespan_unix': value,
  if (instance.players_involved case final value?) 'players_involved': value,
  'change': instance.change,
  if (instance.triggersAction case final value?) 'triggers_action': value,
  if (instance.description case final value?) 'description': value,
  if (boolOrNullFalse(instance.done) case final value?) 'done': value,
  'type': instance.$type,
};

_$GameActionFoulImpl _$$GameActionFoulImplFromJson(Map<String, dynamic> json) =>
    _$GameActionFoulImpl(
      id: (json['id'] as num).toInt(),
      timeGame: (json['time_game'] as num?)?.toInt(),
      timespanGame: (json['timespan_game'] as num?)?.toInt(),
      timeUnix: (json['time_unix'] as num?)?.toInt(),
      timespanUnix: (json['timespan_unix'] as num?)?.toInt(),
      players_involved: (json['players_involved'] as List<dynamic>?)
          ?.map(
            (e) => GameActionPlayerInvolved.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      triggersAction: (json['triggers_action'] as num?)?.toInt(),
      description: json['description'] as String?,
      done: json['done'] as bool? ?? true,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$GameActionFoulImplToJson(
  _$GameActionFoulImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  if (instance.timeGame case final value?) 'time_game': value,
  if (instance.timespanGame case final value?) 'timespan_game': value,
  if (instance.timeUnix case final value?) 'time_unix': value,
  if (instance.timespanUnix case final value?) 'timespan_unix': value,
  if (instance.players_involved case final value?) 'players_involved': value,
  if (instance.triggersAction case final value?) 'triggers_action': value,
  if (instance.description case final value?) 'description': value,
  if (boolOrNullFalse(instance.done) case final value?) 'done': value,
  'type': instance.$type,
};

_$GameActionPenaltyImpl _$$GameActionPenaltyImplFromJson(
  Map<String, dynamic> json,
) => _$GameActionPenaltyImpl(
  id: (json['id'] as num).toInt(),
  timeGame: (json['time_game'] as num?)?.toInt(),
  timespanGame: (json['timespan_game'] as num?)?.toInt(),
  timeUnix: (json['time_unix'] as num?)?.toInt(),
  timespanUnix: (json['timespan_unix'] as num?)?.toInt(),
  players_involved: (json['players_involved'] as List<dynamic>?)
      ?.map((e) => GameActionPlayerInvolved.fromJson(e as Map<String, dynamic>))
      .toList(),
  description: json['description'] as String?,
  done: json['done'] as bool? ?? true,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$GameActionPenaltyImplToJson(
  _$GameActionPenaltyImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  if (instance.timeGame case final value?) 'time_game': value,
  if (instance.timespanGame case final value?) 'timespan_game': value,
  if (instance.timeUnix case final value?) 'time_unix': value,
  if (instance.timespanUnix case final value?) 'timespan_unix': value,
  if (instance.players_involved case final value?) 'players_involved': value,
  if (instance.description case final value?) 'description': value,
  if (boolOrNullFalse(instance.done) case final value?) 'done': value,
  'type': instance.$type,
};

_$GameActionOutballImpl _$$GameActionOutballImplFromJson(
  Map<String, dynamic> json,
) => _$GameActionOutballImpl(
  id: (json['id'] as num).toInt(),
  timeGame: (json['time_game'] as num?)?.toInt(),
  timespanGame: (json['timespan_game'] as num?)?.toInt(),
  timeUnix: (json['time_unix'] as num?)?.toInt(),
  timespanUnix: (json['timespan_unix'] as num?)?.toInt(),
  players_involved: (json['players_involved'] as List<dynamic>?)
      ?.map((e) => GameActionPlayerInvolved.fromJson(e as Map<String, dynamic>))
      .toList(),
  team: (json['team'] as num).toInt(),
  description: json['description'] as String?,
  done: json['done'] as bool? ?? true,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$GameActionOutballImplToJson(
  _$GameActionOutballImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  if (instance.timeGame case final value?) 'time_game': value,
  if (instance.timespanGame case final value?) 'timespan_game': value,
  if (instance.timeUnix case final value?) 'time_unix': value,
  if (instance.timespanUnix case final value?) 'timespan_unix': value,
  if (instance.players_involved case final value?) 'players_involved': value,
  'team': instance.team,
  if (instance.description case final value?) 'description': value,
  if (boolOrNullFalse(instance.done) case final value?) 'done': value,
  'type': instance.$type,
};

_$GameActionPlayerInvolvedImpl _$$GameActionPlayerInvolvedImplFromJson(
  Map<String, dynamic> json,
) => _$GameActionPlayerInvolvedImpl(
  json['name'] as String,
  json['role'] as String,
);

Map<String, dynamic> _$$GameActionPlayerInvolvedImplToJson(
  _$GameActionPlayerInvolvedImpl instance,
) => <String, dynamic>{'name': instance.name, 'role': instance.role};

_$GameActionChangeImpl _$$GameActionChangeImplFromJson(
  Map<String, dynamic> json,
) => _$GameActionChangeImpl(
  GameActionChangeScore.fromJson(json['score'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$GameActionChangeImplToJson(
  _$GameActionChangeImpl instance,
) => <String, dynamic>{'score': instance.score};

_$GameActionChangeScoreImpl _$$GameActionChangeScoreImplFromJson(
  Map<String, dynamic> json,
) => _$GameActionChangeScoreImpl(
  t1: (json['1'] as num?)?.toInt() ?? 0,
  t2: (json['2'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$GameActionChangeScoreImplToJson(
  _$GameActionChangeScoreImpl instance,
) => <String, dynamic>{
  if (intOrNullNot0(instance.t1) case final value?) '1': value,
  if (intOrNullNot0(instance.t2) case final value?) '2': value,
};

_$GameFormatImpl _$$GameFormatImplFromJson(Map<String, dynamic> json) =>
    _$GameFormatImpl(
      name: json['name'] as String,
      decider: json['decider'] as bool? ?? false,
    );

Map<String, dynamic> _$$GameFormatImplToJson(_$GameFormatImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      if (boolOrNullTrue(instance.decider) case final value?) 'decider': value,
    };

_$GameTeamSlotByNameImpl _$$GameTeamSlotByNameImplFromJson(
  Map<String, dynamic> json,
) => _$GameTeamSlotByNameImpl(
  name: json['name'] as String,
  missing: json['missing'] == null
      ? null
      : MissingInfo.fromJson(json['missing'] as Map<String, dynamic>),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$GameTeamSlotByNameImplToJson(
  _$GameTeamSlotByNameImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  if (instance.missing case final value?) 'missing': value,
  'type': instance.$type,
};

_$GameTeamSlotByQueryImpl _$$GameTeamSlotByQueryImplFromJson(
  Map<String, dynamic> json,
) => _$GameTeamSlotByQueryImpl(
  query: GameQuery.fromJson(json['query'] as Map<String, dynamic>),
  missing: json['missing'] == null
      ? null
      : MissingInfo.fromJson(json['missing'] as Map<String, dynamic>),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$GameTeamSlotByQueryImplToJson(
  _$GameTeamSlotByQueryImpl instance,
) => <String, dynamic>{
  'query': instance.query,
  if (instance.missing case final value?) 'missing': value,
  'type': instance.$type,
};

_$GameTeamSlotByQueryResolvedImpl _$$GameTeamSlotByQueryResolvedImplFromJson(
  Map<String, dynamic> json,
) => _$GameTeamSlotByQueryResolvedImpl(
  name: json['name'] as String,
  q: _GameTeamSlotByQuery.fromJson(json['q'] as Map<String, dynamic>),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$GameTeamSlotByQueryResolvedImplToJson(
  _$GameTeamSlotByQueryResolvedImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'q': instance.q,
  'type': instance.$type,
};

_$GameQueryByGroupPlaceImpl _$$GameQueryByGroupPlaceImplFromJson(
  Map<String, dynamic> json,
) => _$GameQueryByGroupPlaceImpl(
  json['group'] as String,
  (json['place'] as num).toInt(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$GameQueryByGroupPlaceImplToJson(
  _$GameQueryByGroupPlaceImpl instance,
) => <String, dynamic>{
  'group': instance.group,
  'place': instance.place,
  'type': instance.$type,
};

_$GameQueryByGameWinnerImpl _$$GameQueryByGameWinnerImplFromJson(
  Map<String, dynamic> json,
) => _$GameQueryByGameWinnerImpl(
  (json['gameIndex'] as num).toInt(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$GameQueryByGameWinnerImplToJson(
  _$GameQueryByGameWinnerImpl instance,
) => <String, dynamic>{'gameIndex': instance.gameIndex, 'type': instance.$type};

_$GameQueryByGameLoserImpl _$$GameQueryByGameLoserImplFromJson(
  Map<String, dynamic> json,
) => _$GameQueryByGameLoserImpl(
  (json['gameIndex'] as num).toInt(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$GameQueryByGameLoserImplToJson(
  _$GameQueryByGameLoserImpl instance,
) => <String, dynamic>{'gameIndex': instance.gameIndex, 'type': instance.$type};

_$MissingInfoImpl _$$MissingInfoImplFromJson(Map<String, dynamic> json) =>
    _$MissingInfoImpl(json['reason'] as String);

Map<String, dynamic> _$$MissingInfoImplToJson(_$MissingInfoImpl instance) =>
    <String, dynamic>{'reason': instance.reason};

_$PlayerImpl _$$PlayerImplFromJson(Map<String, dynamic> json) =>
    _$PlayerImpl(json['name'] as String, json['role'] as String);

Map<String, dynamic> _$$PlayerImplToJson(_$PlayerImpl instance) =>
    <String, dynamic>{'name': instance.name, 'role': instance.role};

_$TeamImpl _$$TeamImplFromJson(Map<String, dynamic> json) => _$TeamImpl(
  json['name'] as String,
  json['logo_uri'] as String,
  json['color'] as String,
  (json['players'] as List<dynamic>)
      .map((e) => Player.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$TeamImplToJson(_$TeamImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'logo_uri': instance.logoUri,
      'color': instance.color,
      'players': instance.players,
    };

_$GroupImpl _$$GroupImplFromJson(Map<String, dynamic> json) => _$GroupImpl(
  json['name'] as String,
  (json['members'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$$GroupImplToJson(_$GroupImpl instance) =>
    <String, dynamic>{'name': instance.name, 'members': instance.members};

_$FormatImpl _$$FormatImplFromJson(Map<String, dynamic> json) => _$FormatImpl(
  json['name'] as String,
  (json['gameparts'] as List<dynamic>)
      .map((e) => Gamepart.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$FormatImplToJson(_$FormatImpl instance) =>
    <String, dynamic>{'name': instance.name, 'gameparts': instance.gameparts};

_$GamepartTimedImpl _$$GamepartTimedImplFromJson(Map<String, dynamic> json) =>
    _$GamepartTimedImpl(
      name: json['name'] as String,
      length: (json['length'] as num).toInt(),
      repeat: json['repeat'] as bool? ?? false,
      decider: json['decider'] as bool? ?? false,
      sidesInverted: json['sides_inverted'] as bool? ?? false,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$GamepartTimedImplToJson(_$GamepartTimedImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'length': instance.length,
      if (boolOrNullTrue(instance.repeat) case final value?) 'repeat': value,
      if (boolOrNullTrue(instance.decider) case final value?) 'decider': value,
      if (boolOrNullTrue(instance.sidesInverted) case final value?)
        'sides_inverted': value,
      'type': instance.$type,
    };

_$GamepartFormatImpl _$$GamepartFormatImplFromJson(Map<String, dynamic> json) =>
    _$GamepartFormatImpl(
      format: json['format'] as String,
      repeat: json['repeat'] as bool? ?? false,
      decider: json['decider'] as bool? ?? false,
      sidesInverted: json['sides_inverted'] as bool? ?? false,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$GamepartFormatImplToJson(
  _$GamepartFormatImpl instance,
) => <String, dynamic>{
  'format': instance.format,
  if (boolOrNullTrue(instance.repeat) case final value?) 'repeat': value,
  if (boolOrNullTrue(instance.decider) case final value?) 'decider': value,
  if (boolOrNullTrue(instance.sidesInverted) case final value?)
    'sides_inverted': value,
  'type': instance.$type,
};

_$GamepartPenaltyImpl _$$GamepartPenaltyImplFromJson(
  Map<String, dynamic> json,
) => _$GamepartPenaltyImpl(
  name: json['name'] as String,
  penalty: Penalty.fromJson(json['penalty'] as Map<String, dynamic>),
  repeat: json['repeat'] as bool? ?? false,
  decider: json['decider'] as bool? ?? false,
  sidesInverted: json['sides_inverted'] as bool? ?? false,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$GamepartPenaltyImplToJson(
  _$GamepartPenaltyImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'penalty': instance.penalty,
  if (boolOrNullTrue(instance.repeat) case final value?) 'repeat': value,
  if (boolOrNullTrue(instance.decider) case final value?) 'decider': value,
  if (boolOrNullTrue(instance.sidesInverted) case final value?)
    'sides_inverted': value,
  'type': instance.$type,
};

_$PenaltyImpl _$$PenaltyImplFromJson(Map<String, dynamic> json) =>
    _$PenaltyImpl(Shooting.fromJson(json['shooting'] as Map<String, dynamic>));

Map<String, dynamic> _$$PenaltyImplToJson(_$PenaltyImpl instance) =>
    <String, dynamic>{'shooting': instance.shooting};

_$ShootingImpl _$$ShootingImplFromJson(Map<String, dynamic> json) =>
    _$ShootingImpl(
      (json['team'] as num).toInt(),
      (json['player'] as num).toInt(),
    );

Map<String, dynamic> _$$ShootingImplToJson(_$ShootingImpl instance) =>
    <String, dynamic>{'team': instance.team, 'player': instance.player};
