// Also dont forget to edit MessageType enum class in remoteend!

export enum MessageType {
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
	TIME_TOGGLE_PAUSE, // Additional: u16 = time from Matchday struct
	TIME_TOGGLE_UNPAUSE,
	TIME_RESET,
	YELLOW_CARD, // Additional: u8 = index of player receiving Card
	RED_CARD, // Additional: u8 = index of player receiving Card
//	SCOREBOARD_SET_TIMER,
	PLS_SEND_CUR_GAMEINDEX,
	PLS_SEND_CUR_HALFTIME,
	PLS_SEND_CUR_IS_PAUSE,
	PLS_SEND_CUR_TIME,
	PLS_SEND_GAMESCOUNT,
	DATA_GAMEINDEX, // Additional: u8 = Gameindex
	DATA_HALFTIME, // Additional: u8/boolean = halftime 0 bzw 1
	DATA_IS_PAUSE, // Additional: u8/boolean = is_pause
	DATA_TIME, // Additional: u16 = time from Matchday struct
	DATA_GAMESCOUNT, // Additional: u8 = Gamescount
	PLS_SEND_JSON,
	DATA_JSON = 123, // (ASCII of: {). Additional: a nullterminated string that contains a full json
};
