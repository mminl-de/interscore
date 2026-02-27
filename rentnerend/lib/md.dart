// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'lib.dart';
import 'MessageType.dart';

part 'md.freezed.dart';
part 'md.g.dart';

@freezed
class Matchday with _$Matchday {
	const Matchday._(); // This is needed to allow methods/getters

	@JsonSerializable(includeIfNull: false)
	const factory Matchday(
		Meta meta,
		List<Format> formats,
		List<Team> teams,
		List<Group> groups,
		List<Game> games,
	) = _Matchday;

	factory Matchday.fromJson(Map<String, dynamic> json) => _$MatchdayFromJson(json);

	int currentTime() {
		if(meta.time.paused) return meta.time.remaining;
		else {
			final unixTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
			final t = meta.time.remaining - (unixTime + meta.time.delay - meta.time.lastUnpaused);
			return t >= 0 ? t : 0;
		}
	}

	Game? get currentGame {
		if(meta.game.ended) return null;
		final i = meta.game.index;
		return games[i];
	}

	Format? get currentFormat {
		final g = currentGame;
		if(g == null) return null;
		final Format? f = formatFromName(g.format.name);
		if(f == null) return null;
		return f.copyWith(gameparts: f.gameparts.where((gp) => (!gp.decider || g.format.decider)).toList());
	}

	Format? get currentFormatUnwrapped {
		final Format? f = currentFormat;
		if(f == null) return null;
		return formatUnwrap(f);
	}

	Gamepart? get currentGamepart {
		return gamepartFromIndex(meta.game.gamepart);
	}

	Matchday setGameIndex(final int index, {final bool applySideEffects = true, final void Function(MessageType, {Matchday? md})? send = null}) {
		Matchday md;
		if (index < 0) return this;
		if (index >= games.length) {
			md = copyWith(meta: meta.copyWith(game: meta.game.copyWith(ended: true)));
			send?.call(MessageType.DATA_META_GAME, md: md);
			return md;
		}
		else if (meta.game.ended)
			md = copyWith(meta: meta.copyWith(game: meta.game.copyWith(ended: false)));

		debugPrint("Setting Gameindex: ${meta.game.index} -> ${index}");
		// Now we resolve the GameTeamSlot.byQueryResolved -> GameTeamSlot.byQuery
		// from the last game, because they arent resolved anymore
		List<Game> new_games = List.from(games);
		for(int i = meta.game.index; i > index; i--) {
			debugPrint("unresolve game ${i}");
			new_games[i] = games[i].copyWith(
				team1: games[i].team1.map(byName: (x) => x, byQuery: (x) => x, byQueryResolved: (x) => x.q),
				team2: games[i].team2.map(byName: (x) => x, byQuery: (x) => x, byQueryResolved: (x) => x.q),
			);
		}
		// Now we resolve the GameTeamSlot.byQuery -> GameTeamSlot.byQueryResolved
		// because all games already played and the one we are playing now have to be resolved
		for(int i = meta.game.index+1; i <= index; i++) {
			debugPrint("resolve game ${i}");
			GameTeamSlot? t1 = games[i].team1.resolveQuery(this);
			GameTeamSlot? t2 = games[i].team2.resolveQuery(this);
			if (t1 == null || t2 == null) return this;
			new_games[i] = games[i].copyWith(
				team1: t1,
				team2: t2,
			);
		}
		md = copyWith(games: new_games, meta: meta.copyWith(game: meta.game.copyWith(index: index)));
		if(applySideEffects && md.meta.time.paused && md.currentTime() == 0)
			md = md.setCurrentGamepart(0, send: send);

		send?.call(MessageType.DATA_META_GAME, md: md);

		return md;
	}

	Matchday setSidesInverted(final bool inverted, {final void Function(MessageType, {Matchday? md})? send = null}) {
		Matchday md = copyWith(meta: meta.copyWith(game: meta.game.copyWith(sidesInverted: inverted)));
		send?.call(MessageType.DATA_META_GAME, md: md);
		return md;
	}

