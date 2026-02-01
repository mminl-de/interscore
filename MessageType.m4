dnl WHEN FILE IS CHANGED, RUN:
dnl make js-new flutter
changequote(<, >)
define(<ENUM_NAMES>, <
DATA_META
DATA_GAMESTATE,
DATA_OBS,
DATA_WIDGETS,
DATA_GAMES,
DATA_GAME,
DATA_GAMEACTIONS,dnl Additional: u8 = gameindex
DATA_GAMEACTION,dnl Additional: u8 = gameindex
DATA_FORMATS,
DATA_FORMAT,
DATA_TEAMS,
DATA_TEAM,
DATA_GROUPS,
DATA_GROUP,
DATA_IM_BOSS,dnl Additional: bool = this client is boss
DATA_TIMESTAMP,
DATA_JSON,
IM_THE_BOSS,
PLS_SEND_META,
PLS_SEND_GAMESTATE,
PLS_SEND_OBS,
PLS_SEND_WIDGETS,
PLS_SEND_GAMES,
PLS_SEND_GAME,
PLS_SEND_GAMEACTIONS,
PLS_SEND_GAMEACTION,
PLS_SEND_FORMATS,
PLS_SEND_FORMAT,
PLS_SEND_TEAMS,
PLS_SEND_TEAM,
PLS_SEND_GROUPS,
PLS_SEND_GROUP,
PLS_SEND_IM_BOSS,
PLS_SEND_TIMESTAMP,
PLS_SEND_JSON
>)
dnl
dnl Recursive print macro
define(i, <0>)
ifdef(<TS>, <
	define(<next_enum>, <ifelse(<$1>, <>, <>, <$1 = i, define(<i>, incr(i))next_enum(shift($@))>)>)
>)
ifdef(<ZIG>, <
	define(<next_enum>, <ifelse(<$1>, <>, <>, <$1 = i, define(<i>, incr(i))next_enum(shift($@))>)>)
>)
ifdef(<DART>, <
	define(<next_enum>, <ifelse(<$1>, <>, <>, <$1(i), define(<i>, incr(i))next_enum(shift($@))>)>)
>)

ifdef(<TS>, <
export enum MessageType {
	next_enum(ENUM_NAMES)
};
>)

ifdef(<ZIG>, <
pub const MessageType = enum(u8) {
	next_enum(ENUM_NAMES)
};
>)

ifdef(<DART>, <
enum MessageType {
	next_enum(ENUM_NAMES)

	final int value;
	const MessageType(this.value);
}
>)
