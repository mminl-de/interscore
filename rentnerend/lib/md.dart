// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:flutter_rentnerend/lib.dart';

part 'md.freezed.dart';
part 'md.g.dart';

@freezed
class Matchday with _$Matchday {
	const Matchday._(); // This is needed to allow methods/getters

	@JsonSerializable(includeIfNull: false)
	const factory Matchday(
		Meta meta,
		List<Team> teams,
		List<Group> groups,
		List<Game> games,
	) = _Matchday;

	factory Matchday.fromJson(Map<String, dynamic> json) => _$MatchdayFromJson(json);

	Game get currentGame {
		final i = meta.gameIndex;
		return games[i];
	}

	Format? get currentFormat {
		Format? f = formatFromName(currentGame.format.name);
		if(f == null) return null;
		return f.copyWith(gameparts: f.gameparts.where((gp) => (!gp.decider || currentGame.format.decider)).toList());
	}

	Format? get currentFormatUnwrapped {
		Format? f = currentFormat;
		if(f == null) return null;
		return formatUnwrap(f);
	}

	Gamepart? get currentGamepart {
		return gamepartFromIndex(meta.currentGamepart);
	}

	Matchday setGameIndex(int index, {bool applySideEffects = true}) {
		if (index < 0 || index >= games.length) return this;
		debugPrint("Setting Gameindex: ${meta.gameIndex} -> ${index}");
		// Now we resolve the GameTeamSlot.byQueryResolved -> GameTeamSlot.byQuery
		// from the last game, because they arent resolved anymore
		List<Game> new_games = List.from(games);
		for(int i = meta.gameIndex; i > index; i--) {
			debugPrint("unresolve game ${i}");
			new_games[i] = games[i].copyWith(
				team1: games[i].team1.map(byName: (x) => x, byQuery: (x) => x, byQueryResolved: (x) => x.q),
				team2: games[i].team2.map(byName: (x) => x, byQuery: (x) => x, byQueryResolved: (x) => x.q),
			);
		}
		// Now we resolve the GameTeamSlot.byQuery -> GameTeamSlot.byQueryResolved
		// because all games already played and the one we are playing now have to be resolved
		for(int i = meta.gameIndex+1; i <= index; i++) {
			debugPrint("resolve game ${i}");
			GameTeamSlot? t1 = games[i].team1.resolveQuery(this);
			GameTeamSlot? t2 = games[i].team2.resolveQuery(this);
			if (t1 == null || t2 == null) return this;
			new_games[i] = games[i].copyWith(
				team1: t1,
				team2: t2,
			);
		}
		Matchday md = copyWith(games: new_games, meta: meta.copyWith(gameIndex: index));
		if(applySideEffects && md.meta.paused && md.meta.currentTime == 0)
			md = md.setCurrentGamepart(0);
		return md;
	}

	Matchday setSidesInverted(bool inverted) {
		return copyWith(meta: meta.copyWith(sidesInverted: inverted));
	}

	Matchday addGameAction(GameAction ga) {
		final newGames = games;
		newGames[meta.gameIndex] = currentGame.copyWith(actions: [...? currentGame.actions, ga]);
		return copyWith(games: newGames);
	}

	Matchday goalAdd(int team) {
		Game g = currentGame;
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

		// TODO test this, looks very suspicious
		return copyWith(games: newGames);
	}

	Matchday goalRemoveLast(int team) {
		Game g = currentGame;
		if (g.actions == null || g.actions!.isEmpty) return this;

		// Find last index of a goal for the team
		final lastGoalIndex = g.actions!.lastIndexWhere((a) =>
			a.mapOrNull(
				goal: (g) {
					final scoreChange = g.change.mapOrNull(score: (s) => s.score);
					if (scoreChange == null) return false;
					if (team == 1) return scoreChange.t1 > 0;
					if (team == 2) return scoreChange.t2 > 0;
					return false;
				}
			) ?? false
		);

		if (lastGoalIndex == -1) return this;

		final newActions = List<GameAction>.from(g.actions!);
		newActions.removeAt(lastGoalIndex);

		final updatedGame = g.copyWith(actions: newActions);
		final newGames = [...games];
		newGames[meta.gameIndex] = updatedGame;

		return copyWith(games: newGames);
	}

