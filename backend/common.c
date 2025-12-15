#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <sys/time.h>

#include <json-c/json.h>
#include <json-c/json_object.h>
#include <json-c/json_object_iterator.h>

#include "common.h"

extern Matchday md;

//Set current_match to first match and 0-initialize every game
void matchday_init() {
	if (md.games_count == 0) {
		printf("There are no games, exiting\n");
		exit(EXIT_FAILURE);
	}
	md.meta.game_i = 0;
	md.meta.halftime = 0;
	md.meta.paused = true;
	md.meta.cur_time = md.meta.game_len;
	for (u8 i = 0; i < md.games_count; i++) {
		md.games[i].halftime_score.t1 = 0;
		md.games[i].halftime_score.t2 = 0;
		md.games[i].score.t1 = 0;
		md.games[i].score.t2 = 0;
		md.games[i].cards_count = 0;
		md.games[i].cards = NULL;
	}
}

// TODO NOW free(): invalid pointer
void matchday_free() {
	for (i32 game_i = 0; game_i < md.games_count; ++game_i) {
		if (md.games[game_i].cards_count > 0) free(md.games[game_i].cards);
		free(md.games[game_i].t1_query.group);
		free(md.games[game_i].t1_query.set);
		free(md.games[game_i].t2_query.group);
		free(md.games[game_i].t2_query.set);

		for (i32 card_i = 0; card_i < md.games[game_i].cards_count; ++card_i)
			free(md.games[game_i].cards[card_i].type);
	}
	for (i32 i = 0; i < md.players_count; ++i)
		free(md.players[i].name);
	if (md.players_count > 0)
		free(md.players);
	if (md.games_count > 0)
		free(md.games);
	for (i32 i = 0; i < md.teams_count; ++i) {
		free(md.teams[i].name);
		free(md.teams[i].logo_path);
	}
	for (i32 i = 0; i < md.groups_count; ++i) free(md.groups[i].members_indices);
	free(md.groups);
	if (md.teams_count > 0)
		free(md.teams);
}

// Return the index of a players name.
// If the name does not exist, return -1.
u8 player_index(const char *name) {
	for (i32 i = 0; i < md.players_count; ++i)
		if (!strcmp(md.players[i].name, name))
			return i;
	return -1;
}

// Return the index of a team name.
// If the name does not exist return -1.
u8 team_index(const char *name) {
	for (i32 i = 0; i < md.teams_count; ++i)
		if (!strcmp(md.teams[i].name, name))
			return i;
	return -1;
}

// Return the index of a Group name.
// If the name does not exist return -1.
u8 group_index(const char *name) {
	printf("looking for Group Index: %s\n", name);
	for (i32 i = 0; i < md.groups_count; ++i) {
		printf("Das hier (%d)? %s == %s\n", i, name, md.groups[i].name);
		if (!strcmp(md.groups[i].name, name))
			return i;
	}
	return -1;
}

