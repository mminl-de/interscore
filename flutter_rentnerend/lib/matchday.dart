import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter_rentnerend/lib.dart';

class GameplanTime {
	late DateTime timestamp;
	late int curTime;
	late int curGamepart;

	GameplanTime(Matchday md){
		timestamp = DateTime.now();
		curTime = md.m_curTime;
		curGamepart = md.m_curGamepart;
	}
}

class GameQuery {
	String set;
	Group? group = null;
	int key;

	GameQuery.fromName({required this.set, String? groupName, required this.key, required Matchday md}) {
		if(groupName == null) return;
		group = md.stringToGroup(groupName);
	}

	GameQuery.fromGroup({required this.set, this.group, required this.key});

	GameQuery copy() => GameQuery.fromGroup(set: set, group: group, key: key);
}

class GamePartPenalty {
	// is used, if people should shoot multiple times / if teams alternate or every penalty of one team is doe after each other
	// e.g. football these would be 0,1,2,3,4 because people cant shoot twice
	// in cycleball 0,1,0,1 because players rotate
	// The values dont actually equal indices
	int shootingTeam; // 0 or 1
	int? shootingPlayer; // 0,1,2, List<Players>.len
	// String shooting_player_role; //TODO DECIDE add this?

	GamePartPenalty({required this.shootingTeam, this.shootingPlayer});

	@override
	String toString() {
		return "{team: ${shootingTeam}, player: ${shootingPlayer}}";
	}
}

class GamePart {
	String name;
	bool repeat;
	bool decider;
	int? length;
	List<GamePartPenalty>? penalties;

	GamePart({required this.name, this.repeat = false, this.decider = false, this.length, this.penalties});

	@override
		String toString() {
			return "{${name}, repeat: ${repeat}, decider: ${decider}, length: ${length}, penalties: ${penalties}}";
		}
}

class GameFormat {
	String name;
	List<GamePart> gameparts;

	GameFormat(this.name, this.gameparts);

	@override
  String toString() {
    return "{${name}, ${gameparts}}";
  }
}

class Goal {
	Player? player;
	late GameplanTime time;

	Goal({String? playerName, required Matchday md}) {
		if(playerName != null) {player = md.stringToPlayer(playerName);}
		time = GameplanTime(md);
	}
}
class Penalty {
	// type=YELLOW_CARD doesnt have a shooting Player,
	// type=4M could potentially have a shooting Player, but could also not be recorded
	Player? shootingPlayer;
	late Game game;
	late GameplanTime time;
	String type;

	Penalty({String? shootingPlayerName, required String gameName, required this.type, required Matchday md}) {
		if(shootingPlayerName != null) {shootingPlayer = md.stringToPlayer(shootingPlayerName);}
		game = md.stringToGame(gameName) ?? (throw Exception("JSON"));
		time = GameplanTime(md);
	}
}

class Player {
	String name;
	String? role;
	//late Team team;

	//Player({required this.name, this.role, required String teamName, required Matchday md}) {
	//	team = md.stringToTeam(teamName) ?? (throw Exception("JSON"));
	//}
	Player({required this.name, this.role});
}
class Team {
	List<Player> players = <Player>[];
	String name;
	String? logoURI;
	Color color;

	Team({required List<String> playersName, required this.name, this.logoURI, required this.color, required Matchday md}) {
		if(playersName.isEmpty) throw Exception("JSON");
		for (String playerName in playersName) {
			players.add(md.stringToPlayer(playerName) ?? (throw Exception("JSON")));
		}
	}
}

class Game {
	String? name;
	Team? t1;
	Team? t2;
	bool missingT1;
	String? missingReasonT1;
	bool missingT2;
	String? missingReasonT2;
	GameQuery? queryT1;
	GameQuery? queryT2;
	List<Goal> goalsT1 = <Goal>[];
	List<Goal> goalsT2 = <Goal>[];
	late GameFormat format;
	bool needsDecider;
	List<Group>? groups;

