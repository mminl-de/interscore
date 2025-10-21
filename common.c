#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <sys/time.h>

#include <json-c/json.h>
#include <json-c/json_object.h>

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
	md.cur.time = md.deftime;
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
	for (int i=0; i < md.games_count; i++)
		if (md.games[i].cards_count > 0)
			free(md.games[i].cards);
	for (int i=0; i < md.players_count; i++)
		free(md.players[i].name);
	if (md.players_count > 0)
		free(md.players);
	if (md.games_count > 0)
		free(md.games);
	for (int i=0; i < md.teams_count; i++) {
		free(md.teams[i].name);
		free(md.teams[i].logo_path);
		free(md.teams[i].color);
	}
	if (md.teams_count > 0)
		free(md.teams);
}

// Return the index of a players name.
// If the name does not exist, return -1.
int player_index(const char *name) {
	for (i32 i = 0; i < md.players_count; ++i)
		if (!strcmp(md.players[i].name, name))
			return i;
	return -1;
}

// Return the index of a team name.
// If the name does not exist return -1.
int team_index(const char *name) {
	for (i32 i = 0; i < md.teams_count; ++i)
		if (!strcmp(md.teams[i].name, name))
			return i;
	return -1;
}

char* json_generate() {
	json_object *root = json_object_new_object();
	json_object_object_add(root, "time", json_object_new_int(md.deftime));

	json_object *teams = json_object_new_array();
	json_object *games = json_object_new_array();
	for (int i=0; i < md.teams_count; i++) {
		json_object *team = json_object_new_object();
		json_object_object_add(team, "name", json_object_new_string(md.teams[i].name));
		json_object_object_add(team, "logo", json_object_new_string(md.teams[i].logo_path));
		json_object_object_add(team, "color", json_object_new_string(md.teams[i].color));
		json_object *players = json_object_new_array();
		json_object *player1 = json_object_new_object();
		json_object_object_add(player1, "name", json_object_new_string(md.players[md.teams[i].keeper_index].name));
		json_object_object_add(player1, "position", json_object_new_string("keeper"));
		json_object_array_add(players, player1);
		json_object *player2 = json_object_new_object();
		json_object_object_add(player2, "name", json_object_new_string(md.players[md.teams[i].field_index].name));
		json_object_object_add(player2, "position", json_object_new_string("field"));
		json_object_array_add(players, player2);
		json_object_object_add(team, "players", players);
		json_object_array_add(teams, team);
	}
	for (int i=0; i < md.games_count; i++) {
		json_object *game = json_object_new_object();
		json_object_object_add(game, "team_1", json_object_new_string(md.teams[md.games[i].t1_index].name));
		json_object_object_add(game, "team_2", json_object_new_string(md.teams[md.games[i].t2_index].name));
		json_object *halftimescore = json_object_new_object();
		json_object_object_add(halftimescore, "team_1", json_object_new_int(md.games[i].halftimescore.t1));
		json_object_object_add(halftimescore, "team_2", json_object_new_int(md.games[i].halftimescore.t2));
		json_object_object_add(game, "halftimescore", halftimescore);
		json_object *score = json_object_new_object();
		json_object_object_add(score, "team_1", json_object_new_int(md.games[i].score.t1));
		json_object_object_add(score, "team_2", json_object_new_int(md.games[i].score.t2));
		json_object_object_add(game, "score", score);

		if (md.games[i].cards_count > 0) {
			json_object *cards = json_object_new_array();
			for (int j=0; j < md.games[j].cards_count; j++) {
				json_object *card = json_object_new_object();
				json_object_object_add(card, "player", json_object_new_string(md.players[md.games[i].cards[j].player_index].name));
				if (md.games[i].cards[j].card_type == 0)
					json_object_object_add(card, "type", json_object_new_string("Y"));
				else
					json_object_object_add(card, "type", json_object_new_string("R"));
				json_object_array_add(cards, card);
			}
			json_object_object_add(game, "cards", cards);
		}
		json_object_array_add(games, game);
	}
	json_object_object_add(root, "teams", teams);
	json_object_object_add(root, "games", games);
	char *str = (char *) json_object_to_json_string_ext(root, JSON_C_TO_STRING_PRETTY);
	return str;
}

json_object *common_json_get_object(json_object *root, char *const key) {
	json_object *jobj;
	json_object_object_get_ex(root, key, &jobj);
	return jobj;
}
i32 common_json_get_int(json_object *root, char *const key) {
	json_object *jobj;
	json_object_object_get_ex(root, key, &jobj);
	return json_object_get_int(jobj);
}
const char *common_json_get_string(json_object *root, char *const key) {
	json_object *jobj;
	json_object_object_get_ex(root, key, &jobj);
	return json_object_get_string(jobj);
}

