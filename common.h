#ifndef _COMMON_H_
#define _COMMON_H_

#include <stdio.h>
#include <time.h>

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;

enum CardType { YELLOW, RED };
enum PlayerRole { KEEPER, FIELD };
enum InputType {
	T1_SCORE_PLUS, T1_SCORE_MINUS, T2_SCORE_PLUS, T2_SCORE_MINUS,
	GAME_NEXT, GAME_PREV, GAME_SWITCH_SIDES,
	TIME_PLUS, TIME_MINUS, TIME_PLUS_20, TIME_MINUS_20,
	TIME_TOGGLE_PAUSE, TIME_RESET
};

#pragma pack(push, 1)
typedef struct {
	u8 t1;
	u8 t2;
} Score;

typedef struct {
	u8 player_index;
	enum CardType card_type;
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
	char *logo_filename;
	char *color_light;
	char *color_dark;
} Team;

typedef struct {
	u8 t1_index;
	u8 t2_index;
	Score halftimescore;
	Score score;
	Card *cards;
	u8 cards_count;
} Game;

typedef struct {
	struct {
		u8 gameindex; // index of the current game played in the games array.
		bool halftime; // 0: first half, 1: second half
		bool pause;
		u16 time;
		time_t timestart;
	} cur;
	u16 deftime;
	Game *games;
	u8 games_count;
	Team *teams;
	u8 teams_count;
	Player *players;
	u8 players_count;
} Matchday;
#pragma pack(pop)

void matchday_init();
void matchday_free();
int player_index(const char *name);
int team_index(const char *name);
char *json_generate();
void json_load(const char *path);
char *file_read(const char *path);
bool file_write(const char *path, const char *s);
void merge_sort(void *base, size_t num, size_t size, int (*compar)(const void *, const void *));
char *gettimems();

#endif // _COMMON_H_
