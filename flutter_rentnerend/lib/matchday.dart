import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter_rentnerend/lib.dart';

class GameplanTime {
	late DateTime timestamp;
	late Uint16 curTime;
	late Uint8 curGamepart;

	GameplanTime(Matchday md){
		timestamp = DateTime.now();
		curTime = md.m_curTime;
		curGamepart = md.m_curGamepart;
	}
}

class GameQuery {
	String set;
	late Group? group;
	Uint8 key;

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
	Uint8 shootingTeam; // 0 or 1
	Uint8? shootingPlayer; // 0,1,2, List<Players>.len
	// String shooting_player_role; //TODO DECIDE add this?

	GamePartPenalty({required this.shootingTeam, this.shootingPlayer});
}

class GamePart {
	String name;
	bool repeat;
	bool decider;
	Uint16? length;
	List<GamePartPenalty>? penalties;

	GamePart({required this.name, this.repeat = false, this.decider = false, this.length, this.penalties});
}

class GameFormat {
	String name;
	List<GamePart> gameparts;

	GameFormat(this.name, this.gameparts);
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
	late List<Player> players;
	String name;
	String? logoURI;
	Color color;

	Team({required List<String> playersName, required this.name, this.logoURI, required this.color, required Matchday md}) {
		if(playersName.isEmpty) throw Exception("JSON");
		for (var playerName in playersName) {
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
	List<Goal> goalsT1 = [];
	List<Goal> goalsT2 = [];
	late GameFormat format;
	bool needsDecider;
	late List<Group> groups;

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
		required List<String> groupNames,
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

		for(String groupName in groupNames) {
			groups.add(md.stringToGroup(groupName) ?? (throw Exception("JSON")));
		}

		if(missingT1 == false && missingReasonT1 != null) (throw Exception("JSON"));
		if(missingT2 == false && missingReasonT2 != null) (throw Exception("JSON"));

		format = md.stringToFormat(formatName) ?? (throw Exception("JSON"));
	}
}

class Group {
	String name;
	late List<Team> members;

	Group(this.name, List<String> members, Matchday md) {
		if(members.isEmpty) throw Exception("JSON");
		for (var memberName in members) {
			this.members.add(md.stringToTeam(memberName) ?? (throw Exception("JSON")));
		}
	}
}

class Matchday {
	// TODO DECIDE how to procede with naming
	late Uint8 m_gameI;
	late Uint8 m_curGamepart;
	late bool m_paused;
	late Uint16 m_curTime;
	late DateTime m_startTime;
	late GameFormat curFormat;

	List<Player> players = [];
	List<Team> teams = [];
	List<Game> games = [];
	List<Group> groups = [];
	List<GameFormat> formats = [];
	List<Penalty> penalties = [];

	Player? stringToPlayer(String name) {return null;}
	Team? stringToTeam(String name) {return null;}
	Game? stringToGame(String name) {return null;}
	Group? stringToGroup(String name) {return null;}
	GameFormat? stringToFormat(String name) {return null;}