void json_load(const char *s) {
	// Then split json into teams and games
	json_object *root = json_tokener_parse(s);
	json_object *meta = common_json_get_object(root, "meta");

	md.meta.game_len = common_json_get_int(meta, "game_len");

	json_object *teams = common_json_get_object(root, "teams");
	json_object *games = common_json_get_object(root, "games");

	md.teams_count = json_object_array_length(teams);
	// Add decoy team for the decoy game at the end
	md.teams = malloc((md.teams_count + 1) * sizeof(Team));

	const u8 team_size = json_object_array_length(json_object_array_get_idx(teams, 0));
	md.players_count = md.teams_count * team_size;
	md.players = malloc(md.players_count * sizeof(Player));

	// Read all the teams
	for (int i = 0; i < md.teams_count; i++) {
		json_object *team = json_object_array_get_idx(teams, i);

		const char *team_name = common_json_get_string(team, "name");
		const u16 team_name_len = strlen(team_name);
		md.teams[i].name = malloc((team_name_len + 1) * sizeof(char));
		strcpy(md.teams[i].name, team_name);
		md.teams[i].name[team_name_len] = '\0';

		const char *logo_path = common_json_get_string(team, "logo");
		const u16 logo_path_len = strlen(logo_path);
		md.teams[i].logo_path = (char *) malloc((logo_path_len + 1) * sizeof(char));
		strcpy(md.teams[i].logo_path, logo_path);
		md.teams[i].logo_path[logo_path_len] = '\0';

		json_object *players = common_json_get_object(team, "players");
		for (int j = 0; j < json_object_array_length(players); ++j) {
			json_object *player = json_object_array_get_idx(players, j);

			const char *player_name = common_json_get_string(player, "name");
			const u16 player_name_len = strlen(player_name);
			md.players[i * team_size + j].name = malloc((player_name_len + 1) * sizeof(char));
			strcpy(md.players[i * team_size + j].name, player_name);
			md.players[i * team_size + j].name[player_name_len] = '\0';

			md.players[i * team_size + j].team_index = i;

			const char *role = common_json_get_string(player, "role");
			if (!strcmp(role, "keeper")) {
				md.players[i * team_size + j].role = KEEPER;
				md.teams[i].keeper_index = i * team_size + j;
			} else if (!strcmp(role, "field")) {
				md.players[i * team_size + j].role = FIELD;
				md.teams[i].field_index = i * team_size + j;
			} else {
				printf("ERROR parsing JSON: Unknown Position: %s. Exiting...", role);
				exit(EXIT_FAILURE);
			}
		}

		const char *team_color = common_json_get_string(team, "color");
		const u16 team_color_len = strlen(team_color);
		md.teams[i].color = (char *) malloc((team_color_len + 1) * sizeof(char));
		strcpy(md.teams[i].color, team_color);
		md.teams[i].color[team_color_len] = '\0';
	}

	// Add a decoy team thats like team 0 but with the name "ENDE". Its used in the decoy game at the end
	md.teams[md.teams_count].name = malloc((4 + 1) * sizeof(char));
	strcpy(md.teams[md.teams_count].name, "ENDE");
	md.teams[md.teams_count].color = md.teams[0].color;
	md.teams[md.teams_count].field_index = md.teams[0].field_index;
	md.teams[md.teams_count].keeper_index = md.teams[0].keeper_index;
	md.teams[md.teams_count].logo_path = md.teams[0].logo_path;

	md.games_count = json_object_array_length(games);
	// We alloc one game more, because its a filler game for the end
	md.games = malloc((md.games_count + 1) * sizeof(Game));

	for (int i = 0; i < md.games_count; ++i) {
		json_object *game = json_object_array_get_idx(games, i);

		json_object *team_1 = common_json_get_object(game, "1");

		// TODO NOW PLAN
		// construct a placeholder string from query
		// free team_1_name afterwards
		bool team_1_name_is_owned = false;
		char *team_1_name;
		const char *team_1_name_cand = common_json_get_string(team_1, "name");
		if (!team_1_name_cand) {
			team_1_name_is_owned = true;

			json_object *query = common_json_get_object(team_1, "query");
			if (!query) {
				printf("ERROR parsing JSON: Team 1 in game no. %d has neither name nor a query! Exiting...", i);
				exit(EXIT_FAILURE);
			}
			const char *query_set = common_json_get_string(query, "set");
			const u16 query_key = common_json_get_int(query, "key");
		}

		if (team_index(team_1) == -1) {
			printf("Erorr parsing JSON: '%s' does not exist (teamname of Team 1 in Game %d). Exiting...\n", json_object_get_string(team), i + 1);
			exit(EXIT_FAILURE);
		}
		md.games[i].t1_index = team_index(json_object_get_string(team));

		json_object_object_get_ex(game, "team_2", &team);
		if (team_index(json_object_get_string(team)) == -1) {
			printf("Erorr parsing JSON: '%s' does not exist (teamname of Team 2 in Game %d). Exiting...\n", json_object_get_string(team), i + 1);
			exit(EXIT_FAILURE);
		}
		md.games[i].t2_index = team_index(json_object_get_string(team));

		json_object *halftimescore, *score, *cards, *var;
		if (json_object_object_get_ex(game, "halftimescore", &halftimescore)) {
			json_object_object_get_ex(halftimescore, "team_1", &var);
			md.games[i].halftimescore.t1 = json_object_get_int(var);
			json_object_object_get_ex(halftimescore, "team_2", &var);
			md.games[i].halftimescore.t2 = json_object_get_int(var);
		}
		if (json_object_object_get_ex(game, "score", &score)) {
			json_object_object_get_ex(score, "team_1", &var);
			md.games[i].score.t1 = json_object_get_int(var);
			json_object_object_get_ex(score, "team_2", &var);
			md.games[i].score.t2 = json_object_get_int(var);
		}

		if (json_object_object_get_ex(game, "cards", &cards)) {

			md.games[i].cards_count = json_object_array_length(cards);
			md.games[i].cards = (Card *) malloc(md.games[i].cards_count * sizeof(Card));

			for (int j=0; j < md.games[i].cards_count; j++) {
				json_object *player, *type, *card;
				card = json_object_array_get_idx(cards, j);
				json_object_object_get_ex(card, "player", &player);
				if (player_index(json_object_get_string(player)) == -1) {
					printf("Erorr parsing JSON: '%s' does not exist (Playername of Card %d in Game %d). Exiting...\n", json_object_get_string(player), j+1, i + 1);
					exit(EXIT_FAILURE);
				}
				md.games[i].cards[j].player_index = player_index(json_object_get_string(player));

				json_object_object_get_ex(card, "type", &type);
				if (strcmp(json_object_get_string(type), "Y"))
					md.games[i].cards[j].card_type = YELLOW;
				else if (strcmp(json_object_get_string(type), "R"))
					md.games[i].cards[j].card_type = RED;
			}
		}
	}
	//Init Decoy-Game at the End
	md.games[md.games_count].t1_index = md.teams_count;
	md.games[md.games_count].t2_index = md.teams_count;
	md.games[md.games_count].cards = NULL;
	md.games[md.games_count].cards_count = 0;
	md.games[md.games_count].score.t1 = 0;
	md.games[md.games_count].score.t2 = 0;
	md.games[md.games_count].halftimescore.t1 = 0;
	md.games[md.games_count].halftimescore.t2 = 0;

	// Free resources
	json_object_put(root);
}

