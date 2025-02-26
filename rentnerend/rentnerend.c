#include <gtk/gtk.h>
#include <json-c/json.h>
#include <json-c/json_object.h>
//#include "../mongoose/mongoose.h"

#include "../config.h"
#include "gtk/gtkshortcut.h"

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;

typedef struct {
	int width;
	int height;
	GtkWidget *w;
	GtkWidget *fixed;
	struct {
		struct {
			GtkWidget* name;
			GtkWidget* score;
		} t1;
		struct {
			GtkWidget* name;
			GtkWidget* score;
		} t2;
		GtkWidget* time;
		GtkWidget* colon;
	} l;
} w_display;

typedef struct {
	int width;
	int height;
	GtkWidget *w;
	GtkWidget *fixed;
	struct {
		struct {
			GtkWidget* name;
			GtkWidget* score;
		} t1;
		struct {
			GtkWidget* name;
			GtkWidget* score;
		} t2;
		GtkWidget* time;
	} l;
	struct {
		struct {
			GtkWidget *score_plus;
			GtkWidget *score_minus;
		} t1;
		struct {
			GtkWidget *score_plus;
			GtkWidget *score_minus;
		} t2;
		struct {
			GtkWidget *next;
			GtkWidget *prev;
			GtkWidget *switch_sides;
		} game;
		struct {
			GtkWidget *yellow;
			GtkWidget *red;
		} card;
		struct {
			GtkWidget *plus;
			GtkWidget *minus;
			GtkWidget *toggle_pause;
			GtkWidget *reset;
		} time;
	} b;
	GtkWidget *dd_card_players;
} w_input;

typedef struct {
	u8 t1;
	u8 t2;
} Score;

typedef struct {
	u8 player_index;
	bool card_type; // 0: yellow card, 1: red card
} Card;

typedef struct {
	char *name;
	u8 team_index;
	bool role; // 0: keeper, 1: field
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
		u8 gameindex; // index of the current game played in the games array
		bool halftime; // 0: first half, 1: second half
		u16 time;
		bool pause;
	} cur;
	Game *games;
	u8 games_count;
	Team *teams;
	u8 teams_count;
	Player *players;
	u8 players_count;
} Matchday;

Matchday md;
w_display wd;
w_input wi;

void update_input_window();
void update_display_window();

void btn_cb_t1_score_plus(){
	md.games[md.cur.gameindex].score.t1++;
	update_input_window();
	update_display_window();
}
void btn_cb_t1_score_minus(){
	if(md.games[md.cur.gameindex].score.t1 > 0)
		md.games[md.cur.gameindex].score.t1--;
	update_input_window();
	update_display_window();
}
void btn_cb_t2_score_plus(){
	md.games[md.cur.gameindex].score.t2++;
	update_input_window();
	update_display_window();
}
void btn_cb_t2_score_minus(){
	if(md.games[md.cur.gameindex].score.t2 > 0)
		md.games[md.cur.gameindex].score.t2--;
	update_input_window();
	update_display_window();
}
void btn_cb_game_next(){
	if(md.cur.gameindex < md.games_count-1)
		md.cur.gameindex++;
	update_input_window();
	update_display_window();
}
void btn_cb_game_prev(){
	if(md.cur.gameindex > 0)
		md.cur.gameindex--;
	update_input_window();
	update_display_window();
}
void btn_cb_game_switch_sides(){
	md.cur.halftime = !md.cur.halftime;
	update_input_window();
	update_display_window();
}
void btn_cb_time_plus(){
	md.cur.time++;
	update_input_window();
	update_display_window();
}
void btn_cb_time_minus(){
	md.cur.time--;
	update_input_window();
	update_display_window();
}
void btn_cb_time_toggle_pause(){
	md.cur.pause = !md.cur.pause;
	update_input_window();
	update_display_window();
}
void btn_cb_time_reset(){
	md.cur.time = GAME_LENGTH;
	update_input_window();
	update_display_window();
}



//Set current_match to first match and 0-initialize every game
void init_matchday() {
	if (md.games_count == 0) {
		printf("There are no games, exiting\n");
		exit(EXIT_FAILURE);
	}
	md.cur.gameindex = 0;
	md.cur.halftime = 0;
	md.cur.time = GAME_LENGTH;
	for (u8 i = 0; i < md.games_count; i++) {
		md.games[i].halftimescore.t1 = 0;
		md.games[i].halftimescore.t2 = 0;
		md.games[i].score.t1 = 0;
		md.games[i].score.t2 = 0;
		md.games[i].cards_count = 0;
		md.games[i].cards = NULL;
	}
	return;
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
		if (strcmp(md.teams[i].name, name) == 0)
			return i;
	return -1;
}