	Game({
		this.name,
		String? nameT1,
		String? nameT2,
		GameQuery? queryT1,
		GameQuery? queryT2,
		this.missingT1 = false,
		this.missingReasonT1,
		this.missingT2 = false,
		this.missingReasonT2,
		required String formatName,
		this.needsDecider = false,
		required List<String>? groupNames,
		required Matchday md
	}) {
		// TODO good error messages
		if(nameT1 == null && queryT1 == null) (throw Exception("JSON"));
		if(nameT1 != null && queryT1 != null) (throw Exception("JSON"));
		if(nameT1 != null) {t1 = md.stringToTeam(nameT1) ?? (throw Exception("JSON"));}
		else {this.queryT1 = queryT1?.copy();} //? is needed, because LSP is too dumb
		if(nameT2 == null && queryT2 == null) (throw Exception("JSON"));
		if(nameT2 != null && queryT2 != null) (throw Exception("JSON"));
		if(nameT2 != null) {t2 = md.stringToTeam(nameT2) ?? (throw Exception("JSON"));}
		else {this.queryT2 = queryT2?.copy();}

		if(groupNames != null) {
			this.groups = <Group>[];
			for(String groupName in groupNames) {
				this.groups?.add(md.stringToGroup(groupName) ?? (throw Exception("JSON")));
			}
		}

		if(missingT1 == false && missingReasonT1 != null) (throw Exception("JSON"));
		if(missingT2 == false && missingReasonT2 != null) (throw Exception("JSON"));

		format = md.stringToFormat(formatName) ?? (throw Exception("JSON"));
	}
}

class Group {
	String name;
	List<Team> members = <Team>[];

	Group(this.name, List<String> members, Matchday md) {
		if(members.isEmpty) throw Exception("JSON");
		for (String memberName in members) {
			this.members.add(md.stringToTeam(memberName) ?? (throw Exception("JSON")));
		}
	}
}

class Matchday {
	// TODO DECIDE how to procede with naming
	late int m_gameI;
	late int m_curGamepart;
	late bool m_paused;
	late int m_curTime;
	late DateTime m_startTime;
	late GameFormat curFormat;

	List<Player> players = <Player>[];
	List<Team> teams = <Team>[];
	List<Game> games = <Game>[];
	List<Group> groups = <Group>[];
	List<GameFormat> formats = <GameFormat>[];
	List<Penalty> penalties = <Penalty>[];

	Player? stringToPlayer(String name) {
		for(Player player in this.players) {
			if(player.name == name) return player;
		}
		return null;
	}

	Team? stringToTeam(String name) {
		for(Team team in this.teams)
			if(team.name == name) return team;
		debugPrint("WARN: Couldnt find Team: ${name}");
		return null;
	}

	Game? stringToGame(String name) {
		for(Game game in this.games)
			if(game.name == name) return game;
		debugPrint("WARN: Couldnt find Game: ${name}");
		return null;
	}

	Group? stringToGroup(String name) {
		for(Group group in this.groups)
			if(group.name == name) return group;
		debugPrint("WARN: Couldnt find Group: ${name}");
		return null;
	}

	GameFormat? stringToFormat(String name) {
		for(GameFormat format in this.formats)
			if(format.name == name) return format;
		debugPrint("WARN: Couldnt find Format: ${name}");
		return null;
	}