char* json_generate() {
	json_object *root = json_object_new_object();
	json_object_object_add(root, "time", json_object_new_int(md.meta.game_len));

	json_object *teams = json_object_new_array();
	json_object *games = json_object_new_array();
	for (int i = 0; i < md.teams_count; i++) {
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
	for (int i = 0; i < md.games_count; i++) {
		json_object *game = json_object_new_object();
		json_object_object_add(game, "team_1", json_object_new_string(md.teams[md.games[i].t1_index].name));
		json_object_object_add(game, "team_2", json_object_new_string(md.teams[md.games[i].t2_index].name));
		json_object *halftimescore = json_object_new_object();
		json_object_object_add(halftimescore, "team_1", json_object_new_int(md.games[i].halftime_score.t1));
		json_object_object_add(halftimescore, "team_2", json_object_new_int(md.games[i].halftime_score.t2));
		json_object_object_add(game, "halftimescore", halftimescore);
		json_object *score = json_object_new_object();
		json_object_object_add(score, "team_1", json_object_new_int(md.games[i].score.t1));
		json_object_object_add(score, "team_2", json_object_new_int(md.games[i].score.t2));
		json_object_object_add(game, "score", score);

		if (md.games[i].cards_count > 0) {
			json_object *cards = json_object_new_array();
			for (int card_i = 0; card_i < md.games[card_i].cards_count; ++card_i) {
				json_object *card = json_object_new_object();
				json_object_object_add(card, "player", json_object_new_string(md.players[md.games[i].cards[card_i].player_index].name));
				json_object_object_add(card, "type", json_object_new_string(md.games[i].cards[card_i].type));
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

json_object *common_json_get_object(json_object *root, const char* key) {
	json_object *jobj;
	json_object_object_get_ex(root, key, &jobj);
	return jobj;
}
i32 common_json_get_int(json_object *root, const char* key) {
	json_object *jobj;
	json_object_object_get_ex(root, key, &jobj);
	return json_object_get_int(jobj);
}
const char *common_json_get_string(json_object *root, const char* key) {
	json_object *jobj;
	json_object_object_get_ex(root, key, &jobj);
	return json_object_get_string(jobj);
}

void common_json_interpret_game_team(
	json_object *game, u8 game_i, const char *team_i,
	u8 *target_index, GameQuery *target_query
) {
	json_object *team_obj = common_json_get_object(game, team_i);
	if (!team_obj) {
		fprintf(stderr, "ERROR parsing JSON: Team %s in game %d does not exist! Exiting...\n", team_i, game_i);
		exit(EXIT_FAILURE);
	}

	const char *team_name = common_json_get_string(team_obj, "name");
	if (!team_name) {
		printf("Game %d is query based\n", game_i);
		json_object *query = common_json_get_object(team_obj, "query");
		if (!query) {
			fprintf(stderr, "ERROR parsing JSON: Team %s in game %d has neither name nor query! Exiting...\n", team_i, game_i);
			exit(EXIT_FAILURE);
		}
		const char *query_set = common_json_get_string(query, "set");
		const u8 query_key = common_json_get_int(query, "key");
		if (!query_set || errno == EINVAL) {
			fprintf(stderr, "ERROR parsing JSON: Query of team %s in game %d doesn't have both \"set\" and \"key\" keys! Exiting...\n", team_i, game_i);
			exit(EXIT_FAILURE);
		}
		target_query->set = malloc((strlen(query_set) + 1) * sizeof(char));
		strcpy(target_query->set, query_set);
		target_query->key = query_key;

		if (!strcmp(query_set, "GROUP")) {
			const char *query_group = common_json_get_string(query, "group");
			if (!query_group) {
				fprintf(stderr, "ERROR parsing JSON: Query of team %s in game %d has a GROUP type but lacks a \"group\" key! Exiting...\n", team_i, game_i);
				exit(EXIT_FAILURE);
			}
			target_query->group = malloc((strlen(query_group) + 1) * sizeof(char));
			strcpy(target_query->group, query_group);
		}

		*target_index = 255; // TODO maybe its a bad idea
		return;
	}
	printf("Game %d is name based\n", game_i);

	memset(target_query, 0, sizeof(GameQuery));

	printf("TODO some ii\n");
	printf("TODO team name '%s'\n", team_name);
	const i32 this_game_index = team_index(team_name);
	printf("TODO some ii.i\n");
	if (this_game_index == -1) {
		fprintf(stderr, "ERROR parsing JSON: Team \"%s\" in game %d does not exist! Exiting...\n", team_name, game_i);
		exit(EXIT_FAILURE);
	}

	printf("TODO some iii\n");
	*target_index = this_game_index;
}

// TODO FINAL before exiting, make sure to free resources
// TODO FINAL CONSIDER migrate to a struct-based json parsing strategy
// TODO IMPLEMENT card reason and card timestamp
void common_json_read_from_string(const char *s) {
	// Then split json into teams and games
	json_object *root = json_tokener_parse(s);
	if (!root) {
		fprintf(stderr, "ERROR parsing JSON: Syntax error! (You can use jsonlint.com to verify your JSON's correctness) Exiting...\n");
		exit(EXIT_FAILURE);
	}

	json_object *meta = common_json_get_object(root, "meta");
	if (!meta) {
		fprintf(stderr, "ERROR parsing JSON: Missing \"meta\" field! Exiting...\n");
		exit(EXIT_FAILURE);
	}
	md.meta.game_len = common_json_get_int(meta, "game_len");

	json_object *teams = common_json_get_object(root, "teams");
	if (!teams) {
		fprintf(stderr, "ERROR parsing JSON: Missing \"teams\" field! Exiting...\n");
		exit(EXIT_FAILURE);
	}
	json_object *games = common_json_get_object(root, "games");
	if (!games) {
		fprintf(stderr, "ERROR parsing JSON: Missing \"games\" field! Exiting...\n");
		exit(EXIT_FAILURE);
	}

	md.teams_count = json_object_array_length(teams);
	// Add decoy team for the decoy game at the end
	md.teams = malloc((md.teams_count + 1) * sizeof(Team));

	json_object *first_team = json_object_array_get_idx(teams, 0);
	if (!first_team) {
		fprintf(stderr, "ERROR parsing JSON: The teams array is empty! Exiting...\n");
		exit(EXIT_FAILURE);
	}
	json_object *first_team_players = common_json_get_object(first_team, "players");
	if (!first_team_players) {
		fprintf(stderr, "ERROR parsing JSON: The first team's player array is empty! Exiting...\n");
		exit(EXIT_FAILURE);
	}
	const u8 team_size = json_object_array_length(first_team_players);

	md.players_count = md.teams_count * team_size;
	md.players = malloc(md.players_count * sizeof(Player));

	// Read all the teams
	for (int team_i = 0; team_i < md.teams_count; ++team_i) {
		json_object *team = json_object_array_get_idx(teams, team_i);

		const char *team_name = common_json_get_string(team, "name");
		if (!team_name) {
			fprintf(stderr, "ERROR parsing JSON: Team %d has no name! Exiting...\n", team_i);
			exit(EXIT_FAILURE);
		}
		const u16 team_name_len = strlen(team_name);
		md.teams[team_i].name = malloc((team_name_len + 1) * sizeof(char));
		strcpy(md.teams[team_i].name, team_name);
		md.teams[team_i].name[team_name_len] = '\0';

		const char *logo_path = common_json_get_string(team, "logo_path");
		const u16 logo_path_len = strlen(logo_path);
		md.teams[team_i].logo_path = malloc((logo_path_len + 1) * sizeof(char));
		if (logo_path) strcpy(md.teams[team_i].logo_path, logo_path);
		md.teams[team_i].logo_path[logo_path_len] = '\0';

		json_object *players = common_json_get_object(team, "players");
		for (int player_i = 0; player_i < json_object_array_length(players); ++player_i) {
			json_object *player = json_object_array_get_idx(players, player_i);

			const char *player_name = common_json_get_string(player, "name");
			const u16 player_name_len = strlen(player_name);
			md.players[team_i * team_size + player_i].name = malloc((player_name_len + 1) * sizeof(char));
			strcpy(md.players[team_i * team_size + player_i].name, player_name);
			md.players[team_i * team_size + player_i].name[player_name_len] = '\0';

			md.players[team_i * team_size + player_i].team_index = team_i;

			const char *role = common_json_get_string(player, "role");
			if (role) {
				const u8 role_len = strlen(role);
				md.players[team_i * team_size + player_i].role = malloc((role_len + 1) * sizeof(char));
				strcpy(md.players[team_i * team_size + player_i].role, role);

				// TODO
				if (!strcmp(role, "keeper")) md.teams[team_i].keeper_index = team_i * team_size + player_i;
				else if (!strcmp(role, "field")) md.teams[team_i].field_index = team_i * team_size + player_i;
				else {
					fprintf(stderr, "ERROR So far, we don't allow other player roles besides \"keeper\" and \"field\" Stay tuned. Exiting...\n");
					exit(EXIT_FAILURE);
				}
			}
		}

		const char *team_color = common_json_get_string(team, "color");
		if (team_color) strcpy(md.teams[team_i].color, team_color);
		md.teams[team_i].color[6] = '\0';
	}

	// Add a decoy team thats like team 0 but with the name "ENDE". Its used in the decoy game at the end
	md.teams[md.teams_count].name = malloc((4 + 1) * sizeof(char));
	strcpy(md.teams[md.teams_count].name, "ENDE");
	strcpy(md.teams[md.teams_count].color, md.teams[0].color);
	md.teams[md.teams_count].field_index = md.teams[0].field_index;
	md.teams[md.teams_count].keeper_index = md.teams[0].keeper_index;
	md.teams[md.teams_count].logo_path = md.teams[0].logo_path;

	md.games_count = json_object_array_length(games);
	// We alloc one game more, because its a filler game for the end
	md.games = malloc((md.games_count + 1) * sizeof(Game));

	// Read all the games
	printf("TODO feck\n");
	for (int game_i = 0; game_i < md.games_count; ++game_i) {
		printf("TODO game %d\n", game_i + 1);
		json_object *game_obj = json_object_array_get_idx(games, game_i);

		common_json_interpret_game_team(
			game_obj, game_i, "1",
			&md.games[game_i].t1_index,
			&md.games[game_i].t1_query
		);
		common_json_interpret_game_team(
			game_obj, game_i, "2",
			&md.games[game_i].t2_index,
			&md.games[game_i].t2_query
		);
		printf("DEBUG: Game %d: t1_index: %d, t2_index: %d\n", game_i, md.games[game_i].t1_index, md.games[game_i].t1_index);

		json_object *halftime_score = common_json_get_object(game_obj, "halftime_score");
		if (halftime_score) {
			const u8 score_1 = common_json_get_int(halftime_score, "1");
			if (!score_1 && errno == EINVAL) {
				fprintf(stderr, "ERROR parsing JSON: Game %d has a halftime score but lacks one for team 1! Exiting...\n", game_i);
				exit(EXIT_FAILURE);
			}
			const u8 score_2 = common_json_get_int(halftime_score, "2");
			if (!score_2 && errno == EINVAL) {
				fprintf(stderr, "ERROR parsing JSON: Game %d has a halftime score but lacks one for team 2! Exiting...\n", game_i);
				exit(EXIT_FAILURE);
			}
			md.games[game_i].halftime_score.t1 = score_1;
			md.games[game_i].halftime_score.t2 = score_2;
		}
		printf(" TODO 3\n");
		json_object *score = common_json_get_object(game_obj, "score");
		if (score) {
			const u8 score_1 = common_json_get_int(score, "1");
			if (!score_1 && errno == EINVAL) {
				fprintf(stderr, "ERROR parsing JSON: Game %d has a score but lacks one for team 1! Exiting...\n", game_i);
				exit(EXIT_FAILURE);
			}
			const u8 score_2 = common_json_get_int(score, "2");
			if (!score_2 && errno == EINVAL) {
				fprintf(stderr, "ERROR parsing JSON: Game %d has a score but lacks one for team 2! Exiting...\n", game_i);
				exit(EXIT_FAILURE);
			}
			md.games[game_i].score.t1 = score_1;
			md.games[game_i].score.t2 = score_2;
		}
		printf(" TODO 4\n");

		json_object *cards = common_json_get_object(game_obj, "cards");
		if (cards) {
			md.games[game_i].cards_count = json_object_array_length(cards);
			md.games[game_i].cards = malloc(md.games[game_i].cards_count * sizeof(Card));

			for (int card_i = 0; card_i < md.games[game_i].cards_count; ++card_i) {
				json_object *card = json_object_array_get_idx(cards, card_i);

				const char *player_name = common_json_get_string(card, "name");
				if (!player_name) {
					fprintf(stderr, "ERROR parsing JSON: Card %d does not feature a player name! Exiting...\n", game_i);
					exit(EXIT_FAILURE);
				}

				const i32 this_player_index = player_index(player_name);
				if (this_player_index == -1) {
					fprintf(stderr, "ERROR parsing JSON: Player '%s' mentioned in card %d of game %d does not exist! Exiting...\n", player_name, card_i, game_i);
					exit(EXIT_FAILURE);
				}
				md.games[game_i].cards[card_i].player_index = this_player_index;

				const char *type = common_json_get_string(card, "type");
				// TODO malloc this, free that
				if (type) {
					md.games[game_i].cards[card_i].type = malloc((strlen(type) + 1) * sizeof(char));
					strcpy(md.games[game_i].cards[card_i].type, type); // TODO NOTE could be bad
				} else md.games[game_i].cards[card_i].type = (char *) "";
			}
		}
	}

	printf("TODO fock\n");
	// Read all groups
	json_object *groups = common_json_get_object(root, "groups");
	if (groups) {
		md.groups_count = json_object_object_length(groups);
		md.groups = malloc(md.groups_count * sizeof(Group));

		struct json_object_iterator it = json_object_iter_begin(groups);
		struct json_object_iterator it_end = json_object_iter_end(groups);
		for (
			i32 group_i = 0;
			!json_object_iter_equal(&it, &it_end);
			++group_i, json_object_iter_next(&it)
		) {
			const char *shallow_name = (char *) json_object_iter_peek_name(&it);
			md.groups[group_i].name = malloc(strlen(shallow_name) + 1);
			strcpy(md.groups[group_i].name, shallow_name);

			json_object *members = json_object_iter_peek_value(&it);
			const u16 members_count = json_object_array_length(members);

			md.groups[group_i].members_count = members_count;
			printf("OAOAOAO --- MEMBERS COUNT: %d --- OAOAOAOAO\n", md.groups[group_i].members_count);
			md.groups[group_i].members_indices = malloc(members_count * sizeof(u8 *));

			for (i32 member_i = 0; member_i < members_count; ++member_i) {
				json_object *member = json_object_array_get_idx(members, member_i);
				const char *member_name = json_object_get_string(member);
				int team_i = team_index(member_name);
				if(team_i == -1) {
					fprintf(stderr, "ERROR: Cant parse input.json: Cant find Team '%s' from Group '%s\n", member_name, md.groups[group_i].name);
					exit(EXIT_FAILURE);
				}
				md.groups[group_i].members_indices[member_i] = team_i;
			}

		}
	} else {
		md.groups = NULL;
		md.groups_count = 0;
	}
	printf("TODO fick\n");

	// Init decoy game at the end
	const Game decoy_game = {
		.t1_index = md.teams_count,
		.t2_index = md.teams_count,
		.halftime_score = { .t1 = 0, .t2 = 0 },
		.score = { .t1 = 0, .t2 = 0 },
		.cards = NULL,
		.cards_count = 0,
		.replays_count = 0
	};
	md.games[md.games_count] = decoy_game;

	// Free resources
	json_object_put(root);
	printf("TODO latest queries 2: '%s'\n", md.games[5].t1_query.set);
}

// @ret the string of the whole content of the file. In case of an error: NULL
//The responsibility of the string, gets passed to the caller! It has to free!
char* common_read_file(const char *path) {
	// First convert path to actual string containing whole file
	FILE *f = fopen(path, "rb");
	if (f == NULL) {
		fprintf(stderr, "Json Input file is not available! Exiting...\n");
		return NULL;
	}
	// seek to end to find length, then reset to the beginning
	fseek(f, 0, SEEK_END);
	const u32 file_size = ftell(f);
	rewind(f);

	char *filestring = malloc((file_size + 1) * sizeof(char)); // +1 for \0
	if (filestring == NULL) {
		fprintf(stderr, "Not enough memory for loading json! Exiting...\n");
		fclose(f);
		return NULL;
	}

	u32 chars_read = fread(filestring, sizeof(char), file_size, f);
	if (chars_read != file_size) {
		fprintf(stderr, "Could not read whole json file! Exiting...");
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
	char *s = malloc(20 * sizeof(char));
	sprintf(s, "%ld.%06ld", (long int)t.tv_sec, (long int)t.tv_usec);
	return s;
}

u8 add_card(char *type, u8 player_index) {
	const u8 cur = md.meta.game_i;

	if (md.games[cur].cards_count == 0)
		md.games[cur].cards = malloc(sizeof(Card));
	else
		md.games[cur].cards = realloc(md.games[cur].cards, (md.games[cur].cards_count+1) * sizeof(Card));

	md.games[cur].cards[md.games[cur].cards_count].player_index = player_index;
	strcpy(md.games[cur].cards[md.games[cur].cards_count++].type, type);
	return md.games[cur].cards_count-1;
}
