#define UNIT_TEST

#include "../../backend/main.h"

#include <stdarg.h>
#include <stddef.h>
#include <setjmp.h>
#include <cmocka.h>

/* --- capture ws_send calls --- */
static int ws_send_call_count;
static struct mg_connection *last_con;
static uint8_t last_buf[256];
static int last_len;

bool ws_send(struct mg_connection *con, char *message, int len) {
    ws_send_call_count++;
    last_con = con;
    last_len = len;
    if (len > 0 && len < (int)sizeof(last_buf)) {
        memcpy(last_buf, message, len);
    }
    return true;
}

void forward_to_receiver(uint8_t *msg, size_t msg_len, struct mg_connection *c, struct mg_connection *r) {
    ws_send_call_count = 0;
    handle_message((enum MessageType *) msg, sizeof(msg), c);

    assert_int_equal(ws_send_call_count, 1);
    assert_ptr_equal(last_con, r);
	for(int i=0; i < msg_len; i++)
    	assert_int_equal(last_buf[i], msg[i]);
}

static void test_forward_to_boss(void **state) {
    (void) state;

    struct mg_connection boss = { .id = 1 };
    struct mg_connection client = { .id = 2 };

    clients.first = NULL;
    clients.boss = &boss;

    Client c1 = { .con = &client, .next = NULL };
    clients.first = &c1;

	forward_to_receiver((uint8_t []){PLS_SEND_GAMEINDEX, 7}, 2, &client, &boss);
	forward_to_receiver((uint8_t []){DATA_PAUSE_ON, true}, 2, &boss, &client);
	uint16_t time = 300;
    uint8_t high = (time >> 8) & 0xFF; // high byte
    uint8_t low  = time & 0xFF;        // low byte
	forward_to_receiver((uint8_t []){DATA_TIME, high, low}, 2, &boss, &client);
	forward_to_receiver((uint8_t []){DATA_GAMEINDEX, 0}, 2, &boss, &client);
}

static void test_im_the_boss(void **state) {
    (void) state;

    struct mg_connection boss1 = { .id = 1 };
    struct mg_connection boss2 = { .id = 2 };
    clients.first = NULL;
    clients.boss = &boss1; // someone is already boss

    Client c1 = { .con = &boss2, .next = NULL };
    clients.first = &c1;

    uint8_t msg[] = {IM_THE_BOSS, true};

    ws_send_call_count = 0;
    handle_message((enum MessageType *)msg, sizeof(msg), &boss2);

    // boss2 should not become boss because boss1 exists
    assert_ptr_equal(clients.boss, &boss1);

    // no ws_send to boss2 should occur because attempt was illegal
    assert_int_equal(ws_send_call_count, 0);

    // now remove existing boss
    clients.boss = NULL;
    handle_message((enum MessageType *)msg, sizeof(msg), &boss2);
    assert_ptr_equal(clients.boss, &boss2);
    assert_int_equal(ws_send_call_count, 1);
    assert_int_equal(last_buf[0], DATA_IM_BOSS);
    assert_int_equal(last_buf[1], true);
}

static void test_data_gameindex_updates(void **state) {
    (void) state;

    struct mg_connection boss = { .id = 1 };
    struct mg_connection client = { .id = 2 };
    clients.first = NULL;
    clients.boss = &boss;
    Client c1 = { .con = &client, .next = NULL };
    clients.first = &c1;

    uint8_t msg[] = {DATA_GAMEINDEX, 42};
    ws_send_call_count = 0;

    handle_message((enum MessageType *)msg, sizeof(msg), &client);

    assert_int_equal(gameindex, 42);
    assert_int_equal(ws_send_call_count, 1);
    assert_int_equal(last_buf[0], DATA_GAMEINDEX);
    assert_int_equal(last_buf[1], 42);
}

static int obs_call_count;
static char last_obs_cmd[256];

void obs_send_cmd(const char *s) {
    obs_call_count++;
    snprintf(last_obs_cmd, sizeof(last_obs_cmd), "%s", s);
}

static void test_obs_stream_on(void **state) {
    (void) state;

    struct mg_connection boss = { .id = 1 };
    clients.boss = &boss;

    uint8_t msg_on[]  = {DATA_OBS_STREAM_ON, true};
    uint8_t msg_off[] = {DATA_OBS_STREAM_ON, false};

    obs_call_count = 0;

    handle_message((enum MessageType *)msg_on, sizeof(msg_on), &boss);
    assert_int_equal(obs_call_count, 1);
    assert_true(strstr(last_obs_cmd, "StartStream") != NULL);

    obs_call_count = 0;
    handle_message((enum MessageType *)msg_off, sizeof(msg_off), &boss);
    assert_int_equal(obs_call_count, 1);
    assert_true(strstr(last_obs_cmd, "StopStream") != NULL);
}

static void test_game_data_to_all_clients(void **state) {
    (void) state;

    struct mg_connection boss = { .id = 1 };
    struct mg_connection client1 = { .id = 2 };
    struct mg_connection client2 = { .id = 3 };

    clients.boss = &boss;
    Client c1 = { .con = &client1, .next = NULL };
    Client c2 = { .con = &client2, .next = &c1 };
    clients.first = &c2;

    uint8_t msg[] = {DATA_GAME, 99};
    ws_send_call_count = 0;

    handle_message((enum MessageType *)msg, sizeof(msg), &boss);

    // both clients should receive DATA_GAME
    assert_int_equal(ws_send_call_count, 2);
    // last_con points to the first client processed (order doesn't matter)
}

static void test_short_message(void **state) {
    (void) state;

    struct mg_connection client = { .id = 1 };
    clients.first = NULL;
    clients.boss = &client;

    uint8_t msg[] = {DATA_OBS_REPLAY_ON}; // missing second byte
    ws_send_call_count = 0;

    handle_message((enum MessageType *)msg, 1, &client);

    // Should be ignored, ws_send not called
    assert_int_equal(ws_send_call_count, 0);
}

int main(void) {
    const struct CMUnitTest tests[] = {
        cmocka_unit_test(test_forward_to_boss),
        cmocka_unit_test(test_im_the_boss),
        cmocka_unit_test(test_forward_to_boss),
        cmocka_unit_test(test_data_gameindex_updates),
        cmocka_unit_test(test_game_data_to_all_clients),
        cmocka_unit_test(test_short_message),
        cmocka_unit_test(test_obs_stream_on),
    };

    return cmocka_run_group_tests(tests, NULL, NULL);
}
