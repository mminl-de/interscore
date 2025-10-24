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

// Widgets
#define WIDGET_SCOREBOARD_TOGGLE 's'
#define WIDGET_GAMEPLAN_TOGGLE 'p'
#define WIDGET_LIVETABLE_TOGGLE 'l'
#define WIDGET_GAMESTART_TOGGLE 'g'
#define WIDGET_AD_TOGGLE 'a'

// Meta
#define EXIT 'q'
#define RELOAD_RENTNERJSON 'j'
#define RELOAD_RENTNER_GAMEINDEX 'r'
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
struct mg_connection *con_front = NULL;
struct mg_connection *con_rentner = NULL;
struct mg_connection *con_remote = NULL;
struct mg_connection *con_obs = NULL;
struct mg_mgr mgr_svr, mgr_obs;
time_t last_obs_con_attempt = 0;
const int obs_reconnect_interval = 5; // in sec

bool replays_instant_working = true;
bool replays_game_working = true;
bool replay_buffer_status = false;
bool scoreboard_on = false;
bool gameplan_on = false;
bool livetable_on = false;
bool gamestart_on = false;
bool ad_on = false;

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

void obs_send_cmd(const char *s){
	printf("DEBUG: Sending OBS a Message: %s\n", s);
	if(con_obs == NULL){
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
	return mg_ws_send(con, message, len, op) == len;
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

//void send_time(u16 t){
//	if(con_front == NULL){
//		printf("client is not connected, couldnt send time\n");
//		return;
//	}
//	u8 buffer[3];
//	buffer[0] = SCOREBOARD_SET_TIMER;
//	u16 time = htons(t);
//	memcpy(&buffer[1], &time, sizeof(time));
//	mg_ws_send(con_front, buffer, sizeof(buffer), WEBSOCKET_OP_BINARY);
//}

void run_system(void *s){
	printf("INFO: Running System CMD: %s\n", (char*)s);
	printf("INFO: CMD Return Value: %d", system((char*)s));
}

void handle_message(enum MessageType *input_type, int input_len, struct mg_connection * con){
	char con_name[20];
	if(con==con_rentner) strcpy(con_name, "rentnerend");
	else if(con==con_front) strcpy(con_name, "frontend");
	else if(con==con_remote) strcpy(con_name, "remoteend");
	printf("INFO: Received a Input from %s: %d\n", con_name, *input_type);
	switch (*input_type) {
		// All of these cases should be forwarded to frontend
		case WIDGET_SCOREBOARD_SHOW:
		case WIDGET_SCOREBOARD_HIDE:
		case WIDGET_GAMEPLAN_SHOW:
		case WIDGET_GAMEPLAN_HIDE:
		case WIDGET_LIVETABLE_SHOW:
		case WIDGET_LIVETABLE_HIDE:
		case WIDGET_GAMESTART_SHOW:
		case WIDGET_GAMESTART_HIDE:
		case WIDGET_AD_SHOW:
		case WIDGET_AD_HIDE:
		case T1_SCORE_PLUS:
		case T1_SCORE_MINUS:
		case T2_SCORE_PLUS:
		case T2_SCORE_MINUS:
		case GAME_NEXT:
		case GAME_PREV:
		case GAME_SWITCH_SIDES:
		case TIME_PLUS_1:
		case TIME_MINUS_1:
		case TIME_PLUS_20:
		case TIME_MINUS_20:
		case TIME_TOGGLE_UNPAUSE:
		case TIME_RESET: {
			ws_send(con_front, (char *)input_type, sizeof(enum MessageType), WEBSOCKET_OP_BINARY);
			break;
		}
		case DATA_TIME: // Same syntax as TIME_TOGGLE_PAUSE as it also ships time as u16 after the MessageType
			printf("INFO: Received DATA: Time\n");
		case TIME_TOGGLE_PAUSE: {
			ws_send(con_front, (void *)input_type, sizeof(u8) + sizeof(u16), WEBSOCKET_OP_BINARY);
			break;
		}
		case YELLOW_CARD:
		case RED_CARD: {
			ws_send(con_front, (char *)input_type, sizeof(char) * 2, WEBSOCKET_OP_BINARY);
			break;
		}
		case DATA_GAMEINDEX: {
			printf("INFO: Received DATA: Gameindex: %d\n", ((char *)input_type)[1]);
			gameindex = ((char *)input_type)[1];
			ws_send(con_front, (char *)input_type, sizeof(char) * 2, WEBSOCKET_OP_BINARY);
			break;
		}
		case DATA_IS_PAUSE: // TODO MERGE TO ONE AGAIN
			printf("INFO: Received DATA: IS_PAUSE\n");
			ws_send(con_front, (char *)input_type, sizeof(char) * 2, WEBSOCKET_OP_BINARY);
			break;
		case DATA_HALFTIME: {
			printf("INFO: Received DATA: DATA_HALFTIME\n");
			ws_send(con_front, (char *)input_type, sizeof(char) * 2, WEBSOCKET_OP_BINARY);
			break;
		}
		case PLS_SEND_CUR_GAMEINDEX:
		case PLS_SEND_CUR_HALFTIME:
		case PLS_SEND_CUR_IS_PAUSE:
		case PLS_SEND_CUR_TIME:
		case PLS_SEND_JSON: {
			ws_send(con_rentner, (char *)input_type, sizeof(enum MessageType), WEBSOCKET_OP_TEXT);
			break;
		}
		case DATA_JSON: {
			printf("INFO: Received DATA: JSON\n");
			ws_send(con_front, (char *)input_type, input_len, WEBSOCKET_OP_BINARY);
			break;
		}
		case OBS_STREAM_START: {
			obs_send_cmd("{\"op\": 6, \"d\": {\"requestType\": \"StartStream\", \"requestId\": \"1\"}}");
			break;
		}
		case OBS_STREAM_STOP: {
			obs_send_cmd("{\"op\": 6, \"d\": {\"requestType\": \"StopStream\", \"requestId\": \"2\"}}");
			break;
		}
		case OBS_REPLAY_START: {
			if(!replays_instant_working) break;
			// Tell OBS to save replay buffer
			obs_send_cmd("{\"op\": 6, \"d\": {\"requestType\": \"SaveReplayBuffer\", \"requestId\": \"save_replay\"}}");
			break;
		}
		case OBS_REPLAY_STOP: {
			obs_switch_scene("live");
			break;
		}
		default:
			break;
	}
}

void obs_switch_scene(void *scene_name){
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
			char con_name[20];
			if(con==con_rentner) {
				strcpy(con_name, "rentnerend");
				con_rentner = NULL;
			} else if(con==con_front) {
				strcpy(con_name, "frontend");
				con_front = NULL;
			} else if(con==con_remote) {
				strcpy(con_name, "remoteend");
				con_remote = NULL;
			}
			printf("WARN: Client %s disconnected!\n", con_name);
			break;
		}
		case MG_EV_HTTP_MSG: {
			struct mg_http_message *hm = p;
			//We have to know which client is connecting (frontend/rentnerend)
			//Therefor we extract the query parameter as seen below.
			//FRONTEND URL: http://0.0.0.0:8081?client=frontend
			//RENTNEREND URL: http://0.0.0.0:8081
			//REMOTEEND URL: http://0.0.0.0:8081?client=remoteend // TODO make this work properly
			//TODO FINAL make this not suck
			char client_type[20];
    		mg_http_get_var(&hm->query, "client", client_type, sizeof(client_type));
			printf("INFO: Clienttype: %s\n", client_type);
			if(!strcmp(client_type, "frontend")){
				printf("INFO: New Client is frontend!\n");
				con_front = con;
			} else if(!strcmp(client_type, "remoteend")){
				printf("INFO: New Client is remoteend!\n");
				con_remote = con;
			} else if(client_type[0] == '\0'){
				printf("INFO: New Client is rentnerend!\n");
				con_rentner = con;
			} else{
				printf("WARN: Unknown Client is trying to connect! Closing Connection\n");
				con->is_closing = true;
				break;
			}

			//TODO check if upgrade is successfull
			mg_ws_upgrade(con, hm, NULL);
			printf("INFO: Client upgraded to WebSocket connection!\n");

			// Get latest and greatest information from rentnerend
			sleep(1); // TODO NOW we cant send requests this rapidly. Destroys json and everything else
			char message_type = PLS_SEND_JSON;
			ws_send(con_rentner, &message_type, sizeof(char), WEBSOCKET_OP_BINARY);
			message_type = PLS_SEND_CUR_HALFTIME;
			ws_send(con_rentner, &message_type, sizeof(char), WEBSOCKET_OP_BINARY);
			message_type = PLS_SEND_CUR_IS_PAUSE;
			ws_send(con_rentner, &message_type, sizeof(char), WEBSOCKET_OP_BINARY);
			message_type = PLS_SEND_CUR_TIME;
			ws_send(con_rentner, &message_type, sizeof(char), WEBSOCKET_OP_BINARY);
			message_type = PLS_SEND_CUR_GAMEINDEX;
			ws_send(con_rentner, &message_type, sizeof(char), WEBSOCKET_OP_BINARY);
			break;
		}
		case MG_EV_WS_OPEN:
			printf("INFO: New connection opened!\n");
			//con_front = con;
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
			break;
		default:
			printf("WARN: Ignoring unknown WS_Signal from client: %d\n", ev);
	}
}