	Matchday(String json) {
		final data = jsonDecode(json);

		final meta = data['meta'];
		if(meta == null) throw Exception("JSON");

		this.m_gameI = meta['game_i'] ?? (throw Exception("JSON"));
		this.m_curGamepart = meta['cur_gamepart'] ?? (throw Exception("JSON"));
		this.m_paused = meta['paused'] ?? (throw Exception("JSON"));
		this.m_curTime = meta['cur_time'] ?? (throw Exception("JSON"));

		if(meta['formats'] == null) throw Exception("JSON");
		for (dynamic format in meta['formats']) {
			if(format['gameparts'] == null) (throw Exception("JSON"));
			List<GamePart> gameparts = [];
			for (dynamic gamepart in format['gameparts']) {
				List<GamePartPenalty>? penalties;
				Uint16? length;
				if(gamepart['penalties'] != null && gamepart['length'] != null) throw Exception("JSON");
				if(gamepart['penalties'] != null) {
					penalties = [];
					for(dynamic penalty in gamepart['penalties']) {
						if(penalty['shooting'] == null) throw Exception("JSON");
						penalties.add(GamePartPenalty(
							shootingTeam: penalty['shooting']['team'] ?? (throw Exception("JSON")),
							shootingPlayer: penalty['shooting']['player']
						));
					}
				} else if (gamepart['length'] != null) {
					length = gamepart['length'];
				} else {throw Exception("JSON");}
				String name = gamepart['name'] ?? (throw Exception("JSON"));
				bool? decider = gamepart['decider'];
				bool? repeat = gamepart['repeat'];
				gameparts.add(GamePart(name: name, decider: decider ?? false, repeat: repeat ?? false, penalties: penalties, length: length));
			}
			if(gameparts.isEmpty) throw Exception("JSON");
			this.formats.add(GameFormat(format['name'], gameparts));
		}
		if(this.formats.isEmpty) throw Exception("JSON");

		if(data['teams'] == null) throw Exception("JSON");
		for(dynamic team in data['teams']) {
			String name = team['name'] ?? (throw Exception("JSON"));
			String? logoURI = team['logo_uri'];
			String color = team['color'] ?? (throw Exception("JSON"));
			List<String> playersName = [];
			if(team['players'] == null) throw Exception("JSON");
			for(dynamic player in team['players']) {
				playersName.add(player['name'] ?? (throw Exception("JSON")));
				String? role = player['role'];
				this.players.add(Player(name: playersName.last, role: role));
			}
			this.teams.add(Team(name: name, logoURI: logoURI, color: colorFromHexString(color), playersName: playersName, md: this));
		}

		if(data['groups'] != null) {
			for(dynamic group in data['groups']) {
				String name = group['name'] ?? (throw Exception("JSON"));
				List<String> members = [];
				if(group['members'] == null) throw Exception("JSON");
				//TODO Find out if we can skip this
				for(String member in group['members']) {members.add(member);}
				if(members.isEmpty) throw Exception("JSON");
				this.groups.add(Group(name, members, this)); // TODO Shallow Copy?
			}
		}

		if(data['games'] == null) throw Exception("JSON");
		for(dynamic game in data['games']) {
			String? name = game['name'];

			if(game['1'] == null) throw Exception("JSON");
			if(game['1']['name'] != null && game['1']['query'] != null) throw Exception("JSON");
			String? nameT1;
			String? missingReasonT1;
			GameQuery? queryT1;
			if(game['1']['name'] != null) {
				nameT1 = game['1']['name'] ?? (throw Exception("JSON"));
				if(game['1']['missing'] != null) {
					missingReasonT1 = game['1']['missing']['reason'];
				}
			} else if (game['1']['query'] != null) {
				String set = game['1']['query']['set'] ?? (throw Exception("JSON"));
				String? group = game['1']['query']['group'];
				Uint8 key = game['1']['query']['key'] ?? (throw Exception("JSON"));
				queryT1 = GameQuery.fromName(set: set, groupName: group, key: key, md: this);
			}
			else { throw Exception("JSON"); }

			if(game['2']['name'] != null && game['2']['query'] != null) throw Exception("JSON");
			String? nameT2;
			String? missingReasonT2;
			GameQuery? queryT2;
			if(game['2']['name'] != null) {
				nameT2 = game['2']['name'] ?? (throw Exception("JSON"));
				if(game['2']['missing'] != null) {
					missingReasonT2 = game['2']['missing']['reason'];
				}
			} else if (game['2']['query'] != null) {
				String set = game['2']['query']['set'] ?? (throw Exception("JSON"));
				String? group = game['2']['query']['group'];
				Uint8 key = game['2']['query']['key'] ?? (throw Exception("JSON"));
				queryT2 = GameQuery.fromName(set: set, groupName: group, key: key, md: this);
			}
			else { throw Exception("JSON"); }

			List<String> groups = game['groups'] ?? (throw Exception("JSON"));

			if(game['format'] == null) throw Exception("JSON");
			String formatName = game['format']['name'] ?? (throw Exception("JSON"));
			bool? decider = game['format']['decider'];

			this.games.add(Game(name: name, nameT1: nameT1, nameT2: nameT2, queryT1: queryT1, queryT2: queryT2, missingT1: missingReasonT1 != null, missingT2: missingReasonT2 != null, missingReasonT1: missingReasonT1, missingReasonT2: missingReasonT2, formatName: formatName, needsDecider: decider ?? false, groupNames: groups, md: this));
		}

		// TODO Add penalties

		this.curFormat = this.games[this.m_gameI as int].format;
	}
}
