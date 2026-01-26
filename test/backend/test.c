#include "munit.h"
#include "../../backend/main.h"

void obs_send_cmd(const char *s) {
	if (!obs_enabled || con_obs == NULL) {
		log_msg(WARN, "Cant send command, OBS is not connected!\n");
		return;
	}
	log_msg(LOG, "Sending OBS a Message: %s\n", s);
	mg_ws_send(con_obs, s, strlen(s), WEBSOCKET_OP_TEXT);
}

bool ws_send(struct mg_connection *con, char *message, int len) {
	if (con == NULL) {
		log_msg(WARN, "client is not connected, couldnt send Message: '%*s'\n", len, message);
		return false;
	}

	mg_ws_send(con, message, len, WEBSOCKET_OP_BINARY);
	return true;
}

struct CopyState{
	char orig_path[64], new_path[64];
	uint32_t buf_len;
	unsigned char *buf;
};

static void *test_copy_file_setup(const MunitParameter params[], void *data) {
	struct CopyState *st = malloc(sizeof(*st));
	if(!st) return NULL;

	int orig = munit_rand_int_range(10000, 99998);
	int new = orig+1;

	snprintf(st->orig_path, sizeof(st->orig_path), "/tmp/%d", orig);
	snprintf(st->new_path, sizeof(st->new_path), "/tmp/%d", new);

	const char *size_str = munit_parameters_get(params, "size");
	st->buf_len = size_str ? atoi(size_str) : munit_rand_int_range(0, 10000);
	st->buf = malloc(st->buf_len);
	if(!st->buf) { free(st); return NULL; }

	munit_rand_memory(st->buf_len, st->buf);

	// ensure the files are not present
	unlink(st->orig_path);
	unlink(st->new_path);

	// Create the orig_file
	FILE *f = fopen(st->orig_path, "wb");
	if(f == NULL) return NULL;
	ssize_t n = fwrite(st->buf, 1, st->buf_len, f);
	if(n != st->buf_len) return NULL;
	fclose(f);

	return st;
}

static void test_copy_file_teardown(void *data) {
	struct CopyState *st = data;

	unlink(st->orig_path);
	unlink(st->new_path);
	free(st->buf);
	free(st);
}

static MunitResult test_copy_file_not_existing(const MunitParameter params[], void *data) {
	// orig_path does not exist, so we cant copy it. copy_file has to fail
	bool retval = copy_file("tmp/1000000", "tmp/1000001");
	munit_assert_false(retval);

	return MUNIT_OK;
}

static MunitResult test_copy_file_overwrite(const MunitParameter params[], void *data) {
	struct CopyState *st = data;

	// copy_file should overwrite
	bool retval = copy_file(st->orig_path, st->new_path);
	munit_assert_true(retval);
	retval = copy_file(st->new_path, st->orig_path);
	munit_assert_true(retval);

	return MUNIT_OK;
}

static MunitResult test_copy_file(const MunitParameter params[], void *data) {
	struct CopyState *st = data;

	// copy file with copy_file
	bool retval = copy_file(st->orig_path, st->new_path);
	munit_assert_true(retval);

	// check new file is created
	FILE *f = fopen(st->new_path, "rb");
	munit_assert_not_null(f);

	munit_assert_int(fseek(f, 0, SEEK_END), ==, 0);
	long size = ftell(f);
	munit_assert_long(size, ==, st->buf_len);
	rewind(f);

	unsigned char buf2[st->buf_len+1];
	fread(buf2, 1, st->buf_len, f);
	munit_assert_memory_equal(st->buf_len, st->buf, buf2);
	fclose(f);

	return MUNIT_OK;
}

// Nothing to test imho
// static MunitResult test_obs_send_cmd(const MunitParameter params[], void *data) {}
// static MunitResult test_ws_send(const MunitParameter params[], void *data) {  return MUNIT_SKIP;}

static MunitResult test_create_replay_dirs(const MunitParameter params[], void *data) {
	replay_path = "/tmp/replays";
	bool retval = create_replay_dirs();
	munit_assert_true(retval);

	struct stat st;
	S_ISDIR(st.st_mode);
	munit_assert_int(stat(replay_path, &st), ==, 0);
	munit_assert_true(S_ISDIR(st.st_mode));

	char last_game_path[strlen(replay_path) + strlen("/last-game") + 1];
	sprintf(last_game_path, "%s/last-game", replay_path);

	munit_assert_int(stat(replay_path, &st), ==, 0);
	munit_assert_true(S_ISDIR(st.st_mode));

	return MUNIT_OK;
}

static MunitResult test_handle_message(const MunitParameter params[], void *data) {
	return MUNIT_OK;
}
// static MunitResult test_obs_switch_scene(const MunitParameter params[], void *data) { return MUNIT_SKIP; }
// This should be tested, but can only really be in production tests. We need a videostream and a timer of some sort and either check obs or mock obs_switch_scene
// static MunitResult test_obs_replay_start(const MunitParameter params[], void *data) { return MUNIT_SKIP; }
// static MunitResult test_ev_handler_client(const MunitParameter params[], void *data) { return MUNIT_SKIP; }
// static MunitResult test_ev_handler_server(const MunitParameter params[], void *data) { return MUNIT_SKIP; }
// static MunitResult test_mongoose_update(const MunitParameter params[], void *data) { return MUNIT_SKIP; }
// static MunitResult test_args(const MunitParameter params[], void *data) { return MUNIT_SKIP; }

static MunitTest test_suite_tests[] = {
	{ "copy_file/normal", test_copy_file, test_copy_file_setup, test_copy_file_teardown, 0, NULL },
	{ "copy_file/edge_case", test_copy_file, test_copy_file_setup, test_copy_file_teardown, 0, (MunitParameterEnum []){{"size", (char *[]){"0", "1", NULL}}, {NULL, NULL}} },
	{ "copy_file/not_existing", test_copy_file_not_existing, NULL, NULL, 0, NULL },
	{ "copy_file/overwrite", test_copy_file_overwrite, test_copy_file_setup, test_copy_file_teardown, 0, NULL },

	// { "obs_send_cmd", test_obs_send_cmd, NULL, NULL, 0, NULL },
	// { "ws_send", test_ws_send, NULL, NULL, 0, NULL },
	{ "create_replay_dirs", test_create_replay_dirs, NULL, NULL, 0, NULL },
	{ "handle_message", test_handle_message, NULL, NULL, 0, NULL },
	// { "obs_switch_scene", test_obs_switch_scene, NULL, NULL, 0, NULL },
	// { "obs_replay_start", test_obs_replay_start, NULL, NULL, 0, NULL },
	// { "ev_handler_client", test_ev_handler_client, NULL, NULL, 0, NULL },
	// { "ev_handler_server", test_ev_handler_server, NULL, NULL, 0, NULL },
	// { "mongoose_update", test_mongoose_update, NULL, NULL, 0, NULL },
	// { "args", test_args, NULL, NULL, 0, NULL },
	{ NULL, NULL, NULL, NULL, 0, NULL }
};

static const MunitSuite test_suite = { "backend/", test_suite_tests, NULL, 1, 0 };

int main(int argc, char* argv[MUNIT_ARRAY_PARAM(argc + 1)]) {
  return munit_suite_main(&test_suite, NULL, argc, argv);
}
