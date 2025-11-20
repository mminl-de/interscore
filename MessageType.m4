dnl WHEN FILE IS CHANGED, RUN:
dnl make js-new flutter
changequote(<, >)
define(<ENUM_NAMES>, <
WIDGET_SCOREBOARD_SHOW,
WIDGET_SCOREBOARD_HIDE,
WIDGET_GAMEPLAN_SHOW,
WIDGET_GAMEPLAN_HIDE,
WIDGET_LIVETABLE_SHOW,
WIDGET_LIVETABLE_HIDE,
WIDGET_GAMESTART_SHOW,
WIDGET_GAMESTART_HIDE,
WIDGET_AD_SHOW,
WIDGET_AD_HIDE,
OBS_STREAM_START,
OBS_STREAM_STOP,
OBS_REPLAY_START,
OBS_REPLAY_STOP,
T1_SCORE_PLUS,
T1_SCORE_MINUS,
T2_SCORE_PLUS,
T2_SCORE_MINUS,
GAME_NEXT,
GAME_PREV,
GAME_SWITCH_SIDES,
TIME_PLUS_1,
TIME_MINUS_1,
TIME_PLUS_20,
TIME_MINUS_20,
TIME_TOGGLE_PAUSE,dnl Additional: u16 = time from Matchday struct)
TIME_TOGGLE_UNPAUSE,
TIME_RESET,
PENALTY,dnl Additional: u8 = player index, char* = penalty type (null-terminated))
PLS_SEND_CUR_GAMEINDEX,
PLS_SEND_CUR_HALFTIME,
PLS_SEND_CUR_IS_PAUSE,
PLS_SEND_CUR_TIME,
PLS_SEND_GAMESCOUNT,
DATA_GAMEINDEX,dnl Additional: u8 = Gameindex)
DATA_HALFTIME,dnl Additional: u8/boolean = halftime 0 bzw 1)
DATA_IS_PAUSE,dnl Additional: u8/boolean = is_pause)
DATA_TIME,dnl Additional: u16 = time from Matchday struct)
DATA_GAMESCOUNT,dnl Additional: u8 = Gamescount)
PLS_SEND_JSON
>)
dnl
dnl // Recursive print macro
define(i, <0>)
ifdef(<TS>, <
	define(<next_enum>, <ifelse(<$1>, <>, <>, <$1 = i, define(<i>, incr(i))next_enum(shift($@))>)>)
>)
ifdef(<DART>, <
	define(<next_enum>, <ifelse(<$1>, <>, <>, <$1(i), define(<i>, incr(i))next_enum(shift($@))>)>)
>)

ifdef(<TS>, <
export enum MessageType {
	next_enum(ENUM_NAMES)
	DATA_JSON = 123
};
>)

ifdef(<DART>, <
enum MessageType {
	next_enum(ENUM_NAMES)
	DATA_JSON(123);

	final int value;
	const MessageType(this.value);
}
>)
