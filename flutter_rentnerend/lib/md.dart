// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

//import 'package:flutter_rentnerend/lib.dart';

part 'md.freezed.dart';
part 'md.g.dart';

@freezed
class Matchday with _$Matchday {
	const Matchday._(); // This is needed to allow methods/getters

	const factory Matchday(
		Meta meta,
		List<Team> teams,
		List<Group> groups,
		List<Game> games,
	) = _Matchday;

	factory Matchday.fromJson(Map<String, dynamic> json) => _$MatchdayFromJson(json);

	Game? get currentGame {
		final i = meta.gameIndex;
		if (i < 0 || i >= games.length) return null;
		return games[i];
	}

	Format? get currentFormat {
		final String? name = currentGame?.format.name;
		if(name == null) return null;
		return meta.formats.firstWhereOrNull(
			(f) => f.name == name
		);
	}

	GamePart? get currentGamePart {
		final Format? format = currentFormat;
		if(format == null) return null;
		if(meta.currentGamepart >= format.gameparts.length) return null;
		return format.gameparts[meta.currentGamepart];
	}

	Matchday nextGame() {
		final next = meta.gameIndex + 1;
		if (next >= games.length) return this;
		return copyWith(meta: meta.copyWith(gameIndex: next));
	}

	Matchday prevGame() {
		final prev = meta.gameIndex - 1;
		if (prev < 0) return this;
		return copyWith(meta: meta.copyWith(gameIndex: prev));
	}

	Matchday switchSides() {
		return copyWith(meta: meta.copyWith(sidesInverted: !meta.sidesInverted));
	}

	Matchday goalAdd({required int team}) {
		Game? g = currentGame;
		if(g == null) return this;
		int id = g.actions?.length ?? 0;

		GameActionChange change = GameActionChange.score(
			GameActionChangeScore(
				t1: team == 1 ? 1 : 0,
				t2: team == 2 ? 1 : 0
			)
		);
		final goalAction = GameAction.goal(id: id, change: change);
		final updatedGame = g.copyWith(actions: [...?g.actions, goalAction]);
		final newGames = [...games];
		newGames[meta.gameIndex] = updatedGame;

		return copyWith(games: newGames);
	}

	Matchday goalRemoveLast({required int team}) {
		Game? g = currentGame;
		if(g == null) return this;
		if(g.actions == null || g.actions!.isEmpty) return this;

		// Find last index of a goal for the team
		final lastGoalIndex = g.actions!.lastIndexWhere((a) =>
			a.mapOrNull(
				goal: (g) {
					final scoreChange = g.change.mapOrNull(score: (s) => s.score);
					if(scoreChange == null) return false;
					if(team == 1) return scoreChange.t1 > 0;
					if(team == 2) return scoreChange.t2 > 0;
					return false;
				}
			) ?? false
		);

		if(lastGoalIndex == -1) return this;

		final newActions = List<GameAction>.from(g.actions!);
		newActions.removeAt(lastGoalIndex);

		final updatedGame = g.copyWith(actions: newActions);
		final newGames = [...games];
		newGames[meta.gameIndex] = updatedGame;

		return copyWith(games: newGames);
	}

	// Time can be positive or negative
	Matchday timeChange(int change) {
		if(change + meta.currentTime < 0) change = -meta.currentTime;
		return copyWith(meta: meta.copyWith(currentTime: meta.currentTime + change));
	}

	// Time can be positive or negative
	Matchday timeReset() {
		if(currentGamePart == null) return this;
		int? defTime = currentGamePart!.whenOrNull(timed: (_, len, _, _, _) => len);
		if(defTime == null) return this;
		return copyWith(meta: meta.copyWith(currentTime: defTime));
	}

	Matchday togglePause() {
		if(meta.paused && meta.currentTime == 0) return this;
		return copyWith(meta: meta.copyWith(paused: meta.paused ? false: true));
	}

	// Returns a Map with Team and an associated integer to it.
	// This allows e.g. for 2 teams who are equally ranked
	Map<Team, int> getRanking() {
		final stats = [for (final t in teams) getTeamPoints(t)];

		stats.sort((a, b) {
			int c;
			if((c = b.points.compareTo(a.points)) != 0) return c;
			if((c = b.goalDiff.compareTo(a.goalDiff)) != 0) return c;
			return b.goals.compareTo(a.goals);
		});

		final Map<Team, int> out = {};
		int currentRank = 1;

		for (int i=0; i < stats.length; i++) {
			if( i > 0 &&
			    (stats[i].points != stats[i-1].points ||
				 stats[i].goalDiff != stats[i-1].goalDiff ||
				 stats[i].goals != stats[i-1].goals))
				currentRank = i + 1;
			out[stats[i].team] = currentRank;
		}

		return out;

		return Map.fromIterable(teams,
			key: (team) => team,
			value: (team) => getTeamPoints(team),
		);
	}

