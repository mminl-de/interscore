import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:typed_data';
import 'package:web/web.dart';
import 'dart:js_interop';

import 'MessageType.dart';
import 'md.dart';
import 'lib.dart' as lib;

class WSClient {
	final String _url;
	// This is needed, so updates pushed by the listen function here triggers a UI redraw
	final ValueNotifier<Matchday> _mdl;
	WebSocket? _ws;
	bool boss = false; // This says, if we are the boss for the server
	final ValueNotifier<bool> connected = ValueNotifier(false);

	WSClient(this._url, this._mdl);

	void close() {
		_ws?.close();
		_ws = null;
	}

	Future<void> connect() async {
		debugPrint("Connecting to Server: ${_url}");
		try {
			final ws = WebSocket(_url);
			ws.binaryType = 'arraybuffer';

			ws.onopen = ((Event e) {
				debugPrint("Connected '${_url}'");
				connected.value = true;
			}).toJS;
			ws.onmessage = ((MessageEvent e) {
				final JSAny? data = e.data;
				if(data == null) return;

				if (data.isA<JSArrayBuffer>())
					_listen((data as JSArrayBuffer).toDart.asUint8List());
				else
					debugPrint("WS Client: Non-binary message ignored: $data");
			}).toJS;
			ws.onerror = ((Event e) {
				debugPrint("WS Client: ERR");
				connected.value = false;
				_ws = null;
			}).toJS;
			ws.onclose = ((CloseEvent e) {
				debugPrint("WS Client: Server '$_url' closed connection");
				connected.value = false;
				_ws = null;
			}).toJS;

			_ws = ws;
		} catch (e) {
			debugPrint("WS Client: Connection failed with error: ${e}");
			_ws = null;
		}
	}

	void _listen(dynamic msg) {
		//debugPrint("WS Client: Received message: ${msg}");
		if(msg is! List<int>) {
			debugPrint("WS Client: Received msg with unknown type(${msg.runtimeType}): ${msg}. Ignoring...");
			return;
		}
		if(msg.length == 0) {
			debugPrint("WS Client: Received empty message...");
			return;
		}

		Matchday md = _mdl.value;

		// Parse the message
		if(     msg[0] == MessageType.DATA_WIDGET_SCOREBOARD_ON.value);
		else if(msg[0] == MessageType.DATA_WIDGET_GAMEPLAN_ON.value);
		else if(msg[0] == MessageType.DATA_WIDGET_LIVETABLE_ON.value);
		else if(msg[0] == MessageType.DATA_WIDGET_GAMESTART_ON.value);
		else if(msg[0] == MessageType.DATA_WIDGET_AD_ON.value);
		else if(msg[0] == MessageType.DATA_OBS_STREAM_ON.value);
		else if(msg[0] == MessageType.DATA_OBS_REPLAY_ON.value);
		else if(msg[0] == MessageType.DATA_GAME.value) {
			Game game = Game.fromJson(jsonDecode(utf8.decode(msg.sublist(1))));
			game = game.copyWith(protected: false);
			int g_index = _mdl.value.games.indexWhere((g) => g.name == game.name);
			debugPrint("Received DATA_GAME. Index: ${g_index}, protected: ${_mdl.value.games[g_index].protected}");
			if(g_index != -1 && _mdl.value.games[g_index].protected == false) {
				List<Game> games = List<Game>.from(_mdl.value.games);
				games[g_index] = game;
				_mdl.value = _mdl.value.copyWith(games: games);
			}
			else if(_mdl.value.meta.allowRemoteGameCreation) {
				List<Game> games = List<Game>.from(_mdl.value.games);
				games.add(game);
				_mdl.value = _mdl.value.copyWith(games: games);
			}
		}
		else if(msg[0] == MessageType.DATA_GAME_ACTION) {
			_mdl.value = md.addGameAction(GameAction.fromJson(jsonDecode(msg.sublist(1).toString())));
		}
		else if(msg[0] == MessageType.DATA_GAMEINDEX.value) {
			if (msg.length < 2) return;
			_mdl.value = md.setGameIndex(msg[1]);
		}
		else if(msg[0] == MessageType.DATA_SIDES_SWITCHED.value) {
			if (msg.length < 2) return;
			_mdl.value = md.setSidesInverted(msg[1] == 1 ? true : false);
		}
		else if(msg[0] == MessageType.DATA_PAUSE_ON.value) {
			debugPrint("WARN: Received DATA_PAUSE_ON. DEPRECATED! Not applying!");
			// _mdl.value = md.setPause(msg[1] == 1 ? true : false);
		}
		else if(msg[0] == MessageType.DATA_GAMEPART.value) {
			if (msg.length < 2) return;
			_mdl.value = md.setCurrentGamepart(msg[1]);
		}
		else if(msg[0] == MessageType.DATA_TIME.value) {
			if (msg.length < 3) return;
			int time_diff = lib.u16FromBytes(msg, 1) - md.currentTime();
			_mdl.value = md.timeChange(time_diff);
		}
		else if(msg[0] == MessageType.DATA_GAMESCOUNT.value);
		else if(msg[0] == MessageType.DATA_IM_BOSS.value) {
			if(msg.length < 2) return;
			debugPrint("Am I the boss? ${msg[1]}");
			this.boss = msg[1] == 1 ? true : false;
		}
		else if(msg[0] == MessageType.DATA_JSON.value) {
			_mdl.value = Matchday.fromJson(jsonDecode(utf8.decode(msg)) as Map<String, dynamic>);
		}
		else if(msg[0] == MessageType.PLS_SEND_GAMEINDEX.value)
			sendSignal(MessageType.DATA_GAMEINDEX);
		else if(msg[0] == MessageType.PLS_SEND_GAMEPART.value)
			sendSignal(MessageType.DATA_GAMEPART);
		else if(msg[0] == MessageType.PLS_SEND_GAME.value)
			sendSignal(MessageType.DATA_GAME, additionalInfo: msg[1]);
		else if(msg[0] == MessageType.PLS_SEND_IS_PAUSE.value)
			sendSignal(MessageType.DATA_PAUSE_ON);
		else if(msg[0] == MessageType.PLS_SEND_TIME.value)
			sendSignal(MessageType.DATA_TIME);
		else if(msg[0] == MessageType.PLS_SEND_GAMESCOUNT.value)
			sendSignal(MessageType.DATA_GAMESCOUNT);
		else if(msg[0] == MessageType.PLS_SEND_JSON.value)
			sendSignal(MessageType.DATA_JSON);

	}

	sendSignal(MessageType signal, {int? additionalInfo}) {
		final List<int>? msg = lib.signalToMsg(signal, _mdl.value, additionalInfo: additionalInfo);
		if(msg == null) return;

		send(msg);
	}

	void send(List<int> msg) {
		//debugPrint("WS Client: sending: ${msg}");
		_ws?.send(Uint8List.fromList(msg).toJS);
	}
}
