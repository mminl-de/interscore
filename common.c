#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

#include <json-c/json.h>
#include <json-c/json_object.h>

#include "config.h"
#include "common.h"

extern Matchday md;

//Set current_match to first match and 0-initialize every game
void matchday_init() {
	if (md.games_count == 0) {
		printf("There are no games, exiting\n");
		exit(EXIT_FAILURE);
	}
	md.cur.gameindex = 0;
	md.cur.halftime = 0;
	md.cur.pause = true;
	md.cur.time = GAME_LENGTH;
	for (u8 i = 0; i < md.games_count; i++) {
		md.games[i].halftimescore.t1 = 0;
		md.games[i].halftimescore.t2 = 0;
		md.games[i].score.t1 = 0;
		md.games[i].score.t2 = 0;
		md.games[i].cards_count = 0;
		md.games[i].cards = NULL;
	}
}

void matchday_free() {
	for(int i=0; i < md.games_count; i++)
		if(md.games[i].cards_count > 0)
			free(md.games[i].cards);
	for(int i=0; i < md.players_count; i++)
		free(md.players[i].name);
	if(md.players_count > 0)
		free(md.players);
	if(md.games_count > 0)
		free(md.games);
	for(int i=0; i < md.teams_count; i++){
		free(md.teams[i].name);
		free(md.teams[i].logo_filename);
		free(md.teams[i].color_light);
		free(md.teams[i].color_dark);
	}
	if(md.teams_count > 0)
		free(md.teams);
}

// Return the index of a players name.
// If the name does not exist, return -1.
int player_index(const char *name) {
	for (u8 i = 0; i < md.players_count; i++)
		if (!strcmp(md.players[i].name, name))
			return i;
	return -1;
}

// Return the index of a team name.
// If the name does not exist return -1.
int team_index(const char *name) {
	for (u8 i = 0; i < md.teams_count; i++)
		if (!strcmp(md.teams[i].name, name))
			return i;
	return -1;
}

const char* json_generate() {
	struct json_object *root = json_object_new_object();
	struct json_object *teams = json_object_new_array();
	struct json_object *games = json_object_new_array();
	for(int i=0; i < md.teams_count; i++){
		struct json_object *team = json_object_new_object();
		json_object_object_add(team, "logo", json_object_new_string(md.teams[i].logo_filename));
		json_object_object_add(team, "color_light", json_object_new_string(md.teams[i].color_light));
		json_object_object_add(team, "color_dark", json_object_new_string(md.teams[i].color_dark));
		struct json_object *keeper = json_object_new_object();
		json_object_object_add(keeper, "name", json_object_new_string(md.players[md.teams[i].keeper_index].name));
		json_object_object_add(team, "keeper", keeper);
		struct json_object *field = json_object_new_object();
		json_object_object_add(field, "name", json_object_new_string(md.players[md.teams[i].field_index].name));
		json_object_object_add(team, "field", field);
		json_object_array_add(teams, team);
	}
	for(int i=0; i < md.games_count; i++){
		struct json_object *game = json_object_new_object();
		json_object_object_add(game, "team1", json_object_new_string(md.teams[md.games[i].t1_index].name));
		json_object_object_add(game, "team2", json_object_new_string(md.teams[md.games[i].t2_index].name));
		struct json_object *halftimescore = json_object_new_object();
		json_object_object_add(halftimescore, "team1", json_object_new_int(md.games[i].halftimescore.t1));
		json_object_object_add(halftimescore, "team2", json_object_new_int(md.games[i].halftimescore.t2));
		json_object_object_add(game, "halftimescore", halftimescore);
		struct json_object *score = json_object_new_object();
		json_object_object_add(score, "team1", json_object_new_int(md.games[i].score.t1));
		json_object_object_add(score, "team2", json_object_new_int(md.games[i].score.t2));
		json_object_object_add(game, "score", score);

		if(md.games[i].cards_count > 0){
			struct json_object *cards = json_object_new_object();
			for(int j=0; j < md.games[j].cards_count; j++){
				struct json_object *card = json_object_new_object();
				json_object_object_add(card, "player", json_object_new_string(md.players[md.games[i].cards[j].player_index].name));
				if(md.games[i].cards[j].card_type == 0)
					json_object_object_add(card, "type", json_object_new_string("Y"));
				else
					json_object_object_add(card, "type", json_object_new_string("R"));
				json_object_object_add(cards, "card", card);
			}
			json_object_object_add(game, "cards", cards);
		}
		json_object_array_add(games, game);
	}
	json_object_object_add(root, "teams", teams);
	json_object_object_add(root, "games", games);
	const char *str = json_object_to_json_string_ext(root, JSON_C_TO_STRING_PRETTY);
	return str;
}

