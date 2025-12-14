// TODO rewrite in zig :(
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/sendfile.h>
#include <errno.h>
#include <pthread.h>
#include <stdbool.h>
#include <json-c/json.h>
#include <json-c/json_object.h>
#include <stdlib.h>
#include <string.h>
#include "mongoose/mongoose.h"

// This define just wipes the export making the num definition c and c++ legal
// while typescript can just use the file. This way we only have to keep track
// of one enum definition instead of 3
#define export
#include "MessageType.ts"
#undef export

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;

struct Client {
	struct mg_connection *con;
	struct Client *next;
};

struct ClientsList {
	struct Client *first;
	struct mg_connection *boss;
};

// Meta
#define EXIT 'q'
#define CONNECT_OBS 'o'
#define PRINT_HELP '?'

#define URL_SERVER_DEFAULT "ws://0.0.0.0:8081"
#define URL_OBS_DEFAULT "http://0.0.0.0:4444"
#define REPLAY_PATH_DEFAULT "/home/obsuser/replays"

char *URL_SERVER = NULL;
char *URL_OBS = NULL;
char *REPLAY_PATH = NULL;

void obs_switch_scene(void *scene_name);
// Return if successful 1 is successfull
bool obs_replay_start();

u8 gameindex = 0;
u8 replays_count[1]; //TODO find out length efficiently

bool running = true;
// We pretty much have to do this in gloabl scope bc at least ev_handler (TODO FINAL DECIDE is this possible/better with smaller scope)
struct ClientsList clients = {.first = NULL, .boss = NULL};
struct mg_connection *con_obs = NULL;
struct mg_mgr mgr_svr, mgr_obs;
time_t last_obs_con_attempt = 0;
const int obs_reconnect_interval = 5; // in sec

bool replays_instant_working = true;
bool replays_game_working = true;
bool replay_buffer_status = false;

void die(char *error, int retval) {
	fprintf(stderr, "CRIT: %s\n", error);
	exit(retval);
}