// @ret the string of the whole content of the file. In case of an error: NULL
//The responsibility of the string, gets passed to the caller! It has to free!
char* common_read_file(const char *path) {
	// First convert path to actual string containing whole file
	FILE *f = fopen(path, "rb");
	if (f == NULL) {
		printf("Json Input file is not available! Exiting...\n");
		return NULL;
	}
	// seek to end to find length, then reset to the beginning
	fseek(f, 0, SEEK_END);
	const u32 file_size = ftell(f);
	rewind(f);

	char *filestring = (char *) malloc((file_size + 1) * sizeof(char)); // +1 for \0
	if (filestring == NULL) {
		printf("Not enough memory for loading json! Exiting...\n");
		fclose(f);
		return NULL;
	}

	u32 chars_read = fread(filestring, sizeof(char), file_size, f);
	if (chars_read != file_size) {
		printf("Could not read whole json file! Exiting...");
		free(filestring);
		fclose(f);
		return NULL;
	}
	filestring[file_size] = '\0';
	fclose(f);
	return filestring;
}

//Write the string to the file in path. If the file exists, overwrite it. If not, create it
bool file_write(const char *path, const char *s) {
	FILE *f = fopen(path, "w");
	if (f == NULL)
		return false;
	fprintf(f, "%s", s);
	fclose(f);
	return true;
}

char *gettimems() {
	struct timeval t;
	gettimeofday(&t, NULL);
	char *s = (char *)malloc(20 * sizeof(char));
	sprintf(s, "%ld.%06ld", (long int)t.tv_sec, (long int)t.tv_usec);
	return s;
}

u8 add_card(enum CardType type, u8 player_index) {
	const u8 cur = md.cur.gameindex;

	if (md.games[cur].cards_count == 0)
		md.games[cur].cards = (Card *)malloc(0 + 1 * sizeof(Card));
	else
		md.games[cur].cards = (Card *)realloc(md.games[cur].cards, (md.games[cur].cards_count+1) * sizeof(Card));

	md.games[cur].cards[md.games[cur].cards_count].player_index = player_index;
	md.games[cur].cards[md.games[cur].cards_count++].card_type = type;
	return md.games[cur].cards_count-1;
}