void load_json(const char *path) {
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

	char *filestring = malloc((file_size + 1) * sizeof(char));
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
	struct json_object *teams = json_object_new_object();
	struct json_object *games = json_object_new_object();
	json_object_object_get_ex(root, "teams", &teams);
	json_object_object_get_ex(root, "games", &games);

	md.teams_count = json_object_object_length(teams);
	md.teams = malloc(md.teams_count * sizeof(Team));

	md.players_count = md.teams_count*2;
	md.players = malloc(md.players_count * sizeof(Player));

	// Read all the teams
	u32 i = 0;
	json_object_object_foreach(teams, teamname, teamdata) {
		md.teams[i].name = teamname;
		json_object *logo, *keeper, *field, *name, *color;

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

		json_object_object_get_ex(teamdata, "color_light", &color);
		md.teams[i].color_light = malloc(strlen(json_object_get_string(color)) *sizeof(char));
		strcpy(md.teams[i].color_light, json_object_get_string(color));

		json_object_object_get_ex(teamdata, "color_dark", &color);
		md.teams[i].color_dark = malloc(strlen(json_object_get_string(color)) *sizeof(char));
		strcpy(md.teams[i].color_dark, json_object_get_string(color));

		i++;
	}

	md.games_count = json_object_object_length(games);
	md.games = malloc(md.games_count * sizeof(Game));

	i = 0;
	json_object_object_foreach(games, gamenumber, gamedata) {
		json_object *team;
		json_object_object_get_ex(gamedata, "team1", &team);
		if (team_index(json_object_get_string(team)) == -1) {
			printf("Erorr parsing JSON: '%s' does not exist (teamname of Team 1 in Game %d). Exiting...\n", json_object_get_string(team), i + 1);
			exit(EXIT_FAILURE);
		}
		md.games[i].t1_index = team_index(json_object_get_string(team));

		json_object_object_get_ex(gamedata, "team2", &team);
		if (team_index(json_object_get_string(team)) == -1) {
			printf("Erorr parsing JSON: '%s' does not exist (teamname of Team 2 in Game %d). Exiting...\n", json_object_get_string(team), i + 1);
			exit(EXIT_FAILURE);
		}
		md.games[i].t2_index = team_index(json_object_get_string(team));
		json_object *halftimescore, *score, *cards, *var;
		if (json_object_object_get_ex(gamedata, "halftimescore", &halftimescore)) {
			json_object_object_get_ex(halftimescore, "team1", &var);
			md.games[i].halftimescore.t1 = json_object_get_int(var);
			json_object_object_get_ex(halftimescore, "team2", &var);
			md.games[i].halftimescore.t2 = json_object_get_int(var);
		}
		if (json_object_object_get_ex(gamedata, "score", &score)) {
			json_object_object_get_ex(score, "team1", &var);
			md.games[i].score.t1 = json_object_get_int(var);
			json_object_object_get_ex(score, "team2", &var);
			md.games[i].score.t2 = json_object_get_int(var);
		}
		if (json_object_object_get_ex(gamedata, "cards", &cards)) {

			md.games[i].cards_count = json_object_object_length(cards);
			md.games[i].cards = malloc(md.games[i].cards_count * sizeof(Card));

			u32 j = 0;
			json_object_object_foreach(cards, cardname, carddata) {
				json_object *player, *type;
				json_object_object_get_ex(carddata, "player", &player);
				if (player_index(json_object_get_string(player)) == -1) {
					printf("Erorr parsing JSON: '%s' does not exist (Playername of Card %d in Game %d). Exiting...\n", json_object_get_string(player), j+1, i + 1);
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


// Update display window
void update_display(GtkWidget *label, const gchar *text) {
    gtk_label_set_text(GTK_LABEL(label), text);
}

// Timer callback function
/*
gboolean update_timer(gpointer user_data) {
    ScoreboardData *data = (ScoreboardData *)user_data;
    if (data->running && data->time_remaining > 0) {
        data->time_remaining--;
        gchar time_str[16];
        g_snprintf(time_str, sizeof(time_str), "Time: %d sec", data->time_remaining);
        update_display(data->time_label, time_str);
        return G_SOURCE_CONTINUE;
    }
    return G_SOURCE_REMOVE;
}

// Start/Pause button callback
void toggle_timer(GtkButton *button, gpointer user_data) {
    ScoreboardData *data = (ScoreboardData *)user_data;
    data->running = !data->running;
    if (data->running) {
        g_timeout_add_seconds(1, update_timer, data);
    }
}
*/

//Gets the biggest font size possible for a markuped text of a label
int biggest_fontsize_possible(char *text, int max_fontsize, int x, int y, bool bold) {
	int width, height, fontsize = max_fontsize+1;
	char b[] = "weight='bold'";
	if (!bold)
		b[0] = '\0';

	GtkWidget *l_decoy = gtk_label_new(NULL);
	do {
		fontsize--;

		char s[500];
		sprintf(s, "<span %s font='%d'>%s</span>", b, fontsize, text);
		gtk_label_set_markup(GTK_LABEL(l_decoy), s);

		int trash;
		gtk_widget_measure(l_decoy, GTK_ORIENTATION_HORIZONTAL, -1, &width, &trash, NULL, NULL);
		gtk_widget_measure(l_decoy, GTK_ORIENTATION_VERTICAL, -1, &height, &trash, NULL, NULL);
		if(y == -1)
			y = height;
		if(x == -1)
			x = width;
	} while (width > x || height > y);
	printf("text: %s, width: %d, height: %d, x: %d, y: %d\n", text, width, height, x, y);
	gtk_widget_set_visible(l_decoy, FALSE);
	return fontsize;
}

//alignment: 0:= left, 1:= center, 2:=right
void update_label(GtkWidget **l, GtkWidget *fixed, int x_start, int x_end, int y_start, int y_end, char *text, int fontsize, bool variable_fontsize, bool bold, u8 x_alignment, u8 y_alignment) {
	printf("Update Label Begin: text: %s\n", text);
	char s[strlen(text)+100];
	if (variable_fontsize)
		fontsize = biggest_fontsize_possible(text, fontsize, x_end-x_start, y_end-y_start, bold);
	char bold_str[] = "weight='bold'";
	if (!bold)
		bold_str[0] = '\0';
	sprintf(s, "<span %s font='%d'>%s</span>", bold_str, fontsize, text);
	gtk_label_set_markup(GTK_LABEL(*l), s);

	int width, height, trash;
	if (x_alignment == 1 && x_end != -1) {
		gtk_widget_measure(*l, GTK_ORIENTATION_HORIZONTAL, -1, &width, &trash, NULL, NULL);
		printf("text: %s, x_alignment = 1, x_start: %d, new x_start: %d,x_end: %d, width: %d\n", text, x_start, (x_end-x_start)-width, x_end, width);
		x_start += ((x_end-x_start)-width)/2;
	} else if (x_alignment == 2 && x_end != -1) {
		gtk_widget_measure(*l, GTK_ORIENTATION_HORIZONTAL, -1, &width, &trash, NULL, NULL);
		printf("text: %s, x_alignment = 2, x_start: %d, new x_start: %d,x_end: %d, width: %d\n", text, x_start, (x_end-x_start)-width, x_end, width);
		x_start += (x_end-x_start)-width;
	} else if (x_alignment == 0)
		printf("text: %s, x_alignment = 0, x_start: %d, new x_start: %d,x_end: %d, width: %d\n", text, x_start, (x_end-x_start)-width, x_end, width);
	if (y_alignment == 1 && y_end != -1) {
		gtk_widget_measure(*l, GTK_ORIENTATION_VERTICAL, -1, &height, &trash, NULL, NULL);
		printf("text: %s, y_alignment = 1, y_start: %d, new y_start: %d,y_end: %d, height: %d\n", text, y_start, (y_end-y_start)-height, y_end, height);
		y_start += ((y_end-y_start)-height)/2;
	} else if (y_alignment == 2 && y_end != -1) {
		gtk_widget_measure(*l, GTK_ORIENTATION_VERTICAL, -1, &height, &trash, NULL, NULL);
		printf("text: %s, y_alignment = 2, y_start: %d, new y_start: %d,y_end: %d, y_end-y_start: %d, height: %d\n", text, y_start, y_start + (y_end-y_start)-height, y_end, (y_end-y_start), height);
		y_start += (y_end-y_start)-height;
	} else if (y_alignment == 0)
		printf("text: %s, y_alignment = 0, y_start: %d, new y_start: %d,y_end: %d, height: %d\n", text, y_start, (y_end-y_start)-height, y_end, height);

	gtk_fixed_move(GTK_FIXED(fixed), *l, x_start, y_start);
	gtk_widget_measure(*l, GTK_ORIENTATION_VERTICAL, -1, &height, &trash, NULL, NULL);
	printf("x_start: %d, y_start: %d, height: %d\n", x_start, y_start, height);
}

void update_button(GtkWidget **b, GtkWidget *fixed, int x_start, int x_end, int y_start, int y_end){
	gtk_fixed_move(GTK_FIXED(fixed), *b, x_start, y_start);
	gtk_widget_set_size_request(*b, x_end-x_start, y_end-y_start);
}

void update_display_window(){
	//Display the Teamnames
	char teamname[TEAMS_NAME_MAX_LEN];
	strcpy(teamname, md.teams[md.games[md.cur.gameindex].t1_index].name);
	int fontsize = biggest_fontsize_possible(teamname, 300, wd.width/2 - wd.width/20, wd.height/6 - 10, true);
	strcpy(teamname, md.teams[md.games[md.cur.gameindex].t2_index].name);
	int fontsize2 = biggest_fontsize_possible(teamname, 300, wd.width/2 - wd.width/20, wd.height/6 - 10, true);
	if (fontsize2 < fontsize)
		fontsize = fontsize2;

	char s[TEAMS_NAME_MAX_LEN];
	if(md.cur.halftime)
		strcpy(s, md.teams[md.games[md.cur.gameindex].t1_index].name);
	else
		strcpy(s, md.teams[md.games[md.cur.gameindex].t2_index].name);
	update_label(&wd.l.t1.name, wd.fixed, wd.width/40, wd.width/40+(wd.width/2 - wd.width/20), 10, wd.height/6, s, fontsize, false, true, 1, 2);

	update_label(&wd.l.colon, wd.fixed, wd.width/40+(wd.width/2 - wd.width/20), wd.width/2 + wd.width/40, 0, wd.height/6, ":", fontsize, false, true, 1, 2);

	if(md.cur.halftime)
		strcpy(s, md.teams[md.games[md.cur.gameindex].t2_index].name);
	else
		strcpy(s, md.teams[md.games[md.cur.gameindex].t1_index].name);
	update_label(&wd.l.t2.name, wd.fixed, wd.width/2 + wd.width/40, wd.width - wd.width/40, 10, wd.height/6, s, fontsize, false, true, 1, 2);

	//Display the Scores
	if(md.cur.halftime)
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t1);
	else
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t2);
	update_label(&wd.l.t1.score, wd.fixed, 0, wd.width/2, wd.height/5, wd.height/2, s, 350, false, true, 1, 1);

	if(md.cur.halftime)
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t2);
	else
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t1);
	update_label(&wd.l.t2.score, wd.fixed, wd.width/2, wd.width-1, wd.height/6, wd.height/2, s, 350, false, true, 1, 1);

	sprintf(s, "%01d:%02d", md.cur.time/60, md.cur.time%60);
	update_label(&wd.l.time, wd.fixed, 0, wd.width-1, wd.height/2, wd.height-1, s, 350, false, true, 1, 1);
}

void update_input_window(){
	//Display the Teamnames
	char teamname[TEAMS_NAME_MAX_LEN];
	strcpy(teamname, md.teams[md.games[md.cur.gameindex].t1_index].name);
	int fontsize = biggest_fontsize_possible(teamname, 300, wi.width/2 - (wi.width/20 + wi.width/40 + wi.width/30 + wi.width/40), wi.height/6 - 10, true);
	strcpy(teamname, md.teams[md.games[md.cur.gameindex].t2_index].name);
	int fontsize2 = biggest_fontsize_possible(teamname, 300, wi.width/2 - (wi.width/20 + wi.width/40 + wi.width/30 + wi.width/40), wi.height/6 - 10, true);
	if (fontsize2 < fontsize)
		fontsize = fontsize2;
	printf("fontsize: %d, %d\n", fontsize, fontsize2);
	char s[TEAMS_NAME_MAX_LEN];

	//Display prev game;
	update_button(&wi.b.game.prev, wi.fixed, wi.width/80, wi.width/20, 20, 20+fontsize);

	//Display Team 1 Name
	if(md.cur.halftime)
		strcpy(s, md.teams[md.games[md.cur.gameindex].t2_index].name);
	else
		strcpy(s, md.teams[md.games[md.cur.gameindex].t1_index].name);
	update_label(&wi.l.t1.name, wi.fixed, wi.width/20 + wi.width/40, wi.width/2 - (wi.width/30 + wi.width/40), 10, wi.height/6, s, fontsize, false, true, 1, 0);

	//Display switch sides;
	update_button(&wi.b.game.switch_sides, wi.fixed, wi.width/2 - wi.width/30, wi.width/2 + wi.width/30, 20, 20+fontsize);

	//Display Team 2 Name
	if(md.cur.halftime)
		strcpy(s, md.teams[md.games[md.cur.gameindex].t1_index].name);
	else
		strcpy(s, md.teams[md.games[md.cur.gameindex].t2_index].name);
	update_label(&wi.l.t2.name, wi.fixed, wi.width/2 + wi.width/30 + wi.width/40, wi.width - (wi.width/20 + wi.width/40), 10, wi.height/6, s, fontsize, false, true, 1, 0);

	//Display next game;
	update_button(&wi.b.game.next, wi.fixed, wi.width - wi.width/20, wi.width - wi.width/80, 20, 20+fontsize);

	//Display the Scores
	//Display Score Team 1
	if(md.cur.halftime)
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t2);
	else
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t1);
	update_label(&wi.l.t1.score, wi.fixed, 0, wi.width/2, wi.height/5, wi.height/2+wi.height/8, s, 350, true, true, 1, 2);

	//Display +- Score Team 1
	int width, height, trash;
	gtk_widget_measure(wi.l.t1.score, GTK_ORIENTATION_HORIZONTAL, -1, &width, &trash, NULL, NULL);
	gtk_widget_measure(wi.l.t1.score, GTK_ORIENTATION_VERTICAL, -1, &height, &trash, NULL, NULL);
	//update_button(&wi.b.t1.score_plus, wi.fixed, 0+(wi.width/2 - width)/2, wi.width/2-(wi.width/2 - width)/2, wi.height/5, wi.height/5 + ((wi.height/2+wi.height/8) - wi.height/5)-height);
	update_button(&wi.b.t1.score_plus, wi.fixed, 0+(wi.width/2 - width)/2, wi.width/2-(wi.width/2 - width)/2, wi.height/5, wi.height/5 + 80);
	update_button(&wi.b.t1.score_minus, wi.fixed, 0+(wi.width/2 - width)/2, wi.width/2-(wi.width/2 - width)/2, wi.height/2 + wi.height/8 - 60, wi.height/2 + wi.height/8 + 20);

	//Display Score Team 2
	if(md.cur.halftime)
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t1);
	else
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t2);
	update_label(&wi.l.t2.score, wi.fixed, wi.width/2, wi.width-1, wi.height/5, wi.height/2+wi.height/8, s, 350, true, true, 1, 2);

	//Display +- Score Team 2
	gtk_widget_measure(wi.l.t2.score, GTK_ORIENTATION_HORIZONTAL, -1, &width, &trash, NULL, NULL);
	gtk_widget_measure(wi.l.t2.score, GTK_ORIENTATION_VERTICAL, -1, &height, &trash, NULL, NULL);
	//update_button(&wi.b.t2.score_plus, wi.fixed, 0+(wi.width/2 - width)/2, wi.width/2-(wi.width/2 - width)/2, wi.height/5, wi.height/5 + ((wi.height/2+wi.height/8) - wi.height/5)-height);
	update_button(&wi.b.t2.score_plus, wi.fixed, wi.width/2+(wi.width/2 - width)/2, wi.width - (wi.width/2 - width)/2, wi.height/5, wi.height/5 + 80);
	update_button(&wi.b.t2.score_minus, wi.fixed, wi.width/2+(wi.width/2 - width)/2, wi.width - (wi.width/2 - width)/2, wi.height/2 + wi.height/8 - 60, wi.height/2 + wi.height/8 + 20);

	//Display Time
	sprintf(s, "%01d:%02d", md.cur.time/60, md.cur.time%60);
	update_label(&wi.l.time, wi.fixed, 0, wi.width-1, wi.height/2+wi.height/5, wi.height-1, s, 350, true, true, 1, 2);

	//Display +- Time
	gtk_widget_measure(wi.l.time, GTK_ORIENTATION_HORIZONTAL, -1, &width, &trash, NULL, NULL);
	gtk_widget_measure(wi.l.time, GTK_ORIENTATION_VERTICAL, -1, &height, &trash, NULL, NULL);
	//update_button(&wi.b.t2.score_plus, wi.fixed, 0+(wi.width/2 - width)/2, wi.width/2-(wi.width/2 - width)/2, wi.height/5, wi.height/5 + ((wi.height/2+wi.height/8) - wi.height/5)-height);
	update_button(&wi.b.time.minus, wi.fixed, wi.width/2 - width/2 - 160, wi.width/2 - width/2, wi.height/2+wi.height/5, wi.height-1);
	update_button(&wi.b.time.plus, wi.fixed, wi.width/2 + width/2, wi.width/2 + width/2 + 160, wi.height/2+wi.height/5, wi.height-1);

	update_button(&wi.b.time.toggle_pause, wi.fixed, wi.width/2 - width/2 + 10, wi.width/2-5, wi.height/2+wi.height/5, wi.height/2+wi.height/5+60);
	update_button(&wi.b.time.reset, wi.fixed, wi.width/2 + 5, wi.width/2 + width/2 - 10, wi.height/2+wi.height/5, wi.height/2+wi.height/5+60);

	//Display the Buttons
	//Display prev game;
	//Display next game;
	//Display Goal +
}

