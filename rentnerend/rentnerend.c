#include <gtk/gtk.h>
#include <json-c/json.h>
#include <json-c/json_object.h>
//#include "../mongoose/mongoose.h"

#include "../config.h"

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;

typedef struct {
	int width;
	int height;
	GtkWidget *w;
	GtkWidget *fixed;
	GtkWidget *l_t1;
	GtkWidget *l_t2;
	GtkWidget *l_t1_score;
	GtkWidget *l_t2_score;
	GtkWidget *l_time;
} w_display;

typedef struct {
	w_display *d;
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
	} cur;
	Game *games;
	u8 games_count;
	Team *teams;
	u8 teams_count;
	Player *players;
	u8 players_count;
} Matchday;

Matchday md;
w_display wd, wi;

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
int biggest_fontsize_possible(char *text, int max_fontsize, int x, bool bold) {
	int width, fontsize = max_fontsize+1;
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
	} while (width > x);
	gtk_widget_set_visible(l_decoy, FALSE);
	return fontsize;
}

//alignment: 0:= left, 1:= center, 2:=right
void update_label(GtkWidget **l, GtkWidget *fixed, int x_start, int x_end, int y_start, int y_end, char *text, int fontsize, bool variable_fontsize, bool bold, u8 x_alignment, u8 y_alignment) {
	printf("text: %s\n", text);
	char s[strlen(text)+100];
	if (variable_fontsize)
		fontsize = biggest_fontsize_possible(text, fontsize, x_end-x_start, bold);
	char bold_str[] = "weight='bold'";
	if (!bold)
		bold_str[0] = '\0';
	sprintf(s, "<span %s font='%d'>%s</span>", bold_str, fontsize, text);
	gtk_label_set_markup(GTK_LABEL(*l), s);

	int width, height, trash;
	if (x_alignment == 1 && x_end != -1) {
		gtk_widget_measure(*l, GTK_ORIENTATION_HORIZONTAL, -1, &width, &trash, NULL, NULL);
		printf("x_alignment = 1, x_start: %d, new x_start: %d,x_end: %d, width: %d\n", x_start, (x_end-x_start)-width, x_end, width);
		x_start += ((x_end-x_start)-width)/2;
	} else if (x_alignment == 2 && x_end != -1) {
		gtk_widget_measure(*l, GTK_ORIENTATION_HORIZONTAL, -1, &width, &trash, NULL, NULL);
		printf("x_alignment = 2, x_start: %d, new x_start: %d,x_end: %d, width: %d\n", x_start, (x_end-x_start)-width, x_end, width);
		x_start += (x_end-x_start)-width;
	}
	if (y_alignment == 1 && y_end != -1) {
		gtk_widget_measure(*l, GTK_ORIENTATION_VERTICAL, -1, &height, &trash, NULL, NULL);
		printf("y_alignment = 1, y_start: %d, new y_start: %d,y_end: %d, height: %d\n", y_start, (y_end-y_start)-height, y_end, height);
		y_start += ((y_end-y_start)-height)/2;
	} else if (y_alignment == 2 && y_end != -1) {
		gtk_widget_measure(*l, GTK_ORIENTATION_VERTICAL, -1, &height, &trash, NULL, NULL);
		printf("y_alignment = 2, y_start: %d, new y_start: %d,y_end: %d, height: %d\n", y_start, (y_end-y_start)-height, y_end, height);
		y_start += (y_end-y_start)-height;
	}

	gtk_fixed_move(GTK_FIXED(fixed), *l, x_start, y_start);
}

void update_display_window(){
	int width = gtk_widget_get_width(wd.w);
	int height = gtk_widget_get_height(wd.w);
	printf("width: %d; height: %d\n", width, height);
	//Display the Teamnames
	char teamname[TEAMS_NAME_MAX_LEN];
	strcpy(teamname, md.teams[md.games[md.cur.gameindex].t1_index].name);
	int fontsize = biggest_fontsize_possible(teamname, 300, wd.width/2 - wd.width/20, true);
	strcpy(teamname, md.teams[md.games[md.cur.gameindex].t2_index].name);
	int fontsize2 = biggest_fontsize_possible(teamname, 300, wd.width/2 - wd.width/20, true);
	if (fontsize2 < fontsize)
		fontsize = fontsize2;

	update_label(&wd.l_t1, wd.fixed, wd.width/40, wd.width/40+(wd.width/2 - wd.width/20), 10, wd.height/6, md.teams[md.games[md.cur.gameindex].t1_index].name, fontsize, false, true, 1, 2);

	GtkWidget *l = gtk_label_new(NULL);
	gtk_fixed_put(GTK_FIXED(wd.fixed), l, 0, 0);
	update_label(&l, wd.fixed, wd.width/40+(wd.width/2 - wd.width/20), wd.width/2 + wd.width/40, 0, wd.height/6, ":", fontsize, false, true, 1, 2);

	update_label(&wd.l_t2, wd.fixed, wd.width/2 + wd.width/40, wd.width - wd.width/40, 10, wd.height/6, md.teams[md.games[md.cur.gameindex].t2_index].name, fontsize, false, true, 1, 2);

	//Display the Scores
	char s[4];
	sprintf(s, "%d", md.games[md.cur.gameindex].score.t1);
	update_label(&wd.l_t1_score, wd.fixed, 0, wd.width/2, wd.height/5, wd.height/2, s, 350, false, true, 1, 1);

	sprintf(s, "%d", md.games[md.cur.gameindex].score.t2);
	update_label(&wd.l_t2_score, wd.fixed, wd.width/2, wd.width-1, wd.height/6, wd.height/2, s, 350, false, true, 1, 1);

	sprintf(s, "%d:%d", md.cur.time/60, md.cur.time%60);
	update_label(&wd.l_time, wd.fixed, 0, wd.width-1, wd.height/2, wd.height-1, s, 350, false, true, 1, 1);
}