	int getTeamPoints(Team t) {
		int points = 0;
		for(int i=0; i < meta.gameIndex; i++) {
			Game g = games[i];
			int? gameTeamIndex;
			if(g.team1.map(byName: (t1) => t.name == t1.name, byQuery: (t1) => t.name == t1.query.resolveTeam(this)?.name))
				gameTeamIndex = 1;
			if(g.team2.map(byName: (t2) => t.name == t2.name, byQuery: (t2) => t.name == t2.query.resolveTeam(this)?.name))
				gameTeamIndex = 2;
			if(gameTeamIndex == null) continue;

			int pointsDiff = g.goalsTeam(gameTeamIndex) - g.goalsTeam(gameTeamIndex == 1 ? 2 : 1);
			if(pointsDiff > 0) points += 3;
			else if (pointsDiff == 0) points++;
		}
		points *= 10;
		return points;
	}
}

@freezed
class Meta with _$Meta {
	const factory Meta({
		@JsonKey(name: 'game_i') @Default(0) int gameIndex,
		@JsonKey(name: 'cur_gamepart') @Default(0) int currentGamepart,
		// This is for an EXTRA invert, not the normal side switching.
		// The normal side switching is done through formats!
		// This is still needed, because maybe the teams are standing the other way around at the beginning
		@JsonKey(name: 'sides_inverted') @Default(false) bool sidesInverted,
		@Default(true) bool paused,
		@JsonKey(name: 'cur_time') @Default(0) int currentTime,
		required List<Format> formats,
	}) = _Meta;

	factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);
}

@freezed
class Game with _$Game {
	const Game._(); // This is needed to allow methods/getters

	const factory Game({
		String? name,
		@JsonKey(name: '1') required GameTeamSlot team1,
		@JsonKey(name: '2') required GameTeamSlot team2,
		List<String>? groups,
		required GameFormat format,
		@Default(false) bool decider,
		List<GameAction>? actions,
	}) = _Game;

	int goalsTeam(int team) {
		if(actions == null || actions!.isEmpty) return 0;

		return actions!.whereType<_GameActionGoal>().fold(0, (sum, action) {
			final score = action.change.map(score: (s) => s.score);
			if(team == 1) return sum + score.t1;
			if(team == 2) return sum + score.t2;
			return sum;
		});
	}

	factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
}

@Freezed(unionKey: "type")
class GameAction with _$GameAction {
	const factory GameAction.goal({
		required int id,
		@JsonKey(name: "time_game") int? timeGame,
		@JsonKey(name: "timespan_game") int? timespanGame,
		@JsonKey(name: "time_unix") int? timeUnix,
		@JsonKey(name: "timespan_unix") int? timespanUnix,
		List<GameActionPlayerInvolved>? players_involved,
		required GameActionChange change,
		@JsonKey(name: "triggers_action") int? triggersAction,
		String? description,
		@Default(true) bool done,
	}) = _GameActionGoal;

	const factory GameAction.foul({
		required int id,
		@JsonKey(name: "time_game") int? timeGame,
		@JsonKey(name: "timespan_game") int? timespanGame,
		@JsonKey(name: "time_unix") int? timeUnix,
		@JsonKey(name: "timespan_unix") int? timespanUnix,
		List<GameActionPlayerInvolved>? players_involved,
		@JsonKey(name: "triggers_action") int? triggersAction,
		String? description,
		@Default(true) bool done,
	}) = _GameActionFoul;

	const factory GameAction.penalty({
		required int id,
		@JsonKey(name: "time_game") int? timeGame,
		@JsonKey(name: "timespan_game") int? timespanGame,
		@JsonKey(name: "time_unix") int? timeUnix,
		@JsonKey(name: "timespan_unix") int? timespanUnix,
		List<GameActionPlayerInvolved>? players_involved,
		String? description,
		@Default(true) bool done,
	}) = _GameActionPenalty;

	const factory GameAction.outball({
		required int id,
		@JsonKey(name: "time_game") int? timeGame,
		@JsonKey(name: "timespan_game") int? timespanGame,
		@JsonKey(name: "time_unix") int? timeUnix,
		@JsonKey(name: "timespan_unix") int? timespanUnix,
		List<GameActionPlayerInvolved>? players_involved,
		required int team, // either 1 or 2 for the equivalent team
		String? description,
		@Default(true) bool done,
	}) = _GameActionOutball;

	factory GameAction.fromJson(Map<String, dynamic> json) => _$GameActionFromJson(json);
}

@freezed
class GameActionPlayerInvolved with _$GameActionPlayerInvolved {
	const factory GameActionPlayerInvolved(String name, String role) = _GameActionPlayerInvolved;

	factory GameActionPlayerInvolved.fromJson(Map<String, dynamic> json) => _$GameActionPlayerInvolvedFromJson(json);
}

