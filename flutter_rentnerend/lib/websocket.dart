import 'package:flutter_rentnerend/lib.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'MessageType.dart';
import 'md.dart';

class InterscoreWS {
	final String url;
	final ValueNotifier<Matchday> mdl;
	late final WebSocketChannel _channel;

	InterscoreWS(this.url, this.mdl);

	void connect() {
		_channel = WebSocketChannel.connect(Uri.parse(url));

		_channel.stream.listen(
			(message) {
				if(message is! List<int>) {
					debugPrint("Received msg with unknown type: ${message.runtimeType}");
					return;
				}
				if(message.length == 0) {
					debugPrint("Received empty message...");
					return;
				}

				final Matchday md = mdl.value;

				// Parse the message
				if(     message[0] == MessageType.WIDGET_SCOREBOARD_SHOW.value);
				else if(message[0] == MessageType.WIDGET_SCOREBOARD_HIDE.value);
				else if(message[0] == MessageType.WIDGET_GAMEPLAN_SHOW.value);
				else if(message[0] == MessageType.WIDGET_GAMEPLAN_HIDE.value);
				else if(message[0] == MessageType.WIDGET_LIVETABLE_SHOW.value);
				else if(message[0] == MessageType.WIDGET_LIVETABLE_HIDE.value);
				else if(message[0] == MessageType.WIDGET_GAMESTART_SHOW.value);
				else if(message[0] == MessageType.WIDGET_GAMESTART_HIDE.value);
				else if(message[0] == MessageType.WIDGET_AD_SHOW.value);
				else if(message[0] == MessageType.WIDGET_AD_HIDE.value);
				else if(message[0] == MessageType.OBS_STREAM_START.value);
				else if(message[0] == MessageType.OBS_STREAM_STOP.value);
				else if(message[0] == MessageType.OBS_REPLAY_START.value);
				else if(message[0] == MessageType.OBS_REPLAY_STOP.value);
				else if(message[0] == MessageType.T1_SCORE_PLUS.value)
					mdl.value = md.goalAdd(team: 1);
				else if(message[0] == MessageType.T1_SCORE_MINUS.value)
					mdl.value = md.goalRemoveLast(team: 1);
				else if(message[0] == MessageType.T2_SCORE_PLUS.value)
					mdl.value = md.goalAdd(team: 2);
				else if(message[0] == MessageType.T2_SCORE_MINUS.value)
					mdl.value = md.goalRemoveLast(team: 2);
				else if(message[0] == MessageType.GAME_NEXT.value)
					mdl.value = md.nextGame();
				else if(message[0] == MessageType.GAME_PREV.value)
					mdl.value = md.prevGame();
				else if(message[0] == MessageType.GAME_SWITCH_SIDES.value)
					mdl.value = md.switchSides();
				else if(message[0] == MessageType.TIME_PLUS_1.value)
					mdl.value = md.timeChange(1);
				else if(message[0] == MessageType.TIME_MINUS_1.value)
					mdl.value = md.timeChange(-1);
				else if(message[0] == MessageType.TIME_PLUS_20.value)
					mdl.value = md.timeChange(20);
				else if(message[0] == MessageType.TIME_MINUS_20.value)
					mdl.value = md.timeChange(-20);
				else if(message[0] == MessageType.TIME_TOGGLE_PAUSE.value)
					if(!md.meta.paused)
						mdl.value = md.togglePause();
				else if(message[0] == MessageType.TIME_TOGGLE_UNPAUSE.value)
					if(md.meta.paused)
						mdl.value = md.togglePause();
				else if(message[0] == MessageType.TIME_RESET.value)
					mdl.value = md.timeReset();
				else if(message[0] == MessageType.PENALTY.value);
				else if(message[0] == MessageType.PLS_SEND_CUR_GAMEINDEX.value);
				else if(message[0] == MessageType.PLS_SEND_CUR_HALFTIME.value);
				else if(message[0] == MessageType.PLS_SEND_CUR_IS_PAUSE.value);
				else if(message[0] == MessageType.PLS_SEND_CUR_TIME.value);
				else if(message[0] == MessageType.PLS_SEND_GAMESCOUNT.value);
				else if(message[0] == MessageType.PLS_SEND_JSON.value);
				else if(message[0] == MessageType.DATA_GAMEINDEX.value) {
					// Gameindex is in message[1] aka u8
					if (message.length < 2) return;
					mdl.value = md.copyWith(meta: md.meta.copyWith(gameIndex: message[1]));
				}
				else if(message[0] == MessageType.DATA_HALFTIME.value) {
					if (message.length < 2) return;
					mdl.value = md.copyWith(meta: md.meta.copyWith(sidesInverted: message[1] == 1));
				}
				else if(message[0] == MessageType.DATA_IS_PAUSE.value) {
					if (message.length < 2) return;
					if ((message[1] == 1) != md.meta.paused)
						mdl.value = md.togglePause();
				}
				else if(message[0] == MessageType.DATA_TIME.value) {
					if (message.length < 3) return;
					int time_diff = u16FromBytes(message, 1) - md.meta.currentTime;
					mdl.value = md.timeChange(time_diff);
				}
				else if(message[0] == MessageType.DATA_GAMESCOUNT.value);
				else if(message[0] == MessageType.DATA_JSON.value)
					mdl.value = Matchday.fromJson(jsonDecode(message.toString()));
			},
			onDone: () => debugPrint('WebSocket closed normally'),
			onError: (err) => debugPrint("WebSocket err: $err"),
		);
	}

	void sendString(String msg) {
		_channel.sink.add(msg);
	}

	void sendBytes(List<int> msg) {
		_channel.sink.add(msg);
	}

	void sendSignal(MessageType msg) {
		final Matchday md = mdl.value;

		// Parse the message
		if(msg == MessageType.PENALTY.value)
			debugPrint("WARN: Penalty sending is not implemented yet!");
		else if(msg == MessageType.DATA_GAMEINDEX.value)
			sendBytes([msg.value, md.meta.gameIndex]);
		else if(msg == MessageType.DATA_HALFTIME.value)
			sendBytes([msg.value, md.meta.currentGamepart]);
		else if(msg == MessageType.DATA_IS_PAUSE.value)
			sendBytes([msg.value, md.meta.paused ? 1 : 0]);
		else if(msg == MessageType.DATA_TIME.value)
			sendBytes([msg.value, ... u16ToBytes(md.meta.currentTime)]);
		else if(msg == MessageType.DATA_GAMESCOUNT.value)
			sendBytes([msg.value, md.games.length]);
		else if(msg == MessageType.DATA_JSON.value)
			sendString(jsonEncode(md.toJson()));
		else
			sendBytes([msg.value]);
	}

	void disconnect() {
		_channel.sink.close();
	}

}