//fontsize is only used for icons atm, cry about it
void button_new(GtkWidget **b, GtkWidget *fixed, void (*callback_func)(), char *text, bool text_is_icon, int fontsize){
	if(text_is_icon){
		GtkWidget *i = gtk_image_new_from_icon_name(text);
		gtk_image_set_pixel_size(GTK_IMAGE(i), fontsize);
		*b = gtk_button_new();
		gtk_button_set_child(GTK_BUTTON(*b), i);
	} else {
		*b = gtk_button_new_with_label(text);
	}
	gtk_fixed_put(GTK_FIXED(fixed), *b, 0, 0);
	g_signal_connect(*b, "clicked", G_CALLBACK(callback_func), NULL);
}

void label_new(GtkWidget **l, GtkWidget *fixed){
	*l = gtk_label_new(NULL);
	gtk_fixed_put(GTK_FIXED(fixed), *l, 0, 0);
}

// Function to create the display window
w_input create_input_window(const GtkApplication *app) {
    wi.w = gtk_application_window_new(GTK_APPLICATION(app));
	wi.width = 1920;
	wi.height = 1080;
    gtk_window_set_title(GTK_WINDOW(wi.w), "Scoreboard Input");
    gtk_window_set_default_size(GTK_WINDOW(wi.w), wi.width, wi.height);

	//TODO FINAL This shit doesnt work, it still uses the old width and height when making the callback
	//g_signal_connect(wd.w, "notify::width", G_CALLBACK(update_display_window), NULL);
	//g_signal_connect(wd.w, "notify::height", G_CALLBACK(update_display_window), NULL);
	//g_signal_connect(wd.w, "notify::fullscreened", G_CALLBACK(update_display_window), NULL);
	//g_signal_connect(wd.w, "size-allocate", G_CALLBACK(update_display_window), NULL);


	wi.fixed = gtk_fixed_new();
	gtk_window_set_child(GTK_WINDOW(wi.w), wi.fixed);

	GtkCssProvider *provider = gtk_css_provider_new();
	gtk_css_provider_load_from_path(provider, "rentnerend/style.css");
	gtk_style_context_add_provider_for_display(gdk_display_get_default(), GTK_STYLE_PROVIDER(provider),GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);


	label_new(&wi.l.t1.name, wi.fixed);
	label_new(&wi.l.t2.name, wi.fixed);
	label_new(&wi.l.t1.score, wi.fixed);
	label_new(&wi.l.t2.score, wi.fixed);
	label_new(&wi.l.time, wi.fixed);
	//Create Buttons
	button_new(&wi.b.t1.score_minus, wi.fixed, btn_cb_t1_score_minus, "list-remove", true, 32);
	button_new(&wi.b.t1.score_plus, wi.fixed, btn_cb_t1_score_plus, "list-add", true, 32);
	button_new(&wi.b.t2.score_minus, wi.fixed, btn_cb_t2_score_minus, "list-remove", true, 32);
	button_new(&wi.b.t2.score_plus, wi.fixed, btn_cb_t2_score_plus, "list-add", true, 32);

	button_new(&wi.b.game.next, wi.fixed, btn_cb_game_next, "go-next", true, 32);

	button_new(&wi.b.game.prev, wi.fixed, btn_cb_game_prev, "go-previous", true, 32);
	button_new(&wi.b.game.switch_sides, wi.fixed, btn_cb_game_switch_sides, "object-flip-horizontal", true, 32);
	button_new(&wi.b.time.plus, wi.fixed, btn_cb_time_plus, "list-add", true, 32);
	button_new(&wi.b.time.minus, wi.fixed, btn_cb_time_minus, "list-remove", true, 32);
	button_new(&wi.b.time.toggle_pause, wi.fixed, btn_cb_time_toggle_pause, "media-playback-pause", true, 32);
	button_new(&wi.b.time.reset, wi.fixed, btn_cb_time_reset, "view-refresh", true, 32);
	/*
	wi.b.card.yellow = gtk_button_new_with_label("GELBE KARTE");
	gtk_fixed_put(GTK_FIXED(wi.fixed), wi.b.card.yellow, 0, 0);
	wi.b.card.red = gtk_button_new_with_label("ROTE KARTE");
	gtk_fixed_put(GTK_FIXED(wi.fixed), wi.b.card.red, 0, 0);
	*/

	update_input_window();
    return wi;
}

