#include <cstdint>
#include <chrono>

typedef int16_t i32;
typedef uint8_t u8;
typedef uint16_t u16;

typedef enum {
	WIDGET_SCOREBOARD_TOGGLE, WIDGET_GAMEPLAN_TOGGLE,
	WIDGET_LIVEPLAN_TOGGLE, WIDGET_GAMESTART_TOGGLE, WIDGET_AD_TOGGLE,

	OBS_STREAM_START, OBS_STREAM_STOP, OBS_REPLAY_START, OBS_REPLAY_ABORT,

	T1_GOAL_ADD, T1_GOAL_REMOVE, T2_GOAL_ADD, T2_GOAL_REMOVE,

	GAME_NEXT, GAME_PREV, GAME_SWITCH_SIDES,

	TIME_PLUS_1S, TIME_MINUS_1S, TIME_PLUS_20S, TIME_MINUS_20S,
	TIME_PAUSE_TOGGLE, TIME_RESET,

	DEAL_YELLOW_CARD, DEAL_RED_CARD
} Signal;

typedef struct Team Team;
typedef struct Player Player;
typedef struct { u16 h; u8 s, b; } HSB;
typedef struct { u8 s1, s2; } Score;
typedef enum { CARD_YELLOW, CARD_RED } CardType;

typedef struct {
	Player *player;
	CardType type;
} Card;

struct Player {
	char *name;
	Team *team;
	char *role;
};

struct Team {
	char *name;
	Player *players;
	u8 players_count;
	HSB color;
	char *logo_path;
};

struct Game {
	Team *t1;
	Team *t2;
	Score halftimescore;
	Score score;
	Card *cards;
	u8 cards_count;
	u8 replays_count;
};

typedef struct {
	struct {
		Game *game;
		bool halftime;
		bool pause;
		u16 time;
		std::chrono start_time;
	} cur;
	u16 deftime;
	Game *games;
	u8 games_count;
	Team *teams;
	u8 teams_count;
} Matchday;