void json_load(const char *path) {
	// First convert path to actual string containing whole file
	FILE *f = fopen(path, "rb");
	if (f == NULL) {
		printf("Json Input file is not available! Exiting...\n");
		exit(EXIT_FAILURE);
	}
	// seek to end to find length, then reset to the beginning
	fseek(f, 0, SEEK_END);
	u32 file_size = ftell(f);
	rewind(f);

	char *filestring = (char *) malloc((file_size + 1) * sizeof(char));
	if (filestring == NULL) {
		printf("Not enough memory for loading json! Exiting...\n");
		fclose(f);
		exit(EXIT_FAILURE);
	}

	u32 chars_read = fread(filestring, sizeof(char), file_size, f);
	if (chars_read != file_size) {
		printf("Could not read whole json file! Exiting...");
		free(filestring);
		fclose(f);
		exit(EXIT_FAILURE);
	}
	filestring[file_size] = '\0';
	fclose(f);

	// Then split json into teams and games
	struct json_object *root = json_tokener_parse(filestring);
	free(filestring);
	struct json_object *teams = json_object_new_array();
	struct json_object *games = json_object_new_array();
	json_object_object_get_ex(root, "teams", &teams);
	json_object_object_get_ex(root, "games", &games);

	md.teams_count = json_object_array_length(teams);
	md.teams = (Team *) malloc(md.teams_count * sizeof(Team));

	md.players_count = md.teams_count*2;
	md.players = (Player *) malloc(md.players_count * sizeof(Player));

	// Read all the teams
	for(int i=0; i < md.teams_count; i++){
		json_object *team, *logo, *players, *name, *color, *position;
		team = json_object_array_get_idx(teams, i);
		json_object_object_get_ex(team, "name", &name);
		md.teams[i].name = (char *) malloc(strlen(json_object_get_string(name)) * sizeof(char));
		strcpy(md.teams[i].name, json_object_get_string(name));

		json_object_object_get_ex(team, "logo", &logo);
		md.teams[i].logo_filename = (char *) malloc(strlen(json_object_get_string(logo)) * sizeof(char));
		strcpy(md.teams[i].logo_filename, json_object_get_string(logo));

		json_object_object_get_ex(team, "players", &players);
		for(int j=0; j < json_object_array_length(players); j++){
			json_object *player = json_object_array_get_idx(players, j);
			json_object_object_get_ex(player, "name", &name);
			md.players[i*2+j].name = (char *) malloc(strlen(json_object_get_string(name)) * sizeof(char));
			strcpy(md.players[i*2+j].name, json_object_get_string(name));
			md.players[i*2+j].team_index = i;
			json_object_object_get_ex(player, "position", &position);
			if(!strcmp(json_object_get_string(position), "keeper")){
				md.players[i*2+j].role = KEEPER;
				md.teams[i].keeper_index = i*2+j;

			} else if(!strcmp(json_object_get_string(position), "field")){
				md.players[i*2+j].role = FIELD;
				md.teams[i].field_index = i*2+j;
			} else {
				printf("ERROR parsing JSON: Unknown Position: %s. Exiting...", json_object_get_string(position));
				exit(EXIT_FAILURE);
			}
		}

		json_object_object_get_ex(team, "color_light", &color);
		md.teams[i].color_light = (char *) malloc(strlen(json_object_get_string(color)) *sizeof(char));
		strcpy(md.teams[i].color_light, json_object_get_string(color));

		json_object_object_get_ex(team, "color_dark", &color);
		md.teams[i].color_dark = (char *) malloc(strlen(json_object_get_string(color)) *sizeof(char));
		strcpy(md.teams[i].color_dark, json_object_get_string(color));
	}

	md.games_count = json_object_array_length(games);
	md.games = (Game *) malloc(md.games_count * sizeof(Game));

	for(int i=0; i < md.games_count; i++){
		json_object *team, *game;
		game = json_object_array_get_idx(games, i);
		json_object_object_get_ex(game, "team1", &team);
		if (team_index(json_object_get_string(team)) == -1) {
			printf("Erorr parsing JSON: '%s' does not exist (teamname of Team 1 in Game %d). Exiting...\n", json_object_get_string(team), i + 1);
			exit(EXIT_FAILURE);
		}
		md.games[i].t1_index = team_index(json_object_get_string(team));

		json_object_object_get_ex(game, "team2", &team);
		if (team_index(json_object_get_string(team)) == -1) {
			printf("Erorr parsing JSON: '%s' does not exist (teamname of Team 2 in Game %d). Exiting...\n", json_object_get_string(team), i + 1);
			exit(EXIT_FAILURE);
		}
		md.games[i].t2_index = team_index(json_object_get_string(team));

		json_object *halftimescore, *score, *cards, *var;
		if (json_object_object_get_ex(game, "halftimescore", &halftimescore)) {
			json_object_object_get_ex(halftimescore, "team1", &var);
			md.games[i].halftimescore.t1 = json_object_get_int(var);
			json_object_object_get_ex(halftimescore, "team2", &var);
			md.games[i].halftimescore.t2 = json_object_get_int(var);
		}
		if (json_object_object_get_ex(game, "score", &score)) {
			json_object_object_get_ex(score, "team1", &var);
			md.games[i].score.t1 = json_object_get_int(var);
			json_object_object_get_ex(score, "team2", &var);
			md.games[i].score.t2 = json_object_get_int(var);
		}
		if (json_object_object_get_ex(game, "cards", &cards)) {

			md.games[i].cards_count = json_object_array_length(cards);
			md.games[i].cards = (Card *) malloc(md.games[i].cards_count * sizeof(Card));

			for(int j=0; j < md.games[i].cards_count; j++){
				json_object *player, *type, *card;
				card = json_object_array_get_idx(cards, j);
				json_object_object_get_ex(card, "player", &player);
				if (player_index(json_object_get_string(player)) == -1) {
					printf("Erorr parsing JSON: '%s' does not exist (Playername of Card %d in Game %d). Exiting...\n", json_object_get_string(player), j+1, i + 1);
					exit(EXIT_FAILURE);
				}
				md.games[i].cards[j].player_index = player_index(json_object_get_string(player));

				json_object_object_get_ex(card, "type", &type);
				if(strcmp(json_object_get_string(type), "Y"))
					md.games[i].cards[j].card_type = YELLOW;
				else if(strcmp(json_object_get_string(type), "R"))
					md.games[i].cards[j].card_type = RED;
			}
		}
	}
	return;
}