	Matchday(String json) {
		Never error(String msg) {
			debugPrint('ERROR: Parsing JSON: $msg');
			throw Exception(msg);
		}
		Never errorField(String field, String typeWanted) {
			error('Field $field missing/wrong type(wanted: $typeWanted)');
		}
		Never errorMissing(String field) {
			error('Field $field missing');
		}
		Never errorType(String field, String typeWanted) {
			error('Field $field has wrong type(wanted: $typeWanted)');
		}

		List<GamePart> jsonDecodeGameparts(List<dynamic> gamepartsJson) {
			List<GamePart> gameparts = [];
			for (Map<String, dynamic> gamepart in gamepartsJson) {
				List<GamePartPenalty>? penalties;
				int? length;
				if(gamepart['penalties'] != null && gamepart['length'] != null) error("Each format[?].gameparts[?] can have either Field 'penalties' or Field 'length' but not both!");
				if(gamepart['penalties'] != null && gamepart['format'] == null && gamepart['length'] == null) {
					penalties = [];
					for(Map<String, dynamic> penalty in gamepart['penalties']) {
						if(penalty['shooting'] == null) errorMissing("format[?].gameparts[?].penalties[?].shooting");
						penalties.add(GamePartPenalty(
							shootingTeam: (penalty['shooting']['team'] is int) ? penalty['shooting']['team'] : errorField("format[?].gameparts[?].penalties[?].shooting.team", "String"),
							shootingPlayer: (penalty['shooting']['player'] is int?) ? penalty['shooting']['team'] : errorType("format[?].gameparts[?].penalties[?].shooting.player", "int")
						)); // TODO add sanity checks
					}
				} else if (gamepart['length'] != null && gamepart['penalties'] == null && gamepart['format'] == null) {
					length = gamepart['length'];
				} else if (gamepart['format'] != null && gamepart['penalties'] == null && gamepart['length'] == null) {
					String formatString = (gamepart['format'] is String) ? gamepart['format'] : errorType("formats[?].gameparts[?].format", "String");
					GameFormat wrappedFormat = stringToFormat(formatString) ?? error("The format specified in formats[?].gameparts[?].format actually has to exist. Typo?");
					gameparts.addAll(wrappedFormat.gameparts);
					continue; // TODO check if decider, repeat, name is there and warn/error about it beeing obsolete
				} else {
					error("Each format[?].gameparts[?] must have exactly one Field 'penalties' or Field 'length' or 'format' but not more or less");
				}
				String name = (gamepart['name'] is String) ? gamepart['name'] : errorField("format[?].gameparts[?].name", "String");
				bool? decider = (gamepart['decider'] is bool?) ? gamepart['decider'] : errorType("format[?].gameparts[?].decider", "bool");
				bool? repeat = (gamepart['repeat'] is bool?) ? gamepart['repeat'] : errorType("format[?].gameparts[?].repeat", "bool");
				gameparts.add(GamePart(name: name, decider: decider ?? false, repeat: repeat ?? false, penalties: penalties, length: length));
			}
			if(gameparts.isEmpty) error("gameparts[] needs at least one element (but has none)");
			return gameparts;
		}


		final Map<String, dynamic> data;
		try { data = jsonDecode(json) as Map<String, dynamic>; }
		catch (_){ error("Syntax error. Try jsonlint.com to find the problem"); }

		final meta = data['meta'] as Map<String, dynamic>?;
		if(meta == null) errorMissing("meta");

		this.m_gameI = (meta['game_i'] is int) ? meta['game_i'] : errorField("meta.game_i", "int");
		this.m_curGamepart = (meta['cur_gamepart'] is int) ? meta['cur_gamepart'] : errorField("meta.cur_gamepart", "int");
		this.m_paused = (meta['paused'] is bool) ? meta['paused'] : errorField("meta.paused", "bool");
		this.m_curTime = (meta['cur_time'] is int) ? meta['cur_time'] : errorField("meta.cur_time", "int");

		if(this.m_gameI < 0) error("meta.game_i cant be negative!");
		if(this.m_curGamepart < 0) error("meta.m_curGamepart cant be negative!");
		if(this.m_curTime < 0) error("meta.curTime cant be negative!");

		if(meta['formats'] == null) errorMissing("formats");
		for (Map<String, dynamic> format in meta['formats']) {
			String nameFormat = (format['name'] is String) ? format['name'] : errorField("formats[?].name", "String");

			if(format['gameparts'] == null) errorMissing("formats[?].gameparts");
			this.formats.add(GameFormat(nameFormat, jsonDecodeGameparts(format['gameparts'])));
		}
		if(this.formats.isEmpty) error("formats[] needs at least one element (but has none)");

		if(data['teams'] == null) errorMissing("teams");
		for(Map<String, dynamic> team in data['teams']) {
			String name = (team['name'] is String) ? team['name'] : errorField("teams[?].name", "String");
			String? logoURI = (team['logo_uri'] is String) ? team['logo_uri'] : errorField("teams[?].logo_uri", "String");
			String color = (team['color'] is String) ? team['color'] : errorField("teams[?].color", "String");
			List<String> playersName = <String>[]; // TOOD nuke
			if(team['players'] == null) errorMissing("teams[?].players");
			for(Map<String, dynamic> player in team['players']) {
				String playerName = (player['name'] is String) ? player['name'] : errorField("teams[?].players[?].name", "String");
				playersName.add(playerName); // TODO nuke
				String? role = (player['role'] is String?) ? player['role'] : errorField("teams[?].players[?].role", "String");
				this.players.add(Player(name: playerName, role: role));
			}
			// TODO use List<Players> players instead of List<String> playersName in constructor
			this.teams.add(Team(name: name, logoURI: logoURI, color: colorFromHexString(color), playersName: playersName, md: this));
		}

		if(data['groups'] != null) {
			for(Map<String, dynamic> group in data['groups']) {
				String name = (group['name'] is String) ? group['name'] : errorField("groups[?].name", "String");
				List<String> members = <String>[];
				if(group['members'] == null) errorMissing("groups[?].missing");
				//TODO Find out if we can skip this
				for(String member in group['members']) members.add(member);
				if(members.isEmpty) error("groups[?].members must have at least one element");
				this.groups.add(Group(name, members, this)); // TODO Shallow Copy?
			}
		}

		if(data['games'] == null) errorMissing("games");
		for(Map<String, dynamic> game in data['games']) {
			String? name = (game['name'] is String?) ? game['name'] : errorType("games[?].name", "String");

			if(game['1'] == null) errorMissing("games[?].1");
			if(game['1']['name'] != null && game['1']['query'] != null) error("Either field games[?].1.name or games[?].1.query needed. Not both!");
			String? nameT1;
			String? missingReasonT1;
			GameQuery? queryT1;
			if(game['1']['name'] != null) {
				nameT1 = (game['1']['name'] is String?) ? game['1']['name'] : errorType("games[?].1.name", "String");
				if(game['1']['missing'] != null) {
					missingReasonT1 = (game['1']['missing']['reason'] is String?) ? game['1']['missing']['reason'] : errorType("games[?].1.missing.reason", "String");
				}
			} else if (game['1']['query'] != null) {
				String set = (game['1']['query']['set'] is String) ? game['1']['query']['set'] : errorField("games[?].1.query.set", "String");
				String? group = (game['1']['query']['group'] is String?) ? game['1']['query']['group'] : errorType("games[?].1.query.group", "String");
				int key = (game['1']['query']['key'] is int) ? game['1']['query']['key'] : errorField("games[?].1.query.key", "int");
				queryT1 = GameQuery.fromName(set: set, groupName: group, key: key, md: this);
			}
			else { error("Either field games[?].1.name or games[?].1.query needed (but has neither)"); }

			if(game['2'] == null) errorMissing("games[?].2");
			if(game['2']['name'] != null && game['2']['query'] != null) error("Either field games[?].2.name or games[?].2.query needed. Not both!");
			String? nameT2;
			String? missingReasonT2;
			GameQuery? queryT2;
			if(game['2']['name'] != null) {
				nameT2 = (game['2']['name'] is String?) ? game['2']['name'] : errorType("games[?].2.name", "String");
				if(game['2']['missing'] != null) {
					missingReasonT2 = (game['2']['missing']['reason'] is String?) ? game['2']['missing']['reason'] : errorType("games[?].2.missing.reason", "String");
				}
			} else if (game['2']['query'] != null) {
				String set = (game['2']['query']['set'] is String) ? game['2']['query']['set'] : errorField("games[?].2.query.set", "String");
				String? group = (game['2']['query']['group'] is String?) ? game['2']['query']['group'] : errorType("games[?].2.query.group", "String");
				int key = (game['2']['query']['key'] is int) ? game['2']['query']['key'] : errorField("games[?].2.query.key", "int");
				queryT2 = GameQuery.fromName(set: set, groupName: group, key: key, md: this);
			}
			else { error("Either field games[?].2.name or games[?].2.query needed (but has neither)"); }

			//List<String> groups = (game['groups'] is List<String>) ? game['groups'] : errorType("games[?].groups", "String Array");
			if(game['groups'] is! List?) errorType("games[?].groups", "String Array");
			List<String> groups = <String>[];
			if(game['groups'] != null) {
				groups = (game['groups'] as List)
					.map((e) => e is String ? e : errorType("games[?].groups[*]", "String"))
					.toList();
			}

			if(game['format'] == null) errorMissing("games[?].format");
			String formatName = (game['format']['name'] is String) ? game['format']['name'] : errorField("games[?].format.name", "String");
			bool? decider = (game['format']['decider'] is bool?) ? game['format']['decider'] : errorField("games[?].format.decider", "bool");

			this.games.add(Game(name: name, nameT1: nameT1, nameT2: nameT2, queryT1: queryT1, queryT2: queryT2, missingT1: missingReasonT1 != null, missingT2: missingReasonT2 != null, missingReasonT1: missingReasonT1, missingReasonT2: missingReasonT2, formatName: formatName, needsDecider: decider ?? false, groupNames: groups, md: this));
		}

		// TODO Add penalties

		this.curFormat = this.games[this.m_gameI].format;
	}
}