void update_input_window(){
	//TODO STARTHERE
	int width = gtk_widget_get_width(wd.w);
	int height = gtk_widget_get_height(wd.w);
	printf("width: %d; height: %d\n", width, height);
	//Display the Teamnames
	char teamname[TEAMS_NAME_MAX_LEN];
	strcpy(teamname, md.teams[md.games[md.cur.gameindex].t1_index].name);
	int fontsize = biggest_fontsize_possible(teamname, 300, wd.width/2 - wd.width/20, true);
	strcpy(teamname, md.teams[md.games[md.cur.gameindex].t2_index].name);
	int fontsize2 = biggest_fontsize_possible(teamname, 300, wd.width/2 - wd.width/20, true);
	if (fontsize2 < fontsize)
		fontsize = fontsize2;

	update_label(&wd.l_t1, wd.fixed, wd.width/40, wd.width/40+(wd.width/2 - wd.width/20), 10, wd.height/6, md.teams[md.games[md.cur.gameindex].t1_index].name, fontsize, false, true, 1, 2);

	GtkWidget *l = gtk_label_new(NULL);
	gtk_fixed_put(GTK_FIXED(wd.fixed), l, 0, 0);
	update_label(&l, wd.fixed, wd.width/40+(wd.width/2 - wd.width/20), wd.width/2 + wd.width/40, 0, wd.height/6, ":", fontsize, false, true, 1, 2);

	update_label(&wd.l_t2, wd.fixed, wd.width/2 + wd.width/40, wd.width - wd.width/40, 10, wd.height/6, md.teams[md.games[md.cur.gameindex].t2_index].name, fontsize, false, true, 1, 2);

	//Display the Scores
	char s[4];
	sprintf(s, "%d", md.games[md.cur.gameindex].score.t1);
	update_label(&wd.l_t1_score, wd.fixed, 0, wd.width/2, wd.height/5, wd.height/2, s, 350, false, true, 1, 1);

	sprintf(s, "%d", md.games[md.cur.gameindex].score.t2);
	update_label(&wd.l_t2_score, wd.fixed, wd.width/2, wd.width-1, wd.height/6, wd.height/2, s, 350, false, true, 1, 1);

	sprintf(s, "%d:%d", md.cur.time/60, md.cur.time%60);
	update_label(&wd.l_time, wd.fixed, 0, wd.width-1, wd.height/2, wd.height-1, s, 350, false, true, 1, 1);
}

// Function to create the display window
w_display create_input_window(const GtkApplication *app) {
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

	wi.l_t1 = gtk_label_new(NULL);
	gtk_fixed_put(GTK_FIXED(wi.fixed), wi.l_t1, 0, 0);
	wi.l_t2 = gtk_label_new(NULL);
	gtk_fixed_put(GTK_FIXED(wi.fixed), wi.l_t2, 0, 0);
	wi.l_t1_score = gtk_label_new(NULL);
	gtk_fixed_put(GTK_FIXED(wi.fixed), wi.l_t1_score, 0, 0);
	wi.l_t2_score = gtk_label_new(NULL);
	gtk_fixed_put(GTK_FIXED(wi.fixed), wi.l_t2_score, 0, 0);
	wi.l_time = gtk_label_new(NULL);
	gtk_fixed_put(GTK_FIXED(wi.fixed), wi.l_time, 0, 0);

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

	wd.l_t1 = gtk_label_new(NULL);
	gtk_fixed_put(GTK_FIXED(wd.fixed), wd.l_t1, 0, 0);
	wd.l_t2 = gtk_label_new(NULL);
	gtk_fixed_put(GTK_FIXED(wd.fixed), wd.l_t2, 0, 0);
	wd.l_t1_score = gtk_label_new(NULL);
	gtk_fixed_put(GTK_FIXED(wd.fixed), wd.l_t1_score, 0, 0);
	wd.l_t2_score = gtk_label_new(NULL);
	gtk_fixed_put(GTK_FIXED(wd.fixed), wd.l_t2_score, 0, 0);
	wd.l_time = gtk_label_new(NULL);
	gtk_fixed_put(GTK_FIXED(wd.fixed), wd.l_time, 0, 0);

	update_display_window();
    return wd;
}

static void on_activate(const GtkApplication *app) {
	load_json(JSON_PATH);
	md.cur.gameindex = 0;

    create_display_window(app);
    create_input_window(app);
    //GtkWidget *input_window = create_input_window();

    //gtk_window_present(GTK_WINDOW(input_window));
    gtk_window_present(GTK_WINDOW(wd.w));
}

int main(int argc, char **argv) {
	GtkApplication *app = gtk_application_new("de.mminl.interscore", G_APPLICATION_DEFAULT_FLAGS);
	g_signal_connect(app, "activate", G_CALLBACK(on_activate), NULL);
	const int stat = g_application_run(G_APPLICATION(app), argc, argv);
	g_object_unref(app);
    return stat;
}
