import 'md.dart';
import 'MessageType.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'lib.dart' as lib;

abstract class WSClient {
	String url;
	final ValueNotifier<Matchday> mdl;
	final bool allowReadFrom, allowWriteTo;
	final ValueNotifier<bool> connected = ValueNotifier(false);
	final ValueNotifier<bool> boss = ValueNotifier(false);

	WSClient(this.url, this.mdl, this.allowReadFrom, this.allowWriteTo);

	void listen(final dynamic msg) {
		// debugPrint("WS Client: Received message: ${msg}");
		if(msg is! List<int>) {
			debugPrint("WS Client: Received msg with unknown type(${msg.runtimeType}): ${msg}. Ignoring...");
			return;
		}
		if(msg.length == 0) {
			debugPrint("WS Client: Received empty message...");
			return;
		}

		// This is a "write operation, but shouldnt be forbidden by allowWriteTo
		if(msg[0] == MessageType.DATA_IM_BOSS.value) {
			if(msg.length < 2) return;
			debugPrint("Received DATA_IM_BOSS: ${msg[1] == 1}");
			boss.value = msg[1] == 1 ? true : false;
		}
		// Parse the message
		if(allowReadFrom) _listenRead(msg);
		if(allowWriteTo) _listenWrite(msg);
	}

	void _listenRead(final List<int> msg) {
		if(msg[0] == MessageType.PLS_SEND_META.value)
			sendSignal(MessageType.DATA_META);
		else if(msg[0] == MessageType.PLS_SEND_META_GAME.value)
			sendSignal(MessageType.DATA_META_GAME);
		else if(msg[0] == MessageType.PLS_SEND_META_OBS.value)
			sendSignal(MessageType.DATA_META_OBS);
		else if(msg[0] == MessageType.PLS_SEND_META_WIDGETS.value)
			sendSignal(MessageType.DATA_META_WIDGETS);
		else if(msg[0] == MessageType.PLS_SEND_GAMES.value)
			sendSignal(MessageType.DATA_GAMES);
		else if(msg[0] == MessageType.PLS_SEND_GAME.value)
			sendSignal(MessageType.DATA_GAME);
		else if(msg[0] == MessageType.PLS_SEND_GAMEACTIONS.value)
			sendSignal(MessageType.DATA_GAMEACTIONS);
		else if(msg[0] == MessageType.PLS_SEND_GAMEACTION.value)
			sendSignal(MessageType.DATA_GAMEACTION);
		else if(msg[0] == MessageType.PLS_SEND_FORMATS.value)
			sendSignal(MessageType.DATA_FORMATS);
		else if(msg[0] == MessageType.PLS_SEND_FORMAT.value)
			sendSignal(MessageType.DATA_FORMAT);
		else if(msg[0] == MessageType.PLS_SEND_TEAMS.value)
			sendSignal(MessageType.DATA_TEAMS);
		else if(msg[0] == MessageType.PLS_SEND_TEAM.value)
			sendSignal(MessageType.DATA_TEAM);
		else if(msg[0] == MessageType.PLS_SEND_GROUPS.value)
			sendSignal(MessageType.DATA_GROUPS);
		else if(msg[0] == MessageType.PLS_SEND_GROUP.value)
			sendSignal(MessageType.DATA_GROUP);
		else if(msg[0] == MessageType.PLS_SEND_IM_BOSS.value)
			sendSignal(MessageType.DATA_IM_BOSS);
		else if(msg[0] == MessageType.PLS_SEND_TIMESTAMP.value)
			sendSignal(MessageType.DATA_TIMESTAMP);
		else if(msg[0] == MessageType.PLS_SEND_JSON.value)
			sendSignal(MessageType.DATA_JSON);
	}

