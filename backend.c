// TODO rewrite in zig :(
#include <pthread.h>
#include <stdbool.h>
#include <json-c/json.h>
#include <json-c/json_object.h>
#include "mongoose/mongoose.h"

#if defined(_WIN32)
    #include <direct.h>
    #define mkdir(path, mode) _mkdir(path)
#else
    #include <sys/stat.h>
    #include <sys/types.h>
#endif

#include "config.h"

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

#define URL "http://0.0.0.0:8081"
#define OBS_URL "http://0.0.0.0:4444"
const char *REPLAY_PATH  = "/home/flame/prg/interscore/replays";

void obs_switch_scene(void *scene_name);

u8 gameindex = 0;
u8 replays_count[1]; //TODO find out length efficiently

bool running = true;
// We pretty much have to do this in gloabl scope bc at least ev_handler (TODO FINAL DECIDE is this possible/better with smaller scope)
struct mg_connection *con_front = NULL;
struct mg_connection *con_rentner = NULL;
struct mg_connection *con_remote = NULL;
struct mg_connection *con_obs = NULL;
struct mg_mgr mgr_svr, mgr_obs;

bool scoreboard_on = false;
bool gameplan_on = false;
bool livetable_on = false;
bool gamestart_on = false;
bool ad_on = false;

void obs_send_cmd(const char *s){
	if(con_obs == NULL){
		printf("WARNING: Cant send command, OBS is not connected!\n");
		return;
	}
	mg_ws_send(con_obs, s, strlen(s), WEBSOCKET_OP_TEXT);
}

//message is allowed to be non null-terminated. Therefor the len as arg
bool ws_send(struct mg_connection *con, char *message, int len, int op) {
	if (con == NULL) {
		printf("WARNING: client is not connected, couldnt send Message: '%*s'\n", len, message);
		return false;
	}
	return mg_ws_send(con, message, len, op) == len;
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
	printf("RUNNING: %s\n", (char*)s);
	printf("RET CODE: %d", system((char*)s));
}

int make_directory(const char *path) {
	#if defined(_WIN32)
		return _mkdir(path);
	#else
		return mkdir(path, 0755);  // or 0755 for more restrictive perms
	#endif
}

