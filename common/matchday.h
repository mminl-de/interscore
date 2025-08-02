#pragma once

#include "../common.h" // TODO

#pragma pack(push, 1)
typedef struct {
	struct {
		Game *game;
		bool halftime;
		bool pause;
		u16 time;
		std::chrono::system_clock::time_point start_time;
	} cur;
	u16 deftime;
	Game *games;
	u8 games_count;
	Team *teams;
	u8 teams_count;
} Matchday;
#pragma pack(pop)

Matchday matchday_init(const char *json);
void matchday_free();
