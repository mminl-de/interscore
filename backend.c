/*
Dependencies for compiling:
libwebsockets
json-c
*/

#include <json-c/json_object.h>
#include <stdbool.h>
#include <libwebsockets.h>
#include <json-c/json.h>
#include <time.h>

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
- delete card (DONE)
####### UI Stuff
- Enable/Disable ==> Ingame Widget
- Start ==> Start of the game/halftime animation
- Enable/Disable ==> Halftime Widget
- enable/Disable ==> Live Table Widget
- Enable/Disable ==> Tunierverlauf Widget
####### Debug Stuff
- Exit (DONE)
- Write State to JSON?
- Reload JSON
- Print State to Terminal?
- Print Connection State to Terminal?
- Print all possible commands
- Print current Gamestate
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


Matchday md;

//return the index of a players name
//if the name does not exist return -1
int player_index(const char *name){
	for(uint i=0; i < md.players_count; i++)
		if(strcmp(md.players[i].name, name) == 0)
			return i;
	return -1;
}

//return the index of a team name
//if the name does not exist return -1
int team_index(const char *name){
	for(uint i=0; i < md.teams_count; i++)
		if(strcmp(md.teams[i].name, name) == 0)
			return i;
	return -1;
}

void load_json(const char *path) {
	//First convert path to actual string containing whole file
	FILE *f = fopen(path, "rb");
	if(f == NULL){
		printf("Json Input file is not available! Exiting...\n");
		exit(EXIT_FAILURE);
	}
	//seek to end to find length, then reset to the beginning
	fseek(f, 0, SEEK_END);
	long file_size = ftell(f);
	rewind(f);

	char *filestring = malloc((file_size + 1) * sizeof(char));
	if(filestring == NULL){
		printf("Not enough memory for loading json! Exiting...\n");
		fclose(f);
		exit(EXIT_FAILURE);
	}

	long chars_read = fread(filestring, sizeof(char), file_size, f);
	if(chars_read != file_size){
		printf("Could not read whole json file! Exiting...");
		free(filestring);
		fclose(f);
		exit(EXIT_FAILURE);
	}
	filestring[file_size] = '\0';
	fclose(f);

	//Then split json into teams and games
	struct json_object *root = json_tokener_parse(filestring);
	free(filestring);
	struct json_object *teams = json_object_new_object();
	struct json_object *games = json_object_new_object();
	json_object_object_get_ex(root, "teams", &teams);
	json_object_object_get_ex(root, "games", &games);

	md.teams_count = json_object_object_length(teams);
	md.teams = malloc(md.teams_count * sizeof(Team));

	md.players_count = md.teams_count*2;
	md.players = malloc(md.players_count * sizeof(Player));

	//read all the teams
	uint i=0;
	json_object_object_foreach(teams, teamname, teamdata){
		md.teams[i].name = teamname;
		json_object *logo, *keeper, *field, *name;

		json_object_object_get_ex(teamdata, "logo", &logo);
		md.teams[i].logo_filename = malloc(strlen(json_object_get_string(logo)) * sizeof(char));
		strcpy(md.teams[i].logo_filename, json_object_get_string(logo));

		json_object_object_get_ex(teamdata, "keeper", &keeper);
		json_object_object_get_ex(keeper, "name", &name);
		md.players[i*2].name = malloc(strlen(json_object_get_string(name)) * sizeof(char));
		strcpy(md.players[i*2].name, json_object_get_string(name));
		md.players[i*2].team_index = i;
		md.players[i*2].role = 0;
		md.teams[i].keeper_index = i*2;


		json_object_object_get_ex(teamdata, "field", &field);
		json_object_object_get_ex(field, "name", &name);
		md.players[i*2+1].name = malloc(strlen(json_object_get_string(name)) * sizeof(char));
		strcpy(md.players[i*2+1].name, json_object_get_string(name));
		md.players[i*2+1].team_index = i;
		md.players[i*2+1].role = 1;
		md.teams[i].field_index = i*2+1;

		i++;
	}

	md.games_count = json_object_object_length(games);
	md.games = malloc(md.games_count * sizeof(Game));

	i=0;
	json_object_object_foreach(games, gamenumber, gamedata){
		json_object *team;
		json_object_object_get_ex(gamedata, "team1", &team);
		if(team_index(json_object_get_string(team)) == -1){
			printf("Erorr parsing JSON: '%s' does not exist (teamname of Team 1 in Game %d). Exiting...\n", json_object_get_string(team), i+1);
			exit(EXIT_FAILURE);
		}
		md.games[i].t1_index = team_index(json_object_get_string(team));

		json_object_object_get_ex(gamedata, "team2", &team);
		if(team_index(json_object_get_string(team)) == -1){
			printf("Erorr parsing JSON: '%s' does not exist (teamname of Team 2 in Game %d). Exiting...\n", json_object_get_string(team), i+1);
			exit(EXIT_FAILURE);
		}
		md.games[i].t2_index = team_index(json_object_get_string(team));
		json_object *halftimescore, *score, *cards, *var;
		if(json_object_object_get_ex(gamedata, "halftimescore", &halftimescore)){
			json_object_object_get_ex(halftimescore, "team1", &var);
			md.games[i].halftimescore.t1 = json_object_get_int(var);
			json_object_object_get_ex(halftimescore, "team2", &var);
			md.games[i].halftimescore.t2 = json_object_get_int(var);
		}
		if(json_object_object_get_ex(gamedata, "score", &score)){
			json_object_object_get_ex(score, "team1", &var);
			md.games[i].score.t1 = json_object_get_int(var);
			json_object_object_get_ex(score, "team2", &var);
			md.games[i].score.t2 = json_object_get_int(var);
		}
		if(json_object_object_get_ex(gamedata, "cards", &cards)){

			md.games[i].cards_count = json_object_object_length(cards);
			md.games[i].cards = malloc(md.games[i].cards_count * sizeof(Card));

			uint j=0;
			json_object_object_foreach(cards, cardname, carddata){
				json_object *player, *type;
				json_object_object_get_ex(carddata, "player", &player);
				if(player_index(json_object_get_string(player)) == -1){
					printf("Erorr parsing JSON: '%s' does not exist (Playername of Card %d in Game %d). Exiting...\n", json_object_get_string(player), j+1, i+1);
				}
				md.games[i].cards[j].player_index = player_index(json_object_get_string(player));

				json_object_object_get_ex(carddata, "type", &type);
				md.games[i].cards[j].card_type = json_object_get_boolean(type);
				j++;
			}
		}
		i++;
	}

	return;
}