// Function to create the display window
w_display create_display_window(const GtkApplication *app) {
    wd.w = gtk_application_window_new(GTK_APPLICATION(app));
	wd.width = 1920;
	wd.height = 1080;
    gtk_window_set_title(GTK_WINDOW(wd.w), "Scoreboard Display");
    gtk_window_set_default_size(GTK_WINDOW(wd.w), wd.width, wd.height);

	//TODO FINAL This shit doesnt work, it still uses the old width and height when making the callback
	//g_signal_connect(wd.w, "notify::width", G_CALLBACK(update_display_window), NULL);
	//g_signal_connect(wd.w, "notify::height", G_CALLBACK(update_display_window), NULL);
	//g_signal_connect(wd.w, "notify::fullscreened", G_CALLBACK(update_display_window), NULL);
	//g_signal_connect(wd.w, "size-allocate", G_CALLBACK(update_display_window), NULL);


	wd.fixed = gtk_fixed_new();
	gtk_window_set_child(GTK_WINDOW(wd.w), wd.fixed);

	label_new(&wd.l.t1.name, wd.fixed);
	label_new(&wd.l.t2.name, wd.fixed);
	label_new(&wd.l.t1.score, wd.fixed);
	label_new(&wd.l.t2.score, wd.fixed);
	label_new(&wd.l.time, wd.fixed);
	label_new(&wd.l.colon, wd.fixed);

	update_display_window();
    return wd;
}

gboolean update_timer(){
	if(!md.cur.pause && md.cur.time > 0){
		md.cur.time--;
		update_display_window();
		update_input_window();
	}
	if(md.cur.time == 0)
		md.cur.pause = true;
	return G_SOURCE_CONTINUE;
}

static void on_activate(const GtkApplication *app) {
	load_json(JSON_PATH);
	md.cur.gameindex = 0;

    create_display_window(app);
    create_input_window(app);
    //GtkWidget *input_window = create_input_window();

    //gtk_window_present(GTK_WINDOW(input_window));
    gtk_window_present(GTK_WINDOW(wd.w));
    gtk_window_present(GTK_WINDOW(wi.w));

	g_timeout_add_seconds(1, update_timer, NULL);
}

int main(int argc, char **argv) {
	GtkApplication *app = gtk_application_new("de.mminl.interscore", G_APPLICATION_DEFAULT_FLAGS);
	g_signal_connect(app, "activate", G_CALLBACK(on_activate), NULL);
	const int stat = g_application_run(G_APPLICATION(app), argc, argv);
	g_object_unref(app);
    return stat;
}
