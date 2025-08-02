#include <json-c/json.h>
#include <stdio.h>
#include <string.h>
#include "matchday.h"

void matchday_init(const char *json) {
	Matchday result;

	// Then split json into teams and games
	struct json_object *root = json_tokener_parse(s);

	struct json_object *time = json_object_new_object();
	json_object_object_get_ex(root, "time", &time);
	result.deftime = json_object_get_int(time);

	struct json_object *teams = json_object_new_array();
	struct json_object *games = json_object_new_array();
	json_object_object_get_ex(root, "teams", &teams);
	json_object_object_get_ex(root, "games", &games);

	result.teams_count = json_object_array_length(teams);
	//Add decoy team for the decoy game at the end
	result.teams = (Team *) malloc((result.teams_count+1) * sizeof(Team));

	// TODO REMOVE
	//md.players_count = result.teams_count*2;
	//md.players = (Player *) malloc(md.players_count * sizeof(Player));

	// Read all the teams
	for(int i=0; i < result.teams_count; i++){
		json_object *team, *logo, *players, *name, *color, *position;
		team = json_object_array_get_idx(teams, i);
		json_object_object_get_ex(team, "name", &name);
		result.teams[i].name = (char *) malloc(strlen(json_object_get_string(name)) * sizeof(char));
		strcpy(result.teams[i].name, json_object_get_string(name));

		json_object_object_get_ex(team, "logo", &logo);
		// TODO REMOVE
		//result.teams[i].logo_filename = (char *) malloc(strlen(json_object_get_string(logo)) * sizeof(char));
		//strcpy(result.teams[i].logo_filename, json_object_get_string(logo));

		json_object_object_get_ex(team, "players", &players);
		for(int j=0; j < json_object_array_length(players); j++){
			json_object *player = json_object_array_get_idx(players, j);
			json_object_object_get_ex(player, "name", &name);
			// TODO REMOVE
			//result.players[i*2+j].name = (char *) malloc(strlen(json_object_get_string(name)) * sizeof(char));
			//strcpy(result.players[i*2+j].name, json_object_get_string(name));
			//result.players[i*2+j].team_index = i;
			json_object_object_get_ex(player, "position", &position);
			if(!strcmp(json_object_get_string(position), "keeper")){
				// TODO REMOVE
				//result.players[i*2+j].role = KEEPER;
				//result.teams[i].keeper_index = i*2+j;

			// TODO REMOVE
			//} else if(!strcmp(json_object_get_string(position), "field")){
			//	result.players[i*2+j].role = FIELD;
			//	result.teams[i].field_index = i*2+j;
			} else {
				printf("ERROR parsing JSON: Unknown Position: %s. Exiting...", json_object_get_string(position));
				exit(EXIT_FAILURE);
			}
		}

		json_object_object_get_ex(team, "color_light", &color);
		// TODO REMOVE
		//result.teams[i].color_light = (char *) malloc(strlen(json_object_get_string(color)) *sizeof(char));
		//strcpy(result.teams[i].color_light, json_object_get_string(color));

		json_object_object_get_ex(team, "color_dark", &color);
		// TODO REMOVE
		//result.teams[i].color_dark = (char *) malloc(strlen(json_object_get_string(color)) *sizeof(char));
		//strcpy(result.teams[i].color_dark, json_object_get_string(color));
	}
	//Add a decoy team thats like team 0 but with the name "ENDE". Its used in the decoy game at the end
	result.teams[result.teams_count].name = malloc(5 * sizeof(char));
	strcpy(result.teams[result.teams_count].name, "ENDE");
	// TODO REMOVE
	//result.teams[result.teams_count].color_dark = result.teams[0].color_dark;
	//result.teams[result.teams_count].color_light = result.teams[0].color_light;
	//result.teams[result.teams_count].field_index = result.teams[0].field_index;
	//result.teams[result.teams_count].keeper_index = result.teams[0].keeper_index;
	//result.teams[result.teams_count].logo_filename = result.teams[0].logo_filename;

	result.games_count = json_object_array_length(games);
	// We alloc one game more, because its a filler game for the end
	// TODO REMOVE md.games = (Game *) malloc((md.games_count+1) * sizeof(Game));

	for(int i=0; i < result.games_count; i++){
		json_object *team, *game;
		game = json_object_array_get_idx(games, i);
		json_object_object_get_ex(game, "team1", &team);
		if (team_index(json_object_get_string(team)) == -1) {
			printf("Erorr parsing JSON: '%s' does not exist (teamname of Team 1 in Game %d). Exiting...\n", json_object_get_string(team), i + 1);
			exit(EXIT_FAILURE);
		}
		result.games[i].t1_index = team_index(json_object_get_string(team));

		json_object_object_get_ex(game, "team2", &team);
		if (team_index(json_object_get_string(team)) == -1) {
			printf("Erorr parsing JSON: '%s' does not exist (teamname of Team 2 in Game %d). Exiting...\n", json_object_get_string(team), i + 1);
			exit(EXIT_FAILURE);
		}
		result.games[i].t2_index = team_index(json_object_get_string(team));

		json_object *halftimescore, *score, *cards, *var;
		if (json_object_object_get_ex(game, "halftimescore", &halftimescore)) {
			json_object_object_get_ex(halftimescore, "team1", &var);
			result.games[i].halftimescore.t1 = json_object_get_int(var);
			json_object_object_get_ex(halftimescore, "team2", &var);
			result.games[i].halftimescore.t2 = json_object_get_int(var);
		}
		if (json_object_object_get_ex(game, "score", &score)) {
			json_object_object_get_ex(score, "team1", &var);
			result.games[i].score.t1 = json_object_get_int(var);
			json_object_object_get_ex(score, "team2", &var);
			result.games[i].score.t2 = json_object_get_int(var);
		}

		if (json_object_object_get_ex(game, "cards", &cards)) {

			result.games[i].cards_count = json_object_array_length(cards);
			result.games[i].cards = (Card *) malloc(result.games[i].cards_count * sizeof(Card));

			for(int j=0; j < result.games[i].cards_count; j++){
				json_object *player, *type, *card;
				card = json_object_array_get_idx(cards, j);
				json_object_object_get_ex(card, "player", &player);
				if (player_index(json_object_get_string(player)) == -1) {
					printf("Erorr parsing JSON: '%s' does not exist (Playername of Card %d in Game %d). Exiting...\n", json_object_get_string(player), j+1, i + 1);
					exit(EXIT_FAILURE);
				}
				result.games[i].cards[j].player_index = player_index(json_object_get_string(player));

				json_object_object_get_ex(card, "type", &type);
				if(strcmp(json_object_get_string(type), "Y"))
					md.games[i].cards[j].card_type = YELLOW;
				else if(strcmp(json_object_get_string(type), "R"))
					md.games[i].cards[j].card_type = RED;
			}
		}
	}
	//Init Decoy-Game at the End
	result.games[result.games_count].t1_index = result.teams_count;
	result.games[result.games_count].t2_index = result.teams_count;
	result.games[result.games_count].cards = NULL;
	result.games[result.games_count].cards_count = 0;
	result.games[result.games_count].score.t1 = 0;
	result.games[result.games_count].score.t2 = 0;
	result.games[result.games_count].halftimescore.t1 = 0;
	result.games[result.games_count].halftimescore.t2 = 0;

	if (result.games_count == 0) {
		printf("There are no games, exiting\n");
		exit(EXIT_FAILURE);
	}
	result.cur.gameindex = 0;
	result.cur.halftime = 0;
	md.cur.pause = true;
	result.cur.time = result.deftime;
	for (u8 i = 0; i < result.games_count; i++) {
		result.games[i].halftimescore.t1 = 0;
		result.games[i].halftimescore.t2 = 0;
		result.games[i].score.t1 = 0;
		result.games[i].score.t2 = 0;
		result.games[i].cards_count = 0;
		result.games[i].cards = NULL;
	}
}