//Set current_match to first match
void init_matchday() {
	if(md.games_count == 0){
		printf("There are no games, exiting\n");
		exit(EXIT_FAILURE);
	}
	md.cur.gameindex = 0;
	md.cur.halftime = 0;
	md.cur.time = GAME_LENGTH;
	for(uint i=0; i < md.games_count; i++){
		md.games[i].halftimescore.t1 = 0;
		md.games[i].halftimescore.t2 = 0;
		md.games[i].score.t1 = 0;
		md.games[i].score.t2 = 0;
		md.games[i].cards_count = 0;
		md.games[i].cards = NULL;
	}
	return;
}


void add_card(bool card_type) {
	uint ind = md.cur.gameindex;
	if(md.games[ind].cards_count == 0)
		md.games[ind].cards = malloc(1 * sizeof(Card));
	else 
		md.games[ind].cards = realloc(md.games[ind].cards, (md.games[ind].cards_count+1) * sizeof(Card));
	printf("Select Player:\n1. %s (Keeper %s)\n2. %s (Field %s)\n3. %s (Keeper %s)\n4. %s (Field %s)\n",
	        md.players[md.teams[md.games[ind].t1_index].keeper_index].name, md.teams[md.games[ind].t1_index].name,
	        md.players[md.teams[md.games[ind].t1_index].field_index].name, md.teams[md.games[ind].t1_index].name,
	        md.players[md.teams[md.games[ind].t2_index].keeper_index].name, md.teams[md.games[ind].t2_index].name,
	        md.players[md.teams[md.games[ind].t2_index].field_index].name, md.teams[md.games[ind].t2_index].name);
	uint player;
	scanf("%ud\n", &player);
	switch(player){
	case 1:
		player = md.teams[md.games[ind].t1_index].keeper_index;
		break;
	case 2:
		player = md.teams[md.games[ind].t1_index].field_index;
		break;
	case 3:
		player = md.teams[md.games[ind].t2_index].keeper_index;
		break;
	case 4:
		player = md.teams[md.games[ind].t2_index].field_index;
		break;
	default:
		printf("Illegal input! Doing nothing");
		return;
	}

	md.games[ind].cards[md.games[ind].cards_count].player_index = player;
	md.games[ind].cards[md.games[ind].cards_count++].card_type = card_type;
	return;
}