void *mongoose_update(void *arg) {
	const int replay_buffer_activation_interval = 10; // in sec
	time_t last_replay_buffer_attempt = time(NULL);
	time_t last_refresh = time(NULL);

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
		} else {
			time_t now = time(NULL);
			if(now - last_refresh >= 10) {
				printf("INFO: Trying to fetch the OBS Replay Buffer Status...\n");
				obs_send_cmd("{\"op\": 6, \"d\": {\"requestType\": \"StartReplayBuffer\", \"requestId\": \"start_buffer\"}}");
				last_refresh = now;
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
		char temp = 0;
		char c = getchar();
		switch (c) {
			// TODO actually implement getting gameindex etc
			case '+':
				gameindex++;
				break;
			case '-':
				gameindex--;
			case '=':
				printf("INFO: Gameindex == %d\n", gameindex);
			case WIDGET_SCOREBOARD_TOGGLE:
				if(scoreboard_on) {
					temp = WIDGET_SCOREBOARD_HIDE;
					ws_send(con_front, &temp, sizeof(u8), WEBSOCKET_OP_BINARY);
				} else {
					temp = WIDGET_SCOREBOARD_SHOW;
					ws_send(con_front, &temp, sizeof(u8), WEBSOCKET_OP_BINARY);
				}
				scoreboard_on = !scoreboard_on;
				break;
			case WIDGET_GAMEPLAN_TOGGLE:
				if(gameplan_on) {
					temp = WIDGET_GAMEPLAN_HIDE;
					ws_send(con_front, &temp, sizeof(u8), WEBSOCKET_OP_BINARY);
				} else {
					temp = WIDGET_GAMEPLAN_SHOW;
					ws_send(con_front, &temp, sizeof(u8), WEBSOCKET_OP_BINARY);
				}
				gameplan_on = !gameplan_on;
				break;
			case WIDGET_LIVETABLE_TOGGLE:
				if(livetable_on) {
					temp = WIDGET_LIVETABLE_HIDE;
					ws_send(con_front, &temp, sizeof(u8), WEBSOCKET_OP_BINARY);
				} else {
					temp = WIDGET_LIVETABLE_SHOW;
					ws_send(con_front, &temp, sizeof(u8), WEBSOCKET_OP_BINARY);
				}
				livetable_on = !livetable_on;
				break;
			case WIDGET_GAMESTART_TOGGLE:
				if(gamestart_on) {
					temp = WIDGET_GAMESTART_HIDE;
					ws_send(con_front, &temp, sizeof(u8), WEBSOCKET_OP_BINARY);
				} else {
					temp = WIDGET_GAMESTART_SHOW;
					ws_send(con_front, &temp, sizeof(u8), WEBSOCKET_OP_BINARY);
				}
				gamestart_on = !gamestart_on;
				break;
			case WIDGET_AD_TOGGLE:
				if(ad_on) {
					temp = WIDGET_AD_HIDE;
					ws_send(con_front, &temp, sizeof(u8), WEBSOCKET_OP_BINARY);
				} else {
					temp = WIDGET_AD_SHOW;
					ws_send(con_front, &temp, sizeof(u8), WEBSOCKET_OP_BINARY);
				}
				ad_on = !ad_on;
				break;
			case RELOAD_RENTNERJSON: {
				char w1 = PLS_SEND_JSON;
				if(!ws_send(con_rentner, &w1, sizeof(char), WEBSOCKET_OP_BINARY))
					fprintf(stderr, "ERROR: Could not send request to Rentnerend!\n");
				break;
			}
			case RELOAD_RENTNER_GAMEINDEX: {
				char w2 = PLS_SEND_CUR_GAMEINDEX;
				if(!ws_send(con_rentner, &w2, sizeof(char), WEBSOCKET_OP_BINARY))
					fprintf(stderr, "ERROR: Could not send request to Rentnerend!\n");
				break;
			}
			case CONNECT_OBS:
				mg_ws_connect(&mgr_obs, URL_OBS, ev_handler_client, NULL, NULL);
				printf("INFO: Trying to connect to OBS...\n");
				break;
			case 'R':
				if(!replays_instant_working) break;
				// Tell OBS to save replay buffer
				obs_send_cmd("{\"op\": 6, \"d\": {\"requestType\": \"SaveReplayBuffer\", \"requestId\": \"save_replay\"}}");
				printf("INFO: Trying to Save a Replay...\n");
				break;
			case PRINT_HELP:
				printf(
					"======= Keyboard options =======\n"
					"s  Scoreboard Toggle\n"
					"p  Gameplan Toggle\n"
					"l  Livetabelle Toggle\n"
					"g  Gamestart Toggle\n"
					"a  Ad Toggle\n"
					"\n"
					"+  Next Game\n"
					"-  Prev Game\n"
					"=  Gameindex right now\n"
					"\n"
					"j  Send rentnerend json to Frontend\n"
					"r  Send rentnerend gameindex to Backend\n"
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
