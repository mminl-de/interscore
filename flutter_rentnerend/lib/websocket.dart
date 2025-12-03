import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:io';

import 'lib.dart';
import 'MessageType.dart';
import 'md.dart';

class _WSServer {
	String _url;
	final Set<WebSocket> _clients = <WebSocket>{};

	_WSServer(this._url);

	Future<void> run() async {
		// TODO how to handle failure because someone already got that port or url is illegal
		final server = await HttpServer.bind(Uri.parse(_url), Uri.parse(_url).port);

		await for (final req in server) {
			if (!WebSocketTransformer.isUpgradeRequest(req)) {
				req.response.statusCode = 404;
				req.response.close();
				continue;
			}

			final client = await WebSocketTransformer.upgrade(req);
			_clients.add(client);

			// Listen is empty, because The server is write only.
			// Writing clients should connect to the real backend!
			client.listen((msg) {}, onDone: () => _clients.remove(client));
		}
	}

	// We broadcast to all clients connected
	void send(dynamic data) {
		for (final client in _clients)
			client.add(data);
	}
}

class _WSClient {
	final String _url;
	// This is needed, so updates pushed by the listen function here triggers a UI redraw
	final ValueNotifier<Matchday> _mdl;
	late WebSocketChannel _channel;

	_WSClient(this._url, this._mdl);

	void connect() {
		// TODO check that this is successfull and reconnect if not
		_channel = WebSocketChannel.connect(Uri.parse(_url));
		_channel.stream.listen(
			_listen,
			onDone: () => debugPrint("WS Client: Server \'${_url}\' closed connection"),
			onError: (err) => debugPrint("WS Client: ERR ${err}")
		);
	}

	void _listen(dynamic msg) {
		if(msg is! List<int>) {
			debugPrint("WS Client: Received msg with unknown type(${msg.runtimeType}): ${msg}. Ignoring...");
			return;
		}
		if(msg.length == 0) {
			debugPrint("WS Client: Received empty message...");
			return;
		}

		final Matchday md = _mdl.value;

		// Parse the message
		if(     msg[0] == MessageType.WIDGET_SCOREBOARD_SHOW.value);
		else if(msg[0] == MessageType.WIDGET_SCOREBOARD_HIDE.value);
		else if(msg[0] == MessageType.WIDGET_GAMEPLAN_SHOW.value);
		else if(msg[0] == MessageType.WIDGET_GAMEPLAN_HIDE.value);
		else if(msg[0] == MessageType.WIDGET_LIVETABLE_SHOW.value);
		else if(msg[0] == MessageType.WIDGET_LIVETABLE_HIDE.value);
		else if(msg[0] == MessageType.WIDGET_GAMESTART_SHOW.value);
		else if(msg[0] == MessageType.WIDGET_GAMESTART_HIDE.value);
		else if(msg[0] == MessageType.WIDGET_AD_SHOW.value);
		else if(msg[0] == MessageType.WIDGET_AD_HIDE.value);
		else if(msg[0] == MessageType.OBS_STREAM_START.value);
		else if(msg[0] == MessageType.OBS_STREAM_STOP.value);
		else if(msg[0] == MessageType.OBS_REPLAY_START.value);
		else if(msg[0] == MessageType.OBS_REPLAY_STOP.value);
		else if(msg[0] == MessageType.T1_SCORE_PLUS.value)
			_mdl.value = md.goalAdd(team: 1);
		else if(msg[0] == MessageType.T1_SCORE_MINUS.value)
			_mdl.value = md.goalRemoveLast(team: 1);
		else if(msg[0] == MessageType.T2_SCORE_PLUS.value)
			_mdl.value = md.goalAdd(team: 2);
		else if(msg[0] == MessageType.T2_SCORE_MINUS.value)
			_mdl.value = md.goalRemoveLast(team: 2);
		else if(msg[0] == MessageType.GAME_NEXT.value)
			_mdl.value = md.nextGame();
		else if(msg[0] == MessageType.GAME_PREV.value)
			_mdl.value = md.prevGame();
		else if(msg[0] == MessageType.GAME_SWITCH_SIDES.value)
			_mdl.value = md.switchSides();
		else if(msg[0] == MessageType.TIME_PLUS_1.value)
			_mdl.value = md.timeChange(1);
		else if(msg[0] == MessageType.TIME_MINUS_1.value)
			_mdl.value = md.timeChange(-1);
		else if(msg[0] == MessageType.TIME_PLUS_20.value)
			_mdl.value = md.timeChange(20);
		else if(msg[0] == MessageType.TIME_MINUS_20.value)
			_mdl.value = md.timeChange(-20);
		else if(msg[0] == MessageType.TIME_TOGGLE_PAUSE.value)
			if(!md.meta.paused)
				_mdl.value = md.togglePause();
		else if(msg[0] == MessageType.TIME_TOGGLE_UNPAUSE.value)
			if(md.meta.paused)
				_mdl.value = md.togglePause();
		else if(msg[0] == MessageType.TIME_RESET.value)
			_mdl.value = md.timeReset();
		else if(msg[0] == MessageType.PENALTY.value);
		else if(msg[0] == MessageType.PLS_SEND_CUR_GAMEINDEX.value);
		else if(msg[0] == MessageType.PLS_SEND_CUR_HALFTIME.value);
		else if(msg[0] == MessageType.PLS_SEND_CUR_IS_PAUSE.value);
		else if(msg[0] == MessageType.PLS_SEND_CUR_TIME.value);
		else if(msg[0] == MessageType.PLS_SEND_GAMESCOUNT.value);
		else if(msg[0] == MessageType.PLS_SEND_JSON.value);
		else if(msg[0] == MessageType.DATA_GAMEINDEX.value) {
			// Gameindex is in message[1] aka u8
			if (msg.length < 2) return;
			_mdl.value = md.copyWith(meta: md.meta.copyWith(gameIndex: msg[1]));
		}
		else if(msg[0] == MessageType.DATA_HALFTIME.value) {
			if (msg.length < 2) return;
			_mdl.value = md.copyWith(meta: md.meta.copyWith(sidesInverted: msg[1] == 1));
		}
		else if(msg[0] == MessageType.DATA_IS_PAUSE.value) {
			if (msg.length < 2) return;
			if ((msg[1] == 1) != md.meta.paused)
				_mdl.value = md.togglePause();
		}
		else if(msg[0] == MessageType.DATA_TIME.value) {
			if (msg.length < 3) return;
			int time_diff = u16FromBytes(msg, 1) - md.meta.currentTime;
			_mdl.value = md.timeChange(time_diff);
		}
		else if(msg[0] == MessageType.DATA_GAMESCOUNT.value);
		else if(msg[0] == MessageType.DATA_JSON.value)
			_mdl.value = Matchday.fromJson(jsonDecode(msg.toString()));

	}

	void send(dynamic msg) {
		_channel.sink.add(msg);
	}
}

class InterscoreWS {
	_WSServer? _server;
	_WSClient _client;
	// This is needed, so Matchday can be updated and trigger a UI redraw
	// Also we need the Matchday informations in sendSignal() to send them
	final ValueNotifier<Matchday> _mdl;

	InterscoreWS(String url, this._mdl, {bool server = true}) {
		if(server)
			_WSServer(url);
		_WSClient(url, _mdl);
	}

	void connect() {
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
