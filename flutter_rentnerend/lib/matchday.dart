import 'package:flutter/material.dart';
import 'dart:ffi';

class GameplanTime {
	DateTime timestamp;
	Uint8 curTime;
	Uint8 curGamepart;
}

class GameQuery {
	String set;
	Group? group;
	Uint8 key;
}

class GamePartPenalty {
	// is used, if people should shoot multiple times / if teams alternate or every penalty of one team is doe after each other
	// e.g. football these would be 0,1,2,3,4 because people cant shoot twice
	// in cycleball 0,1,0,1 because players rotate
	// The values dont actually equal indices
	Uint8 shooting_team; // 0 or 1
	Uint8? shooting_player; // 0,1,2, List<Players>.len
	// String shooting_player_role; //TODO DECIDE add this?
}

class GamePart {
	String name;
	bool repeat;
	bool decider;
	Uint16? length;
	List<GamePartPenalty>? penalties;
}

class GameFormat {
	String name;
	List<GamePart> gameparts;
}

class Goal {
	Player? player;
	GameplanTime time;
}
class Penalty {
	Player shootingPlayer;
	Game game;
	GameplanTime time;
	String type;
}

class Player {
	String name;
	String role;
	Team team;
}
class Team {
	List<Player> players;
	String name;
	String logoURI;
	Color color;
}

class Game {
	String? name;
	Team? t1;
	Team? t2;
	bool missingT1 = false;
	String? missingT1Reason;
	bool missingT2 = false;
	String? missingT2Reason;
	GameQuery? queryT1;
	GameQuery? queryT2;
	List<Goal> goalsT1;
	List<Goal> goalsT2;
	GameFormat format;
	bool needsDecider = false;

	Game(
		String nameT1,
		String nameT2,
		bool? missingT1,
		String? missingT1Reason,
		bool? missingT2,
		String? missingT2Reason,
		String formatName,
		bool? needsDecider,
		Matchday md
	) {
		// TODO good error messages
		t1 = md.stringToTeam(nameT1) ?? (throw Exception("JSON"));
		t2 = md.stringToTeam(nameT2) ?? (throw Exception("JSON"));
		format = md.stringToFormat(formatName) ?? (throw Exception("JSON"));
	}
}

class Group {
	String name;
	List<Team> members;
}

class Matchday {
	// TODO DECIDE how to procede with naming
	Uint8 m_gameI;
	Uint8 m_curGamepart;
	bool m_paused;
	Uint16 m_curTime;
	DateTime m_startTime;
	GameFormat curFormat;

	List<Player> players;
	List<Team> teams;
	List<Game> games;
	List<Group> groups;
	List<GameFormat> formats;
	List<Penalty> cards;

	Player? stringToPlayer(String name) {return null;}
	Team? stringToTeam(String name) {return null;}
	Game? stringToGame(String name) {return null;}
	Group? stringToGroup(String name) {return null;}
	GameFormat? stringToFormat(String name) {return null;}

	Matchday(this.m_gameI, this.m_curGamepart, this.m_paused, this.m_curTime, this.m_startTime, this.teams, this.players, this.games, this.groups, this.formats, this.cards, this.curFormat);
}
