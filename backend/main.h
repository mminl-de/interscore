#ifndef MAIN_H
#define MAIN_H

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
#include "../MessageType.ts"
#undef export

typedef struct _Client {
	struct mg_connection *con;
	struct _Client *next;
} Client;

typedef struct {
	Client *first;
	struct mg_connection *boss;
} ClientsList;

typedef enum { NONE, LOG, WARN, ERROR } LogLevel;

// Meta
#define URL_SERVER_DEFAULT "ws://0.0.0.0:8081"
#define URL_OBS_DEFAULT "http://0.0.0.0:4444"
#define REPLAY_PATH_DEFAULT "/home/obsuser/replays"

#define OBS_RECONNECT_INTERVAL 5 // seconds

void die(char *error, int retval);
void log_msg(LogLevel level, const char *fmt, ...);
int copy_file(const char *src, const char *dst);
void obs_send_cmd(const char *s);
bool ws_send(struct mg_connection *con, char *message, int len);
bool create_replay_dirs();
void handle_message(enum MessageType *msg, int msg_len, struct mg_connection * con);
void obs_switch_scene(void *scene_name);
bool obs_replay_start();
void ev_handler_client(struct mg_connection *con, int ev, void *ev_data);
void ev_handler_server(struct mg_connection *con, int ev, void *p);
void *mongoose_update(void *);
void args(int argc, char *argv[]);
void init_obs();
bool init_server();

extern char *url_server, *url_obs, *replay_path;
extern int gameindex;
extern LogLevel log_level;
extern ClientsList clients;
extern struct mg_connection *con_obs;
extern struct mg_mgr mgr_svr, mgr_obs;
extern time_t last_obs_con_attempt;
extern bool obs_enabled, replays_instant_working, replays_game_working, replay_buffer_status;
#endif