	Matchday addGameAction(final GameAction ga, final int gameIndex, {final void Function(MessageType, {int? additionalInfo, int? additionalInfo2, Matchday? md})? send = null}) {
		List<Game> newGames = List<Game>.from(games);
		newGames[gameIndex] = games[gameIndex].copyWith(actions: [...? games[gameIndex].actions, ga]);
		Matchday md = copyWith(games: newGames);
		send?.call(MessageType.DATA_GAMEACTION, additionalInfo: gameIndex, additionalInfo2: md.games[gameIndex].actions!.length-1, md: md);
		return md;
	}

	Matchday goalAdd(final int team, {final int? gameIndex, final void Function(MessageType, {int? additionalInfo, int? additionalInfo2, Matchday? md})? send = null}) {
		final goalAction = GameAction.goal(
			id: generateId(),
			change: GameActionChange.score(
				GameActionChangeScore(
					t1: team == 1 ? 1 : 0,
					t2: team == 2 ? 1 : 0
				)
			)
		);
		return addGameAction(goalAction, gameIndex ?? meta.game.index, send: send);
	}

	Matchday goalRemoveLast(final int team, {final int? gameIndex, final void Function(MessageType, {int? additionalInfo, Matchday? md})? send = null}) {
		final Game g = games[gameIndex ?? meta.game.index];
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
		newGames[meta.game.index] = updatedGame;

		final Matchday md = copyWith(games: newGames);
		send?.call(MessageType.DATA_GAMEACTIONS, additionalInfo: (gameIndex ?? meta.game.index), md: md);
		return md;
	}

	// Time can be positive or negative
	Matchday timeChange(int change, {final void Function(MessageType, {Matchday? md})? send = null}) {
		if (change + currentTime() < 0) change = -currentTime();
		final Matchday md = copyWith(meta: meta.copyWith(time: meta.time.copyWith(remaining: meta.time.remaining + change)));
		send?.call(MessageType.DATA_META_TIME, md: md);
		return md;
	}

	// Time can be positive or negative
	Matchday timeReset({final void Function(MessageType, {Matchday? md})? send = null}) {
		if (currentGamepart == null) return this;
		int? defTime = currentGamepart!.whenOrNull(
			timed: (_, len, _, _, _) => len,
			pause_timed: (_, len, _, _, _) => len
		);
		if (defTime == null) return this;
		return timeChange(defTime - currentTime(), send: send);
	}

	Matchday setPause(final bool pause, {final void Function(MessageType, {Matchday? md})? send = null}) {
		if (meta.time.paused && meta.time.remaining == 0) return this;
		Matchday md;
		if(pause)
			md = copyWith(meta: meta.copyWith(time: meta.time.copyWith(paused: pause, remaining: currentTime())));
		else {
			final unixTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
			md = copyWith(meta: meta.copyWith(time: meta.time.copyWith(paused: pause, lastUnpaused: unixTime)));
		}
		send?.call(MessageType.DATA_META_TIME, md: md);
		return md;
	}

	Matchday setCurrentGamepart(final int index, {final bool applySideEffect = true, final void Function(MessageType, {Matchday? md})? send = null}) {
		final Gamepart? gp = gamepartFromIndex(index);
		if(gp == null) return this;
		Matchday md = this;
		if(applySideEffect) {
			md = gp.maybeWhen(
				timed: (_, defTime, _, _, _) {
					if(meta.time.paused)
						return timeChange(defTime - currentTime(), send: send);
					else return this;
				},
				pause_timed: (_, defTime, _, _, _) {
					if(meta.time.paused)
						return timeChange(defTime - currentTime(), send: send);
					else return this;
				},
				orElse: () => this
			);
		}
		md = md.copyWith(meta: md.meta.copyWith(game: md.meta.game.copyWith(gamepart: index)));
		send?.call(MessageType.DATA_META_GAME, md: md);
		return md;
	}