	// Time can be positive or negative
	Matchday timeChange(int change) {
		if (change + meta.currentTime < 0) change = -meta.currentTime;
		return copyWith(meta: meta.copyWith(currentTime: meta.currentTime + change));
	}

	// Time can be positive or negative
	Matchday timeReset() {
		if (currentGamepart == null) return this;
		int? defTime = currentGamepart!.whenOrNull(timed: (_, len, _, _, _) => len);
		if (defTime == null) return this;
		return copyWith(meta: meta.copyWith(currentTime: defTime));
	}

	Matchday setPause(bool pause) {
		if (meta.paused && meta.currentTime == 0) return this;
		return copyWith(meta: meta.copyWith(paused: pause));
	}

	Matchday setCurrentGamepart(int index, {bool applySideEffect = true}) {
		Gamepart? gp = gamepartFromIndex(index);
		if(gp == null) return this;
		Matchday md = this;
		if(applySideEffect) {
			md = gp.maybeWhen(
				timed: (_, len, _, _, _) {
					if(meta.paused)
						return copyWith(meta: meta.copyWith(currentTime: len));
					else return this;
				},
				orElse: () => this
			);
		}
		return md.copyWith(meta: md.meta.copyWith(currentGamepart: index));
	}

	// Returns a Map with Team and an associated integer to it.
	// This allows e.g. for 2 teams who are equally ranked
	Map<String, int>? rankingFromGroup(String groupName) {
		final Group? group = groupFromName(groupName);
		if (group == null) return null; // TODO This should probably crash the program

		final List<String> stats = [for (final t in group.members) t];

		stats.sort((a, b) {
			int c;
			if ((c = teamPoints(b, groupName) - teamPoints(a, groupName)) != 0) return c;
			if ((c = teamGoalDiff(b, groupName) - teamGoalDiff(a, groupName)) != 0) return c;
			return teamGoalsPlus(b, groupName) - teamGoalsPlus(a, groupName);
		});

		final Map<String, int> out = {};
		int currentRank = 1;

		for (int i=0; i < stats.length; i++) {
			if ( i > 0 &&
			    (teamPoints(stats[i], groupName) != teamPoints(stats[i-1], groupName) ||
				 teamGoalDiff(stats[i], groupName) != teamGoalDiff(stats[i-1], groupName) ||
				 teamGoalsPlus(stats[i], groupName) != teamGoalsPlus(stats[i-1], groupName)))
				currentRank = i + 1;
			out[stats[i]] = currentRank;
		}

		return out;
	}

	// Gives back Map of all games the team played and an
	Map<Game, int> teamGamesPlayed(String t, String group) {
		if (groupFromName(group) == null); // TODO crash the program?

		Map<Game, int> gamesPlayed = Map<Game, int>();
		for(int i=0; i < meta.gameIndex; i++) {
			Game game = games[i];
			if (game.groups?.firstWhereOrNull((groupName) => group == groupName) == null) continue;
			int? gameTeamIndex;
			if (game.team1.map(
			    byName: (t1) => t == t1.name,
				byQueryResolved: (t1) => t == t1.name,
				byQuery: (t1) => false,
			))
				gameTeamIndex = 1;
			else if (game.team2.map(
				byName: (t2) => t == t2.name,
				byQueryResolved: (t2) => t == t2.name,
				byQuery: (t2) => false)
			)
				gameTeamIndex = 2;
			else continue;

			gamesPlayed[game] = gameTeamIndex;
		}
		return gamesPlayed;
	}

	Map<Game, int> teamGamesWon(String t, String g) {
		Map<Game, int> played = teamGamesPlayed(t, g);
		played.removeWhere((g, gameTeamIndex) {
			return g.teamGoals(gameTeamIndex) - g.teamGoals(gameTeamIndex == 1 ? 2 : 1) <= 0;
		});
		return played;
	}

