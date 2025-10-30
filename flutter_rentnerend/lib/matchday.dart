import 'dart:ffi';

class Team {}
class Player {}
class Game {}
class Group {}

class Matchday {
	// TODO DECIDE how to procede with naming
	Uint16 m_gameLen;
	Uint8 m_gameI;
	bool m_halftime;
	bool m_paused;
	Uint16 m_curTime;
	DateTime m_startTime;

	List<Team> teams;
	List<Player> players;
	List<Game> games;
	List<Group> groups;

	Matchday(this.m_gameLen, this.m_gameI, this.m_halftime, this.m_paused, this.m_curTime, this.m_startTime, this.teams, this.players, this.games, this.groups);
}