int main(void) {
	char *json_path = "input.json";
	load_json(json_path);
	init_matchday();

	bool close = false;
	while(!close) {
		char c = getchar();
		switch (c) {
		// #### INGAME STUFF
		case SET_TIME:
			uint min, sec;
			printf("current time: %d:%2d\nNew Time (in M:SS): ", md.cur.time/60, md.cur.time%60);
			scanf("%d:%d", &min, &sec); //TODO fix this, %ud breaks sec input
			md.cur.time = min*60 + sec;
			printf("new current time: %d:%2d\n", md.cur.time/60, md.cur.time%60);
			break;
		case ADD_TIME:
			md.cur.time++;
			printf("Added 1, new time: %d:%d\n", md.cur.time/60, md.cur.time%60);
			break;
		case GAME_FORWARD:
			if(md.cur.gameindex == md.games_count - 1){
				printf("already at last game! Doing nothing\n");
				break;
			}
			md.cur.gameindex++;
			md.cur.halftime = 0;
			md.cur.time = GAME_LENGTH;
			printf("New Game (%d.): %s : %s\n", md.cur.gameindex+1, md.teams[md.games[md.cur.gameindex].t1_index].name,
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
			printf("New Game (%d.): %s : %s\n", md.cur.gameindex+1, md.teams[md.games[md.cur.gameindex].t1_index].name,
			                            md.teams[md.games[md.cur.gameindex].t2_index].name);
			break;
		case GOAL_TEAM1:
			++md.games[md.cur.gameindex].score.t1;
			printf("New Score: %d : %d\n", md.games[md.cur.gameindex].score.t1, md.games[md.cur.gameindex].score.t2);
			break;
		case GOAL_TEAM2:
			++md.games[md.cur.gameindex].score.t2;
			printf("New Score: %d : %d\n", md.games[md.cur.gameindex].score.t1, md.games[md.cur.gameindex].score.t2);
			break;
		case REMOVE_GOAL_TEAM1:
			if(md.games[md.cur.gameindex].score.t1 > 0)
				--md.games[md.cur.gameindex].score.t1;
			printf("New Score: %d : %d\n", md.games[md.cur.gameindex].score.t1, md.games[md.cur.gameindex].score.t2);
			break;
		case REMOVE_GOAL_TEAM2:
			if(md.games[md.cur.gameindex].score.t2 > 0)
				--md.games[md.cur.gameindex].score.t2;
			printf("New Score: %d : %d\n", md.games[md.cur.gameindex].score.t1, md.games[md.cur.gameindex].score.t2);
			break;
		case YELLOW_CARD:
			add_card(0);
			break;
		case RED_CARD:
			add_card(1);
			break;
		case DELETE_CARD:
			uint ind = md.cur.gameindex;
			for(uint i=0; i < md.games[ind].cards_count; i++){
				printf("%d. ", i+1);
				if(md.games[ind].cards[i].card_type == 0)
					printf("Y ");
				else
					printf("R ");
				printf("%s , %s ", md.players[md.games[ind].cards[i].player_index].name,
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
			md.games[ind].cards[c-1] = md.games[ind].cards[--md.games[ind].cards_count];
			printf("Cards remaining:\n");
			for(uint i=0; i < md.games[ind].cards_count; i++){
				printf("%d. ", i+1);
				if(md.games[ind].cards[i].card_type == 0)
					printf("Y ");
				else
					printf("R ");
				printf("%s , %s ", md.players[md.games[ind].cards[i].player_index].name,
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