	void _listenWrite(final List<int> msg) {
		Matchday md = mdl.value;
		debugPrint("Received: ${msg[0]}");

		if(msg[0] == MessageType.DATA_META.value)
			mdl.value = md.copyWith(meta: Meta.fromJson(jsonDecode(utf8.decode(msg.sublist(1)))));
		else if(msg[0] == MessageType.DATA_META_GAME.value) {
			mdl.value = md.copyWith(meta: md.meta.copyWith(game: MetaGame.fromJson(jsonDecode(utf8.decode(msg.sublist(1))))));
		}
		else if(msg[0] == MessageType.DATA_META_TIME.value)
			mdl.value = md.copyWith(meta: md.meta.copyWith(time: MetaTime.fromJson(jsonDecode(utf8.decode(msg.sublist(1))))));
		else if(msg[0] == MessageType.DATA_META_OBS.value)
			mdl.value = md.copyWith(meta: md.meta.copyWith(obs: MetaObs.fromJson(jsonDecode(utf8.decode(msg.sublist(1))))));
		else if(msg[0] == MessageType.DATA_META_WIDGETS.value)
			mdl.value = md.copyWith(meta: md.meta.copyWith(widgets: MetaWidgets.fromJson(jsonDecode(utf8.decode(msg.sublist(1))))));
		else if(msg[0] == MessageType.DATA_GAMES.value)
			mdl.value = md.copyWith(
				games: (jsonDecode(utf8.decode(msg.sublist(1))) as List)
					.map((e) => Game.fromJson(e as Map<String, dynamic>))
					.toList()
			);
		else if(msg[0] == MessageType.DATA_GAME.value) {
			Game newGame = Game.fromJson(jsonDecode(utf8.decode(msg.sublist(1))));
			int index = mdl.value.games.indexWhere((g) => g.name == newGame.name);
			debugPrint("Received DATA_GAME. Index: ${index}");
			if(index != -1) {
				List<Game> newGames = List<Game>.from(mdl.value.games);
				newGames[index] = newGame;
				mdl.value = mdl.value.copyWith(games: newGames);
			} else
				// This means We received a new Game, which we dont have.
				// We cant know where to insert it, therefor we ask to send all Games, implicitly giving us the index
				sendSignal(MessageType.PLS_SEND_GAMES);
		}
		else if(msg[0] == MessageType.DATA_GAMEACTIONS.value) {
			final int index = msg[1];
			if(index < 0 || index > md.games.length-1) {
				debugPrint("WARN: Received DATA_GAMEACTIONS with illegal gameindex. Should be: 0-${md.games.length-1} but is ${index}");
				return;
			}
			Game newGame = md.games[index].copyWith(
				actions: (jsonDecode(utf8.decode(msg.sublist(2))) as List)
					.map((e) => GameAction.fromJson(e as Map<String, dynamic>))
					.toList()
			);
			List<Game> newGames = List<Game>.from(mdl.value.games);
			newGames[index] = newGame;
			mdl.value = mdl.value.copyWith(games: newGames);
		}
		else if(msg[0] == MessageType.DATA_GAMEACTION.value) {
			if(msg.length < 2) return;
			final int index = msg[1];
			if(index < 0 || index > md.games.length-1) {
				debugPrint("WARN: Received DATA_GAMEACTION with illegal gameindex. Should be: 0-${md.games.length-1} but is ${index}");
				return;
			}

			GameAction newGameAction = GameAction.fromJson(jsonDecode(utf8.decode(msg.sublist(2))));
			int? actionIndex = mdl.value.games[index].actions?.indexWhere((a) => a.id == newGameAction.id);
			if(actionIndex == null || actionIndex == -1) {
				mdl.value = md.addGameAction(newGameAction, index);
				return;
			}

			List<GameAction> newGameActions = List<GameAction>.from(mdl.value.games[index].actions!);
			newGameActions[actionIndex] = newGameAction;

			Game newGame = md.games[index].copyWith(actions: newGameActions);
			List<Game> newGames = List<Game>.from(mdl.value.games);
			newGames[index] = newGame;
			mdl.value = mdl.value.copyWith(games: newGames);
		}
		else if(msg[0] == MessageType.DATA_FORMATS.value) {
			mdl.value = md.copyWith(
				formats: (jsonDecode(utf8.decode(msg.sublist(1))) as List)
					.map((e) => Format.fromJson(e as Map<String, dynamic>))
					.toList()
			);
		}
		else if(msg[0] == MessageType.DATA_FORMAT.value) {
			Format newFormat = Format.fromJson(jsonDecode(utf8.decode(msg.sublist(1))));
			int index = mdl.value.formats.indexWhere((f) => f.name == newFormat.name);
			debugPrint("Received DATA_FORMAT. Index: ${index}");

			if(index != -1) {
				List<Format> newFormats = List<Format>.from(mdl.value.formats);
				newFormats[index] = newFormat;
				mdl.value = md.copyWith(formats: newFormats);
			} else
				mdl.value = md.copyWith(formats: [newFormat, ... md.formats]);
		}
		else if(msg[0] == MessageType.DATA_TEAMS.value)
			mdl.value = md.copyWith(
				teams: (jsonDecode(utf8.decode(msg.sublist(1))) as List)
					.map((e) => Team.fromJson(e as Map<String, dynamic>))
					.toList()
			);
		else if(msg[0] == MessageType.DATA_TEAM.value) {
			Team newTeam = Team.fromJson(jsonDecode(utf8.decode(msg.sublist(1))));
			int index = mdl.value.formats.indexWhere((t) => t.name == newTeam.name);
			debugPrint("Received DATA_TEAM. Index: ${index}");

			if(index != -1) {
				List<Team> newTeams = List<Team>.from(mdl.value.formats);
				newTeams[index] = newTeam;
				mdl.value = md.copyWith(teams: newTeams);
			} else
				mdl.value = md.copyWith(teams: [newTeam, ... md.teams]);
		}
		else if(msg[0] == MessageType.DATA_GROUPS.value)
			mdl.value = md.copyWith(
				groups: (jsonDecode(utf8.decode(msg.sublist(1))) as List)
					.map((e) => Group.fromJson(e as Map<String, dynamic>))
					.toList()
			);
		else if(msg[0] == MessageType.DATA_GROUP.value) {
			Group newGroup = Group.fromJson(jsonDecode(utf8.decode(msg.sublist(1))));
			int index = mdl.value.formats.indexWhere((g) => g.name == newGroup.name);
			debugPrint("Received DATA_GROUP. Index: ${index}");

			if(index != -1) {
				List<Group> newGroups = List<Group>.from(mdl.value.formats);
				newGroups[index] = newGroup;
				mdl.value = md.copyWith(groups: newGroups);
			} else
				mdl.value = md.copyWith(groups: [newGroup, ... md.groups]);
		}
		else if(msg[0] == MessageType.DATA_TIMESTAMP.value) {
			mdl.value = md.copyWith(meta: md.meta.copyWith(time: md.meta.time.copyWith(delay: lib.i64FromBytes(msg, 1))));
		}
		else if(msg[0] == MessageType.DATA_JSON.value) {
			mdl.value = Matchday.fromJson(jsonDecode(utf8.decode(msg.sublist(1))) as Map<String, dynamic>);
		}
		else {
			debugPrint(" NUUUUR. This: ${utf8.decode(msg.sublist(1))}");
		}
	}

	sendSignal(final MessageType signal, {final int? additionalInfo, final Matchday? md}) {
		final List<int>? msg = lib.signalToMsg(signal, md ?? mdl.value, additionalInfo: additionalInfo);
		if(msg == null) return;

		send(msg);
	}

	void setUrl(final String url) {
		this.url = url;
	}

	Future<void> connect();
	void send(List<int> msg);
	void close();
}
