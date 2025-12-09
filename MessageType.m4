dnl WHEN FILE IS CHANGED, RUN:
dnl make js-new flutter
changequote(<, >)
define(<ENUM_NAMES>, <
DATA_WIDGET_SCOREBOARD_ON,dnl Additional: boolean on(1)/off(0)
DATA_WIDGET_GAMEPLAN_ON,dnl Additional: boolean on(1)/off(0)
DATA_WIDGET_LIVETABLE_ON,dnl Additional: boolean on(1)/off(0)
DATA_WIDGET_GAMESTART_ON,dnl Additional: boolean on(1)/off(0)
DATA_WIDGET_AD_ON,dnl Additional: boolean on(1)/off(0)
DATA_OBS_STREAM_ON,dnl Additional: boolean on(1)/off(0)
DATA_OBS_REPLAY_ON,dnl Additional: boolean on(1)/off(0)
DATA_SIDES_SWITCHED,dnl Additional: boolean switched(1)/not switched(0)
DATA_GAME_ACTION,dnl Additional: Game Action as json
DATA_GAMEINDEX,dnl Additional: u8 = Gameindex)
DATA_GAMEPART,dnl Additional: u8/boolean = halftime 0 bzw 1)
DATA_PAUSE_ON,dnl Additional: u8/boolean = is_pause)
DATA_TIME,dnl Additional: u16 = time from Matchday struct)
DATA_GAMESCOUNT,dnl Additional: u8 = Gamescount)
GAME_ACTION_DELETE,dnl Additional: uint = id of game action
IM_THE_BOSS,
DATA_IM_BOSS,dnl Additional: bool = this client is boss
PLS_SEND_IM_BOSS,
PLS_SEND_WIDGET_SCOREBOARD_ON,
PLS_SEND_WIDGET_GAMEPLAN_ON,
PLS_SEND_WIDGET_LIVETABLE_ON,
PLS_SEND_WIDGET_GAMESTART_ON,
PLS_SEND_WIDGET_AD_ON,
PLS_SEND_OBS_STREAM_ON,
PLS_SEND_OBS_REPLAY_ON,
PLS_SEND_SIDES_SWITCHED,
PLS_SEND_GAME_ACTION,dnl Additional: uint = id of wanted game action
PLS_SEND_GAMEINDEX,
PLS_SEND_GAMEPART,
PLS_SEND_IS_PAUSE,
PLS_SEND_TIME,
PLS_SEND_GAMESCOUNT,
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
