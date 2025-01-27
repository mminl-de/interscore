/*
Dependencies for compiling:
libwebsockets
json-c
*/

#include <stdbool.h>
#include <libwebsockets.h>
#include <json-c/json.h>

#include "backend.h"

struct Score {
	uint t1;
	uint t2;
};

struct Card {
	uint player_index;
	bool card_type; //0: yellow card, 1: red card
};

struct Player {
	char *name;
	uint team_index;
	bool role; //0: keeper, 1: field
};

struct Team {
	uint keeper_index;
	uint field_index;
	char *name;
	char *logo_filename;
};

struct Game {
	uint t1_index;
	uint t2_index;
	Score halftimescore;
	Score score;
	Card *cards;
	uint cards_count;
};

struct Matchday {
	struct {
		uint gameindex; //index of the current game played in the games array
		bool halftime; //0: first half, 1: second half
		uint time;
	} cur;
	Game *games;
	uint games_count;
	Team *teams;
	uint teams_count;
	Player *players;
	uint players_count;
};

/*
Possible User Actions:
####### Ingame Stuff
- Set Time (DONE)
- Add Time (DONE)
- go a game forward (DONE)
- go a game back (DONE)
- goal Team 1 (DONE)
- goal Team 2 (DONE)
- Yellow Card to Player 1, 2, 3 or 4 (DONE)
- Red Card to Player 1, 2, 3 or 4 (DONE)
## Error Handling
- minus goal team 1 (DONE)
- minus goal team 2 (DONE)
- delete card
####### UI Stuff
- Enable/Disable ==> Ingame Widget
- Start ==> Start of the game/halftime animation
- Enable/Disable ==> Halftime Widget
- enable/Disable ==> Live Table Widget
- Enable/Disable ==> Tunierverlauf Widget
####### Debug Stuff
- Exit
- Write State to JSON?
- Reload JSON
- Print State to Terminal?
- Print Connection State to Terminal?
- Print all possible commands
*/

/* TODO MrMine
- parse input.json
- write input.json
- calculate table
*/

//The default length of every halftime in sec
#define GAME_LENGTH 420

//Define the input characters:
#define SET_TIME 't'

#define ADD_TIME '+'
#define GAME_FORWARD 'n'
#define GAME_BACK 'b'
#define GOAL_TEAM1 '1'
#define GOAL_TEAM2 '2'
#define REMOVE_GOAL_TEAM1 '3'
#define REMOVE_GOAL_TEAM2 '4'
#define YELLOW_CARD 'y'
#define RED_CARD 'r'
#define DELETE_CARD 'c'
// #### UI STUFF
#define TOGGLE_WIDGET_INGAME 'i'
#define START_OF_GAME_ANIMATION_START 's'
#define TOGGLE_WIDGET_HALFTIME 'h'
#define TOGGLE_WIDGET_LIVETABLE 'l'
#define TOGGLE_WIDGET_TUNIERVERLAUF 'v'
// #### Debug Stuff
#define EXIT 'x'
#define RELOAD_JSON 'j'
#define PRINT_HELP '0'

void load_json(Matchday *md, const char *path) {
	//TODO
	return;
}

//Set current_match to first match
void init_matchday(Matchday *md) {
	if(md->games_count == 0){
		printf("There are no games, exiting\n");
		exit(EXIT_FAILURE);
	}
	md->cur.gameindex = 0;
	md->cur.halftime = 0;
	md->cur.time = GAME_LENGTH;
	return;
}


void add_card(Matchday *md, bool card_type) {
	uint ind = md->cur.gameindex;
	if(md->games[ind].cards_count == 0)
		md->games[ind].cards = malloc(1 * sizeof(Card));
	else
		md->games[ind].cards = realloc(md->games[ind].cards, md->games[ind].cards_count+1 * sizeof(Card));
	printf("Select Player: 1. %s (Torwart %s)\n2. %s (Feldspieler %s)\n3. %s (Torwart %s)\n4. %s (Feldspieler %s)\n",
	        md->players[md->teams[md->games[ind].t1_index].keeper_index].name, md->teams[md->games[ind].t1_index].name,
	        md->players[md->teams[md->games[ind].t1_index].field_index].name, md->teams[md->games[ind].t1_index].name,
	        md->players[md->teams[md->games[ind].t2_index].keeper_index].name, md->teams[md->games[ind].t2_index].name,
	        md->players[md->teams[md->games[ind].t2_index].field_index].name, md->teams[md->games[ind].t2_index].name);
	uint player;
	scanf("%ud\n", &player);
	switch(player){
	case 1:
		player = md->teams[md->games[ind].t1_index].keeper_index;
		break;
	case 2:
		player = md->teams[md->games[ind].t1_index].field_index;
		break;
	case 3:
		player = md->teams[md->games[ind].t2_index].keeper_index;
		break;
	case 4:
		player = md->teams[md->games[ind].t2_index].field_index;
		break;
	default:
		printf("Illegal input! Doing nothing");
		return;
	}

	md->games[ind].cards[md->games[ind].cards_count].player_index = player;
	md->games[ind].cards[md->games[ind].cards_count++].card_type = card_type;
	return;
}