	Matchday setEnded(final bool ended, {final void Function(MessageType, {Matchday? md})? send = null}) {
		final md = copyWith(meta: meta.copyWith(game: meta.game.copyWith(ended: ended)));
		send?.call(MessageType.DATA_META_GAME, md: md);
		return md;
	}

	// Returns a Map with Team and an associated integer to it.
	// This allows e.g. for 2 teams who are equally ranked
	Map<String, int>? rankingFromGroup(final String groupName) {
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

	// Gives back Map of all games the team is in
	Map<Game, int> teamGames(final String t, final String group) {
		Map<Game, int> teamGames = Map<Game, int>();

		for(int i=0; i < games.length; i++) {
			final Game g = games[i];
			if (g.groups?.firstWhereOrNull((groupName) => group == groupName) == null) continue;
			int? gameTeamIndex;
			if (g.team1.map(
			    byName: (t1) => t == t1.name,
				byQueryResolved: (t1) => t == t1.name,
				byQuery: (t1) => false,
			))
				gameTeamIndex = 1;
			else if (g.team2.map(
				byName: (t2) => t == t2.name,
				byQueryResolved: (t2) => t == t2.name,
				byQuery: (t2) => false)
			)
				gameTeamIndex = 2;
			else continue;

			teamGames[g] = gameTeamIndex;
		}
		return teamGames;
	}

	// Gives back Map of all games the team played and an
	Map<Game, int> teamGamesPlayed(final String t, final String group) {
		final lastGamePlayedIndex = meta.game.ended ? games.length : meta.game.index;
		if (groupFromName(group) == null); // TODO crash the program?

		final played = teamGames(t, group);
		played.removeWhere((_, i) => i >= lastGamePlayedIndex);

		return played;
	}

	Map<Game, int> teamGamesWon(final String t, final String g) {
		Map<Game, int> played = teamGamesPlayed(t, g);
		played.removeWhere((g, gameTeamIndex) {
			return g.teamGoals(gameTeamIndex) - g.teamGoals(gameTeamIndex == 1 ? 2 : 1) <= 0;
		});
		return played;
	}

	Map<Game, int> teamGamesLost(final String t, final String g) {
		Map<Game, int> played = teamGamesPlayed(t, g);
		played.removeWhere((g, gameTeamIndex) {
			return g.teamGoals(gameTeamIndex) - g.teamGoals(gameTeamIndex == 1 ? 2 : 1) >= 0;
		});
		return played;
	}

	Map<Game, int> teamGamesTied(final String t, final String g) {
		Map<Game, int> played = teamGamesPlayed(t, g);
		played.removeWhere((g, gameTeamIndex) {
			return g.teamGoals(gameTeamIndex) - g.teamGoals(gameTeamIndex == 1 ? 2 : 1) != 0;
		});
		return played;
	}

	int teamPoints(final String t, final String g) {
		return teamGamesWon(t, g).length * 3 + teamGamesTied(t, g).length;
	}

	int teamGoalDiff(final String t, final String g) {
		return teamGoalsPlus(t, g) - teamGoalsMinus(t, g);
	}

	int teamGoalsPlus(final String t, final String g) {
		int goals = 0;
		teamGamesPlayed(t, g).forEach((g, gameTeamIndex) {
			goals += g.teamGoals(gameTeamIndex);
		});
		return goals;
	}

	int teamGoalsMinus(final String t, final String g) {
		int goals = 0;
		teamGamesPlayed(t, g).forEach((g, gameTeamIndex) {
			goals += g.teamGoals(gameTeamIndex == 1 ? 2 : 1);
		});
		return goals;
	}

	Team? teamFromName(final String name) {
		return this.teams.firstWhere((team) => name == team.name);
	}

	Group? groupFromName(final String name) {
		return this.groups.firstWhere((group) => name == group.name);
	}

	Format? formatFromName(final String name) {
		return this.formats.firstWhere((format) => name == format.name);
	}

	Format? formatUnwrap(final Format f) {
		return f.copyWith(gameparts: f.gameparts.expand((gp) => gp.maybeWhen(
			format: (name, _, _, _) => formatUnwrap(formatFromName(name)!)!.gameparts,
			orElse: () => [ gp ]
		)).toList());
	}

	Gamepart? gamepartFromIndex(final int index) {
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
		@Default(MetaGame(index: 0, gamepart: 0, sidesInverted: false, ended: false))
		MetaGame game,
		@Default(MetaTime(paused: true, remaining: 0, lastUnpaused: 0, delay: 0))
		MetaTime time,
		@Default(MetaWidgets(scoreboard: false, gameplan: false, liveplan: false, gamestart: false, ad: false))
		MetaWidgets widgets,
		@Default(MetaObs(streamStarted: null, replayStarted: null))
		MetaObs obs,
	}) = _Meta;

	factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);
}

@freezed
class MetaGame with _$MetaGame {
	@JsonSerializable(includeIfNull: false)
	const factory MetaGame({
		@JsonKey(toJson: intOrNullNot0) @Default(0) int index,
		@JsonKey(toJson: intOrNullNot0) @Default(0) int gamepart,
		// This is for an EXTRA invert, not the normal side switching.
		// The normal side switching is done through formats!
		// This is still needed, because maybe the teams are standing the other way around at the beginning
		@JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue) @Default(false) bool sidesInverted,
		@JsonKey(toJson: boolOrNullTrue) @Default(false) bool ended,
	}) = _MetaGame;

	factory MetaGame.fromJson(Map<String, dynamic> json) => _$MetaGameFromJson(json);
}

@freezed
class MetaTime with _$MetaTime {
	@JsonSerializable(includeIfNull: false)
	const factory MetaTime({
		@JsonKey(toJson: boolOrNullFalse) @Default(true) bool paused,
		@Default(0) int remaining,
		@JsonKey(name: 'last_unpaused') @Default(0) int lastUnpaused,
		@JsonKey(name: 'delay', toJson: null) @Default(0) int delay,
	}) = _MetaTime;

	factory MetaTime.fromJson(Map<String, dynamic> json) => _$MetaTimeFromJson(json);
}

@freezed
class MetaWidgets with _$MetaWidgets {
	@JsonSerializable(includeIfNull: false)
	const factory MetaWidgets({
		@Default(false) bool scoreboard,
		@Default(false) bool gameplan,
		@Default(false) bool liveplan,
		@Default(false) bool gamestart,
		@Default(false) bool ad,
	}) = _MetaWidgets;

	factory MetaWidgets.fromJson(Map<String, dynamic> json) => _$MetaWidgetsFromJson(json);
}

@freezed
class MetaObs with _$MetaObs {
	@JsonSerializable(includeIfNull: false)
	const factory MetaObs({
		@Default(null) bool? streamStarted,
		@Default(null) bool? replayStarted,
	}) = _MetaObs;

	factory MetaObs.fromJson(Map<String, dynamic> json) => _$MetaObsFromJson(json);
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
		if (gq.gameIndex >= m.meta.game.index || gq.gameIndex < 0) return null;
		final Game g = m.games[gq.gameIndex];
		final int winner = g.winner;
		final GameTeamSlot winnerTeamSlot = winner == 1 ? g.team1 : g.team2;
		return winnerTeamSlot.mapOrNull(byName: (gts) => gts.name, byQueryResolved: (gts) => gts.name);
	}

	static String? _resolveTeamGameLoser(_GameQueryByGameLoser gq, Matchday m) {
		if (gq.gameIndex >= m.meta.game.index || gq.gameIndex < 0) return null;
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
	const factory Gamepart.pause_timed({
		required String name,
		required int length,
		@JsonKey(toJson: boolOrNullTrue) @Default(false) bool repeat,
		@JsonKey(toJson: boolOrNullTrue) @Default(false) bool decider,
		@JsonKey(name: 'sides_inverted', toJson: boolOrNullTrue) @Default(false) bool sidesInverted,
	}) = _GamepartPauseTimed;

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