void handle_message(enum MessageType *input_type, int input_len, struct mg_connection * con){
	printf("received a Input: %d\n", *input_type);
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
			printf("Received DATA: Time\n");
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
			printf("Received DATA: Gameindex: %d\n", ((char *)input_type)[1]);
			gameindex = ((char *)input_type)[1];
			ws_send(con_front, (char *)input_type, sizeof(char) * 2, WEBSOCKET_OP_BINARY);
			break;
		}
		case DATA_IS_PAUSE: // TODO MERGE TO ONE AGAIN
			printf("Received DATA: IS_PAUSE\n");
			ws_send(con_front, (char *)input_type, sizeof(char) * 2, WEBSOCKET_OP_BINARY);
			break;
		case DATA_HALFTIME: {
			printf("Received DATA: DATA_HALFTIME\n");
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
			printf("Received DATA: JSON\n");
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
			int base_delay = 1000;
			mg_timer_add(&mgr_obs, base_delay+500, 0, obs_switch_scene, "replay");
			mg_timer_add(&mgr_obs, base_delay+6500, 0, obs_switch_scene, "live");

			//now save replay
			static char s[200], s2[200];
			//This errors when /dev/shm is not there. If that happens just use /tmp here and in replay.sh (it will be slower)
			sprintf(s, "ffmpeg -y -sseof -3 -i '/dev/shm/livebuffer.ts' -c copy '%s/instant-replay.mkv'", REPLAY_PATH);
			//We wait to save the replay 0.5s because thats circa the delay we have on stream
			mg_timer_add(&mgr_obs, base_delay, 0, run_system, s);

			//Create path (even if already existent bc its easier)
			char path[200];
			sprintf(path, "%s/game_%02d", REPLAY_PATH, gameindex);
			make_directory(path);

			//After we save the replay we copy it to the games directory
			sprintf(s2, "cp -r '%s/instant-replay.mkv' '%s/game_%02d/replay-%05d.mkv'",
			        REPLAY_PATH, REPLAY_PATH, gameindex, replays_count[gameindex]);
			printf("s2: %s\n", s2);
			mg_timer_add(&mgr_obs, base_delay+400, 0, run_system, s2);
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

void ev_handler_client(struct mg_connection *con, int ev, void *ev_data) {
	switch(ev) {
	case MG_EV_CONNECT:
        printf("Connected to OBS WebSocket server\n");
		break;
	case MG_EV_WS_OPEN:
        printf("WebSocket handshake completed\n");
        con_obs = con;  // Save the connection
	    const char *identify_msg = "{\"op\": 1, \"d\": {\"rpcVersion\": 1, \"eventSubscriptions\": 255}}";
    	mg_ws_send(con_obs, identify_msg, strlen(identify_msg), WEBSOCKET_OP_TEXT);
		break;
	case MG_EV_WS_MSG: {
        struct mg_ws_message *wm = (struct mg_ws_message *)ev_data;
		break;
	}
	case MG_EV_CLOSE:
        printf("WebSocket connection closed\n");
		con_obs = NULL;
		break;
	// Signals not worth logging
	case MG_EV_OPEN:
	case MG_EV_POLL:
	case MG_EV_READ:
	case MG_EV_WRITE:
	case MG_EV_HTTP_HDRS:
		break;
	default:
		printf("Ignoring unknown signal (client) %d ...\n", ev);
	}
}

void ev_handler_server(struct mg_connection *con, int ev, void *p) {
	// TODO FINAL CONSIDER keeping these cases
	switch (ev) {
		case MG_EV_CONNECT:
			printf("New client connected!\n");
			break;
		case MG_EV_ACCEPT:
			printf("Connection accepted!\n");
			break;
		case MG_EV_CLOSE:
			printf("Client disconnected!\n");
			con_front = NULL; // TODO wtf is this, why does it always disconnect front
			break;
		case MG_EV_HTTP_MSG: {
			struct mg_http_message *hm = p;
			//We have to know which client is connecting (frontend/rentnerend)
			//Therefor we extract the query parameter as seen below.
			//FRONTEND URL: http://0.0.0.0:8081?client=frontend
			//RENTNEREND URL: http://0.0.0.0:8081
			//REMOTEEND URL: http://0.0.0.0:8081 // TODO make this work properly
			//TODO FINAL make this not suck
			char client_type[20];
    		mg_http_get_var(&hm->query, "client", client_type, sizeof(client_type));
			printf("Clienttype: %s\n", client_type);
			if(!strcmp(client_type, "frontend")){
				con_front = con;
			} else if(client_type[0] == '\0'){
				con_rentner = con;
			} else{
				printf("ERROR: Unknown Client is trying to connect!");
				con->is_closing = true;
				break;
			}

			//TODO check if upgrade is successfull
			mg_ws_upgrade(con, hm, NULL);
			printf("Client upgraded to WebSocket connection!\n");

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
			printf("Connection opened!\n");
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
			printf("Ignoring unknown signal (server) %d ...\n", ev);
	}
}

void *mongoose_update(void *arg) {
	while (running) {
		mg_mgr_poll(&mgr_svr, 20);
		mg_mgr_poll(&mgr_obs, 20);
	}
	return NULL;
}

int main(void) {
	// WebSocket server stuff
	mg_mgr_init(&mgr_svr);
	mg_http_listen(&mgr_svr, URL, ev_handler_server, NULL);
	pthread_t thread;
	if (pthread_create(&thread, NULL, mongoose_update, NULL) != 0) {
		fprintf(stderr, "ERROR: Failed to create thread for updating the connection!");
		goto cleanup;
	}
	// WebSocket as Client(OBS) stuff
	mg_mgr_init(&mgr_obs);


	char str[MAX_PATH_LEN];
	sprintf(str, "mkdir -p %s/last-game", REPLAY_PATH);
	printf("making dir: %s\n", str);
	system(str);

	printf("Server loaded!\n\x1b[33mDon't forget to connect to OBS!\x1b[0m\n");

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
				mg_ws_connect(&mgr_obs, OBS_URL, ev_handler_client, NULL, NULL);
				printf("Trying to connect to OBS...\n");
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
				printf("Invalid input!\n");
		}
	}

	// WebSocket stuff, again
	if (pthread_join(thread, NULL) != 0)
		fprintf(stderr, "ERROR: Failed to join thread!\n");

cleanup:
	mg_mgr_free(&mgr_svr);
	mg_mgr_free(&mgr_obs);
	return 0;
}