	Map<Game, int> teamGamesLost(String t, String g) {
		Map<Game, int> played = teamGamesPlayed(t, g);
		played.removeWhere((g, gameTeamIndex) {
			return g.teamGoals(gameTeamIndex) - g.teamGoals(gameTeamIndex == 1 ? 2 : 1) > 0;
		});
		return played;
	}

	Map<Game, int> teamGamesTied(String t, String g) {
		Map<Game, int> played = teamGamesPlayed(t, g);
		played.removeWhere((g, gameTeamIndex) {
			return g.teamGoals(gameTeamIndex) - g.teamGoals(gameTeamIndex == 1 ? 2 : 1) != 0;
		});
		return played;
	}

	int teamPoints(String t, String g) {
		return teamGamesWon(t, g).length * 3 + teamGamesTied(t, g).length;
	}

	int teamGoalDiff(String t, String g) {
		return teamGoalsPlus(t, g) - teamGoalsMinus(t, g);
	}

	int teamGoalsPlus(String t, String g) {
		int goals = 0;
		teamGamesPlayed(t, g).forEach((g, gameTeamIndex) {
			goals += g.teamGoals(gameTeamIndex);
		});
		return goals;
	}

	int teamGoalsMinus(String t, String g) {
		int goals = 0;
		teamGamesPlayed(t, g).forEach((g, gameTeamIndex) {
			goals += g.teamGoals(gameTeamIndex == 1 ? 2 : 1);
		});
		return goals;
	}

	Team? teamFromName(String name) {
		return this.teams.firstWhere((team) => name == team.name);
	}

	Group? groupFromName(String name) {
		return this.groups.firstWhere((group) => name == group.name);
	}

	Format? formatFromName(String name) {
		return this.meta.formats.firstWhere((format) => name == format.name);
	}

	Format? formatUnwrap(Format f) {
		return f.copyWith(gameparts: f.gameparts.expand((gp) => gp.maybeWhen(
			format: (name, _, _, _) => formatUnwrap(formatFromName(name)!)!.gameparts,
			orElse: () => [ gp ]
		)).toList());
	}

	Gamepart? gamepartFromIndex(int index) {
		final Format? f = currentFormatUnwrapped;
		if (f == null) return null;
		if (index < 0) return null;
		if (index >= f.gameparts.length) return null;
		return f.gameparts[index];
	}
}

@freezed
class Meta with _$Meta {
	@JsonSerializable(includeIfNull: false)
	const factory Meta({
		@JsonKey(name: 'game_i', toJson: intOrNullNot0) @Default(0) int gameIndex,
		@JsonKey(name: 'cur_gamepart', toJson: intOrNullNot0) @Default(0) int currentGamepart,
		// This is for an EXTRA invert, not the normal side switching.
		// The normal side switching is done through formats!
		// This is still needed, because maybe the teams are standing the other way around at the beginning
		@JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue) @Default(false) bool sidesInverted,
		@JsonKey(toJson: boolOrNullFalse) @Default(true) bool paused,
		@JsonKey(name: 'cur_time', toJson: intOrNullNot0) @Default(0) int currentTime,
		@JsonKey(name: 'allow_remote_game_creation', toJson: boolOrNullTrue) @Default(false) bool allowRemoteGameCreation,
		@Default(false) bool widgetScoreboard,
		@Default(false) bool widgetGameplan,
		@Default(false) bool widgetLiveplan,
		@Default(false) bool widgetGamestart,
		@Default(false) bool widgetAd,
		@Default(false) bool streamStarted,
		@Default(false) bool replayStarted,
		required List<Format> formats,
	}) = _Meta;

	factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);
}

@freezed
class Game with _$Game {
	const Game._(); // This is needed to allow methods/getters

	@JsonSerializable(includeIfNull: false)
	const factory Game({
		required String name,
		@JsonKey(name: '1') required GameTeamSlot team1,
		@JsonKey(name: '2') required GameTeamSlot team2,
		List<String>? groups,
		required GameFormat format,
		@JsonKey(toJson: boolOrNullTrue) @Default(false) bool decider,
		@Default(true) bool protected,
		List<GameAction>? actions,
	}) = _Game;

