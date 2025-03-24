typedef enum { CARD_YELLOW, CARD_RED } CardType;
typedef enum PlayerRole { KEEPER, FIELD } PlayerRole;
enum InputType {
        WIDGET_SCOREBOARD_TOGGLE, WIDGET_GAMEPLAN_TOGGLE,
        WIDGET_LIVEPLAN_TOGGLE, WIDGET_GAMESTART_TOGGLE, WIDGET_AD_TOGGLE,
        OBS_STREAM_START, OBS_STREAM_STOP, OBS_REPLAY_START, OBS_REPLAY_STOP,
        T1_SCORE_PLUS, T1_SCORE_MINUS, T2_SCORE_PLUS, T2_SCORE_MINUS,
        GAME_NEXT, GAME_PREV, GAME_SWITCH_SIDES,
        TIME_PLUS, TIME_MINUS, TIME_PLUS_20, TIME_MINUS_20,
        TIME_TOGGLE_PAUSE, TIME_RESET, YELLOW_CARD, RED_CARD
};

typedef struct {
        u16 h;
        u8 s;
        u8 b;
} HSB;

typedef struct {
        u8 t1;
        u8 t2;
} Score;

typedef struct {
		Player *player;
        CardType card_type;
} Card;

typedef struct {
        char *name;
		Team *team;
        enum PlayerRole role;
} Player;

typedef struct {
        char *name;
		Player *players;
		u8 players_count;
        HSB color;
        char *logo_path;
} Team;

typedef struct {
		Team *t1;
		Team *t2;
        Score halftimescore;
        Score score;
        Card *cards;
        u8 cards_count;
        u8 replays_count;
} Game;

typedef struct {
        struct {
				Game *game;
                bool halftime; // 0: first half, 1: second half
                bool pause;
                u16 time;
                chrono_t? timestart;
        } cur;
        u16 deftime;
        Game *games;
        u8 games_count;
        Team *teams;
        u8 teams_count;
} Matchday;