@Freezed(unionKey: "type")
class GameActionChange with _$GameActionChange {
	const factory GameActionChange.score(GameActionChangeScore score) = _GameActionChange;

	factory GameActionChange.fromJson(Map<String, dynamic> json) => _$GameActionChangeFromJson(json);
}

@freezed
class GameActionChangeScore with _$GameActionChangeScore {
	const factory GameActionChangeScore({
		@JsonKey(name: '1') @Default(0) int t1,
		@JsonKey(name: '2') @Default(0) int t2,
	}) = _GameActionChangeScore;

	factory GameActionChangeScore.fromJson(Map<String, dynamic> json) => _$GameActionChangeScoreFromJson(json);
}

@freezed
class GameFormat with _$GameFormat {
	const factory GameFormat({ required String name, @Default(false) bool decider }) = _GameFormat;

	factory GameFormat.fromJson(Map<String, dynamic> json) => _$GameFormatFromJson(json);
}

@Freezed(unionKey: "type")
class GameTeamSlot with _$GameTeamSlot {
	const factory GameTeamSlot.byName({ required String name, MissingInfo? missing }) = _GameTeamSlotByName;
	const factory GameTeamSlot.byQuery({ required GameQuery query, MissingInfo? missing }) = _GameTeamSlotByQuery;

	factory GameTeamSlot.fromJson(Map<String, dynamic> json) => _$GameTeamSlotFromJson(json);
}

@Freezed(unionKey: "type")
class GameQuery with _$GameQuery {
	const factory GameQuery.groupPlace(String group, int place) = _GameQueryByGroupPlace;
	const factory GameQuery.gameWinner(int gameIndex) = _GameQueryByGameWinner;
	const factory GameQuery.gameLoser(int gameIndex) = _GameQueryByGameLoser;

	// TODO Validate functions
	Team? resolveTeam(Matchday m) {
		return map(
			groupPlace: (e) => _resolveTeamGroupPlace(e, m),
			gameWinner: (e) => _resolveTeamGameWinner(e, m),
			gameLoser: (e) => _resolveTeamGameLoser(e, m),
		);
	}

	Team? _resolveTeamGroupPlace(_GameQueryByGroupPlace gq, Matchday m) {
		Group? g = m.groups.firstWhereIndexedOrNull((_, group) => gq.group == group.name);
		if(g == null) return null;

		return null;
	}

	Team? _resolveTeamGameWinner(_GameQueryByGameWinner gq, Matchday m) {
		return null;
	}

	Team? _resolveTeamGameLoser(_GameQueryByGameLoser gq, Matchday m) {
		return null;
	}


	factory GameQuery.fromJson(Map<String, dynamic> json) => _$GameQueryFromJson(json);
}
@freezed
class MissingInfo with _$MissingInfo {
	const factory MissingInfo(String reason) = _MissingInfo;

	factory MissingInfo.fromJson(Map<String, dynamic> json) => _$MissingInfoFromJson(json);
}
@freezed
class Player with _$Player {
	const factory Player(String name, String role) = _Player;

	factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}
@freezed
class Team with _$Team {
	const factory Team(
		String name,
		@JsonKey(name: 'logo_uri') String logoUri,
		String color,
		List<Player> players
	) = _Team;

	factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
}
@freezed
class Group with _$Group {
	const factory Group(String name, List<String> members) = _Group;

	factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}

@freezed
class Format with _$Format {
	const factory Format(String name, List<GamePart> gameparts) = _Format;

	factory Format.fromJson(Map<String, dynamic> json) => _$FormatFromJson(json);
}

@Freezed(unionKey: 'type')
class GamePart with _$GamePart {
	const factory GamePart.timed({
		required String name,
		required int length,
		@Default(false) bool repeat,
		@Default(false) bool decider,
		@JsonKey(name: 'sides_inverted') @Default(false) bool sidesInverted,
	}) = _GamePartTimed;

	const factory GamePart.format({
		required String format, // nested reference to another format
		@Default(false) bool repeat,
		@Default(false) bool decider,
		@JsonKey(name: 'sides_inverted') @Default(false) bool sidesInverted,
	}) = _GamePartFormat;

	const factory GamePart.penalty({
		required String name,
		required Penalty penalty,
		@Default(false) bool repeat,
		@Default(false) bool decider,
		@JsonKey(name: 'sides_inverted') @Default(false) bool sidesInverted,
	}) = _GamePartPenalty;

	factory GamePart.fromJson(Map<String, dynamic> json) => _$GamePartFromJson(json);
}
@freezed
class Penalty with _$Penalty {
	const factory Penalty(Shooting shooting) = _Penalty;

	factory Penalty.fromJson(Map<String, dynamic> json) => _$PenaltyFromJson(json);
}
@freezed
class Shooting with _$Shooting {
	const factory Shooting(int team, int player) = _Shooting;

	factory Shooting.fromJson(Map<String, dynamic> json) => _$ShootingFromJson(json);
}