	int teamGoals(int team) {
		if (actions == null || actions!.isEmpty) return 0;

		return actions!.whereType<_GameActionGoal>().fold(0, (sum, action) {
			final score = action.change.map(score: (s) => s.score);
			if (team == 1) return sum + score.t1;
			if (team == 2) return sum + score.t2;
			return sum;
		});
	}

	// returns 1/2 if they are the winner and 0 in case of draw
	int get winner {
		final goalDiff = teamGoals(2) - teamGoals(1);
		if (goalDiff < 0) return 1;
		if (goalDiff > 0) return 2;
		return goalDiff;
	}

	// returns 1/2 if they are the loser and 0 in case of draw
	int get loser {
		final goalDiff = teamGoals(2) - teamGoals(1);
		if (goalDiff < 0) return 2;
		if (goalDiff > 0) return 1;
		return goalDiff;
	}

	factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
}

@Freezed(unionKey: "type")
class GameAction with _$GameAction {
	@JsonSerializable(includeIfNull: false)
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
		@JsonKey(toJson: boolOrNullFalse) @Default(true) bool done,
	}) = _GameActionGoal;

	@JsonSerializable(includeIfNull: false)
	const factory GameAction.foul({
		required int id,
		@JsonKey(name: "time_game") int? timeGame,
		@JsonKey(name: "timespan_game") int? timespanGame,
		@JsonKey(name: "time_unix") int? timeUnix,
		@JsonKey(name: "timespan_unix") int? timespanUnix,
		List<GameActionPlayerInvolved>? players_involved,
		@JsonKey(name: "triggers_action") int? triggersAction,
		String? description,
		@JsonKey(toJson: boolOrNullFalse) @Default(true) bool done,
	}) = _GameActionFoul;

	@JsonSerializable(includeIfNull: false)
	const factory GameAction.penalty({
		required int id,
		@JsonKey(name: "time_game") int? timeGame,
		@JsonKey(name: "timespan_game") int? timespanGame,
		@JsonKey(name: "time_unix") int? timeUnix,
		@JsonKey(name: "timespan_unix") int? timespanUnix,
		List<GameActionPlayerInvolved>? players_involved,
		String? description,
		@JsonKey(toJson: boolOrNullFalse) @Default(true) bool done,
	}) = _GameActionPenalty;

	@JsonSerializable(includeIfNull: false)
	const factory GameAction.outball({
		required int id,
		@JsonKey(name: "time_game") int? timeGame,
		@JsonKey(name: "timespan_game") int? timespanGame,
		@JsonKey(name: "time_unix") int? timeUnix,
		@JsonKey(name: "timespan_unix") int? timespanUnix,
		List<GameActionPlayerInvolved>? players_involved,
		required int team, // either 1 or 2 for the equivalent team
		String? description,
		@JsonKey(toJson: boolOrNullFalse) @Default(true) bool done,
	}) = _GameActionOutball;

	factory GameAction.fromJson(Map<String, dynamic> json) => _$GameActionFromJson(json);
}

@freezed
class GameActionPlayerInvolved with _$GameActionPlayerInvolved {
	@JsonSerializable(includeIfNull: false)
	const factory GameActionPlayerInvolved(String name, String role) = _GameActionPlayerInvolved;

	factory GameActionPlayerInvolved.fromJson(Map<String, dynamic> json) => _$GameActionPlayerInvolvedFromJson(json);
}

@Freezed(unionKey: "type")
class GameActionChange with _$GameActionChange {
	@JsonSerializable(includeIfNull: false)
	const factory GameActionChange.score(GameActionChangeScore score) = _GameActionChange;

	factory GameActionChange.fromJson(Map<String, dynamic> json) => _$GameActionChangeFromJson(json);
}

@freezed
class GameActionChangeScore with _$GameActionChangeScore {
	@JsonSerializable(includeIfNull: false)
	const factory GameActionChangeScore({
		@JsonKey(name: '1', toJson: intOrNullNot0) @Default(0) int t1,
		@JsonKey(name: '2', toJson: intOrNullNot0) @Default(0) int t2,
	}) = _GameActionChangeScore;