int main(void) {
	char *json_path = "input.json";
	Matchday md;
	load_json(&md, json_path);
	init_matchday(&md);

	bool close = false;
	while(close) {
		char c = getchar();
		switch (c) {
		// #### INGAME STUFF
		case SET_TIME:
			uint min, sec;
			printf("current time: %d:%d\nNew Time (in M:SS):", md.cur.time/60, md.cur.time%60);
			scanf("%ud:%ud", &min, &sec);
			md.cur.time = min*60 + sec;
			printf("new current time: %d:%d\n", md.cur.time/60, md.cur.time%60);
			break;
		case ADD_TIME:
			md.cur.time++;
			printf("Added 1, new time: %d:%d\n", md.cur.time/60, md.cur.time%60);
			break;
		case GAME_FORWARD:
			if(md.cur.gameindex == md.games_count){
				printf("already at last game! Doing nothing\n");
				break;
			}
			md.cur.gameindex++;
			md.cur.halftime = 0;
			md.cur.time = GAME_LENGTH;
			printf("New Game: %s : %s", md.teams[md.games[md.cur.gameindex].t1_index].name,
			                            md.teams[md.games[md.cur.gameindex].t2_index].name);
			break;
		case GAME_BACK:
			if(md.cur.gameindex == 0){
				printf("Already at first Game! Doing nothing\n");
				break;
			}
			md.cur.gameindex--;
			md.cur.halftime = 0;
			md.cur.time = GAME_LENGTH;
			printf("New Game: %s : %s", md.teams[md.games[md.cur.gameindex].t1_index].name,
			                            md.teams[md.games[md.cur.gameindex].t2_index].name);
			break;
		case GOAL_TEAM1:
			++md.games[md.cur.gameindex].score.t1;
			printf("New Score: %d : %d\n", md.games[md.cur.gameindex].score.t1, md.games[md.cur.gameindex].score.t2);
			break;
		case GOAL_TEAM2:
			++md.games[md.cur.gameindex].score.t2;
			printf("New Score: %d : %d\n", md.games[md.cur.gameindex].score.t2, md.games[md.cur.gameindex].score.t2);
			break;
		case REMOVE_GOAL_TEAM1:
			--md.games[md.cur.gameindex].score.t1;
			printf("New Score: %d : %d\n", md.games[md.cur.gameindex].score.t1, md.games[md.cur.gameindex].score.t2);
			break;
		case REMOVE_GOAL_TEAM2:
			--md.games[md.cur.gameindex].score.t2;
			printf("New Score: %d : %d\n", md.games[md.cur.gameindex].score.t2, md.games[md.cur.gameindex].score.t2);
			break;
		case YELLOW_CARD:
			add_card(&md, 0);
			break;
		case RED_CARD:
			add_card(&md, 1);
			break;
		case DELETE_CARD:
			uint ind = md.cur.gameindex;
			for(uint i=0; i < md.games[ind].cards_count; i++){
				printf("%d. %s , %s ", i, md.players[md.games[ind].cards[i].player_index].name,
				                          md.teams[md.players[md.games[ind].cards[i].player_index].team_index].name);
				if(md.players[md.games[ind].cards[i].player_index].role == 0)
					printf("(Keeper)\n");
				else
					printf("(field)\n");
			}
			printf("Select a card to delete: ");
			uint c = 0;
			scanf("%ud", &c);
			//Overwrite c with the last element
			md.games[ind].cards[c] = md.games[ind].cards[md.games[ind].cards_count--];
			printf("Cards remaining:\n");
			for(uint i=0; i < md.games[ind].cards_count; i++){
				printf("%d. %s , %s ", i, md.players[md.games[ind].cards[i].player_index].name,
				                          md.teams[md.players[md.games[ind].cards[i].player_index].team_index].name);
				if(md.players[md.games[ind].cards[i].player_index].role == 0)
					printf("(Keeper)\n");
				else
					printf("(field)\n");
			}
			break;
		// #### UI STUFF
		case TOGGLE_WIDGET_INGAME:
		case START_OF_GAME_ANIMATION_START:
		case TOGGLE_WIDGET_HALFTIME:
		case TOGGLE_WIDGET_LIVETABLE:
		case TOGGLE_WIDGET_TUNIERVERLAUF:
		// #### Debug Stuff
		case EXIT:
			close = true;
		case RELOAD_JSON:
		case PRINT_HELP:
		}
	}

    return 0;
}

/* TODO NOTE lws stuff
#include <libwebsockets.h>
#include <string.h>
#include <stdio.h>

static int callback_echo(struct lws *wsi, enum lws_callback_reasons reason, void *user, void *in, size_t len) {
    switch (reason) {
        case LWS_CALLBACK_RECEIVE:
            lws_write(wsi, (unsigned char *)in, len, LWS_WRITE_TEXT);
            break;

        default:
            break;
    }
    return 0;
}

static struct lws_protocols protocols[] = {
    {
        .name = "echo",
        .callback = callback_echo,
        .per_session_data_size = 0,
        .rx_buffer_size = 0,
        .id = 0,
        .user = NULL,
    },
    { NULL, NULL, 0, 0 } // Terminator
};

int main() {
    struct lws_context_creation_info info;
    struct lws_context *context;

    memset(&info, 0, sizeof(info));
    info.port = 9000;
    info.protocols = protocols;

    context = lws_create_context(&info);
    if (!context) {
        printf("lws init failed\n");
        return 1;
    }

    printf("Server running on port 9000...\n");

    while (1) {
        lws_service(context, 100);
    }

    lws_context_destroy(context);
    return 0;
}
*/
