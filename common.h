#ifndef _COMMON_H_
#define _COMMON_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>
#include <time.h>

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef int i32;

enum PlayerRole { KEEPER, FIELD };

// This define just wipes the export making the num definition C and C++ legal
// while TypeScript can just use the file. This way we only have to keep track
// of one enum definition instead of 3.
#define export
#include "MessageType.ts"
#undef export

#pragma pack(push, 1)
typedef struct {
	u8 t1;
	u8 t2;
} Score;

typedef struct {
	u8 player_index;
	char *type;
} Card;

typedef struct {
	char *name;
	u8 team_index;
	enum PlayerRole role;
} Player;

typedef struct {
	u8 keeper_index;
	u8 field_index;
	char *name;
	char *logo_path;
	char *color;
} Team;

typedef struct {
	u8 t1_index;
	u8 t2_index;
	Score halftime_score;
	Score score;
	Card *cards;
	u8 cards_count;
	u8 replays_count;
} Game;

typedef struct {
	struct {
		u16 game_len;
		u8 game_i; // index of the current game played in the games array.
		bool halftime; // 0: first half, 1: second half
		bool paused;
		u16 cur_time;
		time_t start_time;
	} meta;
	Team *teams;
	u8 teams_count;
	Player *players;
	u8 players_count;
	Game *games;
	u8 games_count;
} Matchday;
#pragma pack(pop)

void matchday_init();
void matchday_free();
int player_index(const char *name);
int team_index(const char *name);
char *json_generate();
void common_json_load_from_string(const char *path);
char *common_read_file(const char *path);
bool file_write(const char *path, const char *s);
char *gettimems();
u8 add_card(char *type, u8 player_index);


#ifdef __cplusplus
}
#endif

#endif // _COMMON_H_