	factory GameActionChangeScore.fromJson(Map<String, dynamic> json) => _$GameActionChangeScoreFromJson(json);
}

@freezed
class GameFormat with _$GameFormat {
	@JsonSerializable(includeIfNull: false)
	const factory GameFormat({
		required String name,
		@JsonKey(toJson: boolOrNullTrue) @Default(false) bool decider
	}) = _GameFormat;

	factory GameFormat.fromJson(Map<String, dynamic> json) => _$GameFormatFromJson(json);
}

@Freezed(unionKey: "type")
class GameTeamSlot with _$GameTeamSlot {
	@JsonSerializable(includeIfNull: false)
	const factory GameTeamSlot.byName({ required String name, MissingInfo? missing }) = _GameTeamSlotByName;
	@JsonSerializable(includeIfNull: false)
	const factory GameTeamSlot.byQuery({ required GameQuery query, MissingInfo? missing }) = _GameTeamSlotByQuery;
	@JsonSerializable(includeIfNull: false)
	const factory GameTeamSlot.byQueryResolved({required String name, required _GameTeamSlotByQuery q}) = _GameTeamSlotByQueryResolved;

	factory GameTeamSlot.fromJson(Map<String, dynamic> json) => _$GameTeamSlotFromJson(json);
}

extension GameTeamSlotEx on GameTeamSlot {
	@JsonSerializable(includeIfNull: false)
	GameTeamSlot? resolveQuery(Matchday m) {
		return map(
			byName: (_) => this,
			byQueryResolved: (_) => this,
			byQuery: (gts) {
				final String? name = GameQuery.resolveTeam(gts.query, m)?[0];
				if (name == null) return null;
				return GameTeamSlot.byQueryResolved(name: name, q: gts);
			}
		);
	}
}

@Freezed(unionKey: "type")
class GameQuery with _$GameQuery {
	@JsonSerializable(includeIfNull: false)
	const factory GameQuery.groupPlace(String group, int place) = _GameQueryByGroupPlace;
	@JsonSerializable(includeIfNull: false)
	const factory GameQuery.gameWinner(int gameIndex) = _GameQueryByGameWinner;
	@JsonSerializable(includeIfNull: false)
	const factory GameQuery.gameLoser(int gameIndex) = _GameQueryByGameLoser;

	// TODO Validate functions
	static List<String>? resolveTeam(GameQuery gq, Matchday m) {
		List<String>? ret = gq.map(
			groupPlace: (e) => _resolveTeamGroupPlace(e, m),
			gameWinner: (e) {
				final winner = _resolveTeamGameWinner(e, m);
				if (winner == null) return null;
				return [winner];
			},
			gameLoser: (e) {
				final loser = _resolveTeamGameLoser(e, m);
				if (loser == null) return null;
				return [loser];

			}
		);
		debugPrint("resolved: ${gq.runtimeType} to -> ${ret}");
		return ret;
	}

	static List<String>? _resolveTeamGroupPlace(_GameQueryByGroupPlace gq, Matchday m) {
		Group? g = m.groups.firstWhereIndexedOrNull((_, group) => gq.group == group.name);
		if (g == null) return null;

		Map<String, int>? groupRankingMap = m.rankingFromGroup(gq.group);
		if (groupRankingMap == null) return null;
		groupRankingMap.forEach((t, i) => debugPrint("[${t}, ${i}],"));
		groupRankingMap.removeWhere((key, _) => !g.members.contains(key));

		List<MapEntry<String, int>> groupRanking = groupRankingMap.entries.toList()..sort((a, b) => a.value - b.value);

		debugPrint("Group Ranking 1: ${groupRanking}");
		debugPrint("gq.place: ${gq.place}");
		debugPrint("Group Ranking[gq.place]: ${groupRanking[gq.place]}");
		if (gq.place >= groupRanking.length) return null;

		List<String> ret = groupRanking
			.where((e) => e.value == groupRanking[gq.place].value)
			.map((e) => e.key)
			.toList();
		debugPrint("Group Ranking 2: ${ret.map((t) => t).toList()}");
		if (ret.length == 0) return null;
		debugPrint("Group Ranking 3: ${ret.map((t) => t).toList()}");
		return ret.map((t) => t).toList();
	}