// 0 is success
int copy_file(const char *src, const char *dst) {
    int source = open(src, O_RDONLY);
    if (source < 0) return -1;

    int dest = open(dst, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (dest < 0) {
        close(source);
        return -1;
    }

    struct stat stat_source;
    fstat(source, &stat_source);

    off_t bytes_copied = 0;
    ssize_t result = sendfile(dest, source, &bytes_copied, stat_source.st_size);

    close(source);
    close(dest);
    return result;
}

void obs_send_cmd(const char *s) {
	printf("DEBUG: Sending OBS a Message: %s\n", s);
	if(con_obs == NULL) {
		printf("WARN: Cant send command, OBS is not connected!\n");
		return;
	}
	mg_ws_send(con_obs, s, strlen(s), WEBSOCKET_OP_TEXT);
}

//message is allowed to be non null-terminated. Therefor the len as arg
bool ws_send(struct mg_connection *con, char *message, int len, int op) {
	if (con == NULL) {
		printf("WARN: client is not connected, couldnt send Message: '%*s'\n", len, message);
		return false;
	}

	const unsigned long sent = mg_ws_send(con, message, len, op);
	if (sent != (unsigned long) len) {
		fprintf(stderr, "ERR: Expected to send %dB, got %luB\n", len, sent);
		return false;
	}
	return true;
}

bool create_replay_dirs() {
	// Create Replay Paths if not already existing
	if (mkdir(REPLAY_PATH, 0755) == -1 && errno != EEXIST) {
		printf("WARN: Cant create replay directory %s: %s\n", REPLAY_PATH, strerror(errno));
		replays_instant_working = false;
		replays_game_working = false;
		return false;
	}

	char last_game_path[strlen(REPLAY_PATH) + strlen("/last-game") + 1];
	sprintf(last_game_path, "%s/last-game", REPLAY_PATH);
	if (mkdir(last_game_path, 0755) == -1 && errno != EEXIST) {
		printf("WARN: Cant create replay directory %s: %s\n", last_game_path, strerror(errno));
		replays_game_working = false;
		return false;
	}

	return true;
}

void run_system(void *s) {
	printf("INFO: Running System CMD: %s\n", (char*)s);
	printf("INFO: CMD Return Value: %d", system((char*)s));
}

void handle_message(enum MessageType *msg, int msg_len, struct mg_connection * con) {
	printf("INFO: Received a Input from con %lu: %d\n", con->id, *msg);
	switch (*msg) {
		// All of these cases should be forwarded to frontend
		case PLS_SEND_SIDES_SWITCHED:
		case PLS_SEND_GAMEPART:
		case PLS_SEND_GAMEINDEX:
		case PLS_SEND_IS_PAUSE:
		case PLS_SEND_TIME:
		case PLS_SEND_JSON:
		case PLS_SEND_OBS_REPLAY_ON:
		case PLS_SEND_OBS_STREAM_ON:
		case PLS_SEND_WIDGET_AD_ON:
		case PLS_SEND_WIDGET_GAMESTART_ON:
		case PLS_SEND_WIDGET_GAMEPLAN_ON:
		case PLS_SEND_WIDGET_LIVETABLE_ON:
		case PLS_SEND_WIDGET_SCOREBOARD_ON:
		case PLS_SEND_GAME_ACTION:
			printf("DEBUG: clients.boss: %p\n", clients.boss);
			ws_send(clients.boss, (char *)msg, msg_len, WEBSOCKET_OP_BINARY);
			break;

		case PLS_SEND_IM_BOSS: {
			char tmp[2] = {DATA_IM_BOSS, con == clients.boss};
			ws_send(con, tmp, 2, WEBSOCKET_OP_BINARY);
			break;

		} case DATA_OBS_STREAM_ON: {
			if(msg_len < 2) {
				printf("WARN: Received DATA_OBS_STREAM_ON without data about the Status\n");
				break;
			}
			if(msg[1])
				obs_send_cmd("{\"op\": 6, \"d\": {\"requestType\": \"StartStream\", \"requestId\": \"1\"}}");
			else
				obs_send_cmd("{\"op\": 6, \"d\": {\"requestType\": \"StopStream\", \"requestId\": \"2\"}}");
			break;
		}
		case DATA_OBS_REPLAY_ON: {
			if(!replays_instant_working) break;
			if(msg_len < 2) {
				printf("WARN: Received DATA_OBS_STREAM_ON without data about the Status\n");
				break;
			}
			if(msg[1])
				// Tell OBS to save replay buffer
				obs_send_cmd("{\"op\": 6, \"d\": {\"requestType\": \"SaveReplayBuffer\", \"requestId\": \"save_replay\"}}");
			else
				obs_switch_scene("live");
			break;
		}
		case IM_THE_BOSS:
			if(msg_len < 2 || !msg[1]) { printf("Boss sent illegal message\n"); break;}
			if(clients.boss != NULL) {
				printf("WARN: Con %lu is trying to be boss, but %lu is already!\n", con->id, clients.boss->id);
				break;
			}
			printf("setting boss: %p\n", con);
			clients.boss = con;
			char tmp[] = {DATA_IM_BOSS, true};
			mg_ws_send(clients.boss, &tmp, 2, WEBSOCKET_OP_BINARY);
			break;
		case DATA_GAMEINDEX:
			printf("INFO: Received DATA: Gameindex: %d\n", ((char *)msg)[1]);
			gameindex = msg[1];
			// Now we go into default
			__attribute__((fallthrough)); // silence compiler warning
		default:
			for(struct Client *c = clients.first; c != NULL; c = c->next) {
				if (c->con == clients.boss) continue;
				printf("sending to :%lu\n", c->con->id);
				const bool ret = ws_send(c->con, (char *)msg, msg_len, WEBSOCKET_OP_BINARY);
				if (!ret) printf("\n\n\nOH NO BROOOOO SOMETHING FAILED BROOOO\n");
			}
			break;
	}
}

void obs_switch_scene(void *scene_name) {
	char cmd[strlen(scene_name)+256];
    snprintf(cmd, sizeof(cmd), "{\"op\": 6, \"d\": {\"requestType\": \"SetCurrentProgramScene\", \"requestId\": \"switch_scene\", \"requestData\": {\"sceneName\": \"%s\"}}}", (char *)scene_name);
	obs_send_cmd(cmd);
}

// This function plays the replay in REPLAY_PATH/instantreplay.mkv
bool obs_replay_start() {
	const int replay_len = 3; // sec
	const float replay_speed = 0.75;
	const int base_delay = 1000; // ms

	printf("DEBUG: OBS_REPLAY_START 0\n");

	// Check if video is there
	char instantreplay_path[strlen(REPLAY_PATH) + strlen("/instantreplay.mkv") + 1];
	strcpy(instantreplay_path, REPLAY_PATH);
	strcat(instantreplay_path, "/instantreplay.mkv");
	if (access(instantreplay_path, F_OK) != 0) return false;

	printf("DEBUG: OBS_REPLAY_START 1\n");
	// cut video to 3sec
	char instantreplay_path_short[strlen(REPLAY_PATH) + strlen("/instantreplay_short.mkv") + 1];
	strcpy(instantreplay_path_short, REPLAY_PATH);
	strcat(instantreplay_path_short, "/instantreplay_short.mkv");

	printf("DEBUG: OBS_REPLAY_START 2\n");
	char cmd[512 + strlen(instantreplay_path) * 2];
	snprintf(cmd, sizeof(cmd), "ffmpeg -y -sseof -%d -i \"%s\" -c:v libx264 -preset veryfast -c:a aac \"%s\"", replay_len, instantreplay_path, instantreplay_path_short);
	if (system(cmd) != 0) {
		fprintf(stderr, "WARN: Couldnt shorten the instantreplay! Aborting Replay\n");
		return false;
	}

	// TODO DECIDE check if video is exactly the length we want?

	printf("DEBUG: OBS_REPLAY_START 3\n");
	// change scene to replay
	//obs_switch_scene("replay");
	mg_timer_add(&mgr_obs, base_delay, 0, obs_switch_scene, "replay");
	// change scene to live 3sec later
	mg_timer_add(&mgr_obs, base_delay+replay_len*1000/replay_speed - 100, 0, obs_switch_scene, "live");

	//
	// Now we save the instantreplay to its game replay folder
	//
	printf("DEBUG: OBS_REPLAY_START 4\n");
	if(!replays_game_working) return true;

	printf("DEBUG: OBS_REPLAY_START 5\n");
	// Create gamepath (even if already existent bc its easier)
	char gamepath[strlen(REPLAY_PATH) + strlen("/game_00") + 1];
	sprintf(gamepath, "%s/game_%02d", REPLAY_PATH, gameindex);
	if (mkdir(gamepath, 0755) == -1 && errno != EEXIST) {
		fprintf(stderr, "WARN: Cant create replay directory %s: %s\n", gamepath, strerror(errno));
		replays_game_working = false;
		return true;
	}

	printf("DEBUG: OBS_REPLAY_START 6\n");
	// Check how many replays there are already
	char gamereplaypath[strlen(gamepath) + strlen("/replay_00.mkv")];
	sprintf(gamereplaypath, "%s/replay_00.mkv", gamepath);
	int replay_count;
	for(replay_count = 0; !access(gamereplaypath, F_OK) ; replay_count++)
		sprintf(gamereplaypath, "%s/replay_%02d.mkv", gamepath, replay_count+1);

	printf("DEBUG: OBS_REPLAY_START 7\n");
	// copy replay to the gamepath
	if(copy_file(instantreplay_path, gamereplaypath) != 0) {
		fprintf(stderr, "WARN: Cant copy replay into game folder: '%s' -> '%s'\n", instantreplay_path, gamereplaypath);
		return true;
	}

	printf("DEBUG: OBS_REPLAY_START 8\n");
	return true;
}

void ev_handler_client(struct mg_connection *con, int ev, void *ev_data) {
	switch(ev) {
	case MG_EV_CONNECT:
        printf("INFO: Connected to OBS WebSocket server\n");
		break;
	case MG_EV_WS_OPEN:
        printf("INFO: OBS WebSocket handshake completed\n");
        con_obs = con;  // Save the connection
		obs_send_cmd("{\"op\": 1, \"d\": {\"rpcVersion\": 1, \"eventSubscriptions\": 255}}");
		//obs_send_cmd("{\"op\": 6, \"d\": {\"requestType\": \"StartReplayBuffer\", \"requestId\": \"start_buffer\"}}");
		break;
	case MG_EV_WS_MSG: {
        struct mg_ws_message *wm = (struct mg_ws_message *)ev_data;
		char *msg = malloc(wm->data.len+1);
		memcpy(msg, wm->data.buf, wm->data.len);
		msg[wm->data.len] = '\0';
		printf("DEBUG: Received MSG from OBS:\n%s\n", msg);
		if (strstr(msg, "\"eventType\":\"ReplayBufferSaved\"")) { // TODO DECIDE extract instantreplaypath instead of hardcoding it?
		// {"d":{"eventData":{"savedReplayPath":"/home/obsuser/instantreplay.mkv"},"eventIntent":64,"eventType":"ReplayBufferSaved"},"op":5}
			printf("DEBUG: Got positive SaveReplayBuffer response\n");
			obs_replay_start();
		} else if(strstr(msg, "\"requestType\":\"StartReplayBuffer\"")) {
			// If the StartReplayBuffer is 100(started)/500(already started) we double check with a GetReplayBufferStatus request
			// because especially 100 can be a fucking lie and doesnt mean shit. GetReplayBufferStatus is reliable (see next else if)
			if(strstr(msg, "\"result\":true") || strstr(msg, "\"code\":500"))
				obs_send_cmd("{\"op\": 6, \"d\": {\"requestType\": \"GetReplayBufferStatus\", \"requestId\": \"what_buffer\"}}");
		} else if(strstr(msg, "\"requestType:\":\"GetReplayBufferStatus\"")) {
			replay_buffer_status = strstr(msg, "\"outputActive\":true");
			printf("INFO: OBS Replay buffer is now: %s\n", replay_buffer_status ? "on" : "off");
		}
		break;
	}
	case MG_EV_CLOSE:
        printf("INFO: OBS WebSocket connection closed\n");
		last_obs_con_attempt = time(NULL);
		con_obs = NULL;
		break;
	// Signals not worth logging
	case MG_EV_OPEN:
	case MG_EV_POLL:
	case MG_EV_READ:
	case MG_EV_WRITE:
	case MG_EV_HTTP_HDRS:
	case MG_EV_WS_CTL:
	case MG_EV_ERROR:
	case MG_EV_RESOLVE:
		break;
	default:
		printf("WARN: Ignoring unknown signal from OBS: %d \n", ev);
	}
}

void ev_handler_server(struct mg_connection *con, int ev, void *p) {
	// TODO FINAL CONSIDER keeping these cases
	switch (ev) {
		case MG_EV_CONNECT:
			printf("INFO: New client connecting...\n");
			break;
		case MG_EV_ACCEPT:
			printf("INFO: New client connected!\n");
			break;
		case MG_EV_CLOSE: {
			if(clients.boss == con) clients.boss = NULL;
			if(clients.first->con == con) {
				struct Client *tmp = clients.first->next;
				free(clients.first);
				clients.first = tmp;
			} else {
				for(struct Client *c = clients.first; c->next != NULL; c = c->next) {
					if(c->next->con == con) {
						struct Client *tmp = c->next->next;
						free(c->next);
						c->next = tmp;
						break;
					}
				}
			}
			printf("WARN: Client %lu disconnected!\n", con->id);
			break;
		}
		case MG_EV_HTTP_MSG: {
			struct mg_http_message *hm = p;
			struct Client *new = malloc(sizeof(struct Client));
			*new = (struct Client){ .con = con, .next = NULL };

			if(clients.first == NULL) clients.first = new;
			else
				for(struct Client *c = clients.first; c != NULL; c = c->next)
					if(c->next == NULL) { c->next = new; break; }

			//TODO check if upgrade is successfull
			mg_ws_upgrade(con, hm, NULL);
			printf("INFO: Client %lu upgraded to WebSocket connection!\n", con->id);
			break;
		}
		case MG_EV_WS_OPEN:
			printf("INFO: New connection opened!\n");
			break;
		case MG_EV_WS_MSG: {
			struct mg_ws_message *m = (struct mg_ws_message *) p;
			// Renterend either sends a button press as a u8 number or a json-string
			// which always begins with '{'
			handle_message((enum MessageType *) m->data.buf, m->data.len, con);
			break;
		}
		// Signals not worth logging
		case MG_EV_OPEN:
		case MG_EV_POLL:
		case MG_EV_READ:
		case MG_EV_WRITE:
		case MG_EV_HTTP_HDRS:
		case MG_EV_WS_CTL:
			break;
		default:
			printf("WARN: Ignoring unknown WS_Signal from client: %d\n", ev);
	}
}

void *mongoose_update(void *) {
	const int replay_buffer_activation_interval = 10; // in sec
	time_t last_replay_buffer_attempt = time(NULL);

	while (running) {
		mg_mgr_poll(&mgr_svr, 20);
		mg_mgr_poll(&mgr_obs, 20);
		if (!con_obs) {
			time_t now = time(NULL);
			if(now - last_obs_con_attempt >= obs_reconnect_interval) {
				printf("INFO: Trying to reconnect to OBS...\n");
				mg_ws_connect(&mgr_obs, URL_OBS, ev_handler_client, NULL, NULL);
				last_obs_con_attempt = now;
			}
		} else if (!replay_buffer_status) {
			time_t now = time(NULL);
			if(now - last_replay_buffer_attempt >= replay_buffer_activation_interval) {
				printf("INFO: Trying to activate the OBS Replay Buffer...\n");
				obs_send_cmd("{\"op\": 6, \"d\": {\"requestType\": \"StartReplayBuffer\", \"requestId\": \"start_buffer\"}}");
				last_replay_buffer_attempt = now;
			}
		}
	}
	return NULL;
}


int main(int argc, char *argv[]) {
	printf("test\n");

	// Check for args
	for (int i=1; i < argc; i++) {
		if (!strcmp(argv[i], "--url-server")) {
			if (argc <= i+1)
				die("Syntax: --url-server <url> needs an url...", EXIT_FAILURE);
			URL_SERVER = malloc(strlen(argv[i+1]) + 1);
			strcpy(URL_SERVER, argv[i+1]);
			i++;
		} else if(!strcmp(argv[i], "--url-obs")) {
			if (argc <= i+1)
				die("Syntax: --url-obs <url> needs an url...", EXIT_FAILURE);
			URL_OBS = malloc(strlen(argv[i+1]) + 1);
			strcpy(URL_OBS, argv[i+1]);
			i++;
		} else if(!strcmp(argv[i], "--replay-path")) {
			if (argc <= i+1)
				die("Syntax: --replay-path <url> needs an path...", EXIT_FAILURE);
			// If the path has a trailing '/' we remove it
			// The rest of the program expects the path to have no trailing '/'
			if (argv[i+1][strlen(argv[i+1])-1] == '/')
				argv[i+1][strlen(argv[i+1])-1] = '\0';
			REPLAY_PATH = malloc(strlen(argv[i+1]) + 1);
			strcpy(REPLAY_PATH, argv[i+1]);
			i++;
		} else {
			die("Syntax: Unknown Argument! Usage: backend <--url-server/--url-obs/--replay-path> <url/path>", EXIT_FAILURE);
		}
	}

	// If Arguments were not provided we use defaults
	if (URL_SERVER == NULL) {
		URL_SERVER = malloc(sizeof(URL_SERVER_DEFAULT) + 1);
		strcpy(URL_SERVER, URL_SERVER_DEFAULT);
	}
	if (URL_OBS == NULL) {
		URL_OBS = malloc(sizeof(URL_OBS_DEFAULT) + 1);
		strcpy(URL_OBS, URL_OBS_DEFAULT);
	}
	if (REPLAY_PATH == NULL) {
		REPLAY_PATH = malloc(sizeof(REPLAY_PATH_DEFAULT) + 1);
		strcpy(REPLAY_PATH, REPLAY_PATH_DEFAULT);
	}

	create_replay_dirs();

	// WebSocket as Client(OBS) stuff
	mg_mgr_init(&mgr_obs);
	mg_ws_connect(&mgr_obs, URL_OBS, ev_handler_client, NULL, NULL);
	last_obs_con_attempt = time(NULL);
	printf("INFO: Trying to connect to OBS...\n");

	// WebSocket server stuff
	mg_mgr_init(&mgr_svr);
	mg_http_listen(&mgr_svr, URL_SERVER, ev_handler_server, NULL);
	pthread_t thread;
	if (pthread_create(&thread, NULL, mongoose_update, NULL) != 0) {
		fprintf(stderr, "ERROR: Failed to create thread for updating the connection!");
		goto cleanup;
	}

	printf("INFO: Server loaded!\n");


	while (running) {
		switch (getchar()) {
			case CONNECT_OBS:
				mg_ws_connect(&mgr_obs, URL_OBS, ev_handler_client, NULL, NULL);
				printf("INFO: Trying to connect to OBS...\n");
				break;
			case PRINT_HELP:
				printf(
					"======= Keyboard options =======\n"
					"o  connect to obs\n"
					"\n"
					"?  print help\n"
					"q  quit\n"
					"================================\n"
				);
				break;
			case EXIT:
				running = false;
				break;
			case '\n': break;
			default:
				printf("WARN: Invalid input!\n");
		}
	}

	// WebSocket stuff, again
	if (pthread_join(thread, NULL) != 0)
		fprintf(stderr, "ERROR: Failed to join thread!\n");

cleanup:
	mg_mgr_free(&mgr_svr);
	mg_mgr_free(&mgr_obs);
	free(URL_OBS);
	free(URL_SERVER);
	free(REPLAY_PATH);
	return 0;
}