	static String? _resolveTeamGameWinner(_GameQueryByGameWinner gq, Matchday m) {
		if (gq.gameIndex >= m.meta.gameIndex || gq.gameIndex < 0) return null;
		final Game g = m.games[gq.gameIndex];
		final int winner = g.winner;
		final GameTeamSlot winnerTeamSlot = winner == 1 ? g.team1 : g.team2;
		return winnerTeamSlot.mapOrNull(byName: (gts) => gts.name, byQueryResolved: (gts) => gts.name);
	}

	static String? _resolveTeamGameLoser(_GameQueryByGameLoser gq, Matchday m) {
		if (gq.gameIndex >= m.meta.gameIndex || gq.gameIndex < 0) return null;
		final Game g = m.games[gq.gameIndex];
		final int loser = g.loser;
		final GameTeamSlot loserTeamSlot = loser == 1 ? g.team1 : g.team2;
		return loserTeamSlot.mapOrNull(byName: (gts) => gts.name, byQueryResolved: (gts) => gts.name);
	}

	factory GameQuery.fromJson(Map<String, dynamic> json) => _$GameQueryFromJson(json);
}
@freezed
class MissingInfo with _$MissingInfo {
	@JsonSerializable(includeIfNull: false)
	const factory MissingInfo(String reason) = _MissingInfo;

	factory MissingInfo.fromJson(Map<String, dynamic> json) => _$MissingInfoFromJson(json);
}
@freezed
class Player with _$Player {
	@JsonSerializable(includeIfNull: false)
	const factory Player(String name, String role) = _Player;

	factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}
@freezed
class Team with _$Team {
	@JsonSerializable(includeIfNull: false)
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
	@JsonSerializable(includeIfNull: false)
	const factory Group(String name, List<String> members) = _Group;

	factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}

@freezed
class Format with _$Format {
	@JsonSerializable(includeIfNull: false)
	const factory Format(String name, List<Gamepart> gameparts) = _Format;

	factory Format.fromJson(Map<String, dynamic> json) => _$FormatFromJson(json);
}

@Freezed(unionKey: 'type')
class Gamepart with _$Gamepart {
	@JsonSerializable(includeIfNull: false)
	const factory Gamepart.timed({
		required String name,
		required int length,
		@JsonKey(toJson: boolOrNullTrue) @Default(false) bool repeat,
		@JsonKey(toJson: boolOrNullTrue) @Default(false) bool decider,
		@JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue) @Default(false) bool sidesInverted,
	}) = _GamepartTimed;

	@JsonSerializable(includeIfNull: false)
	const factory Gamepart.format({
		required String format, // nested reference to another format
		@JsonKey(toJson: boolOrNullTrue) @Default(false) bool repeat,
		@JsonKey(toJson: boolOrNullTrue) @Default(false) bool decider,
		@JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue) @Default(false) bool sidesInverted,
	}) = _GamepartFormat;

	@JsonSerializable(includeIfNull: false)
	const factory Gamepart.penalty({
		required String name,
		required Penalty penalty,
		@JsonKey(toJson: boolOrNullTrue) @Default(false) bool repeat,
		@JsonKey(toJson: boolOrNullTrue) @Default(false) bool decider,
		@JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue) @Default(false) bool sidesInverted,
	}) = _GamepartPenalty;

	factory Gamepart.fromJson(Map<String, dynamic> json) => _$GamepartFromJson(json);
}
@freezed
class Penalty with _$Penalty {
	@JsonSerializable(includeIfNull: false)
	const factory Penalty(Shooting shooting) = _Penalty;

	factory Penalty.fromJson(Map<String, dynamic> json) => _$PenaltyFromJson(json);
}
@freezed
class Shooting with _$Shooting {
	@JsonSerializable(includeIfNull: false)
	const factory Shooting(int team, int player) = _Shooting;

	factory Shooting.fromJson(Map<String, dynamic> json) => _$ShootingFromJson(json);
}

