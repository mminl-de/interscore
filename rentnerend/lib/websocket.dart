import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'lib.dart';
import 'MessageType.dart';
import 'md.dart';

class _WSServer {
	String _url;
	final Set<WebSocket> _clients = <WebSocket>{};
	HttpServer? _server;
	ValueNotifier<Matchday> _mdl;

	_WSServer(this._url, this._mdl);

	void close() {
		for (var client in _clients)
			client.close();
		_clients.clear();
		_server?.close(force: true);
	}

	Future<void> run() async {
		debugPrint("WS Server: Starting...");
		try {
			_server = await HttpServer.bind(Uri.parse(_url).host, Uri.parse(_url).port, shared: true);
		} catch (_) {
			debugPrint("WS Server: Couldnt bind on port! Cant Start Server!");
			_server = null;
			return;
		}

		await for (final req in _server!) {
			if (!WebSocketTransformer.isUpgradeRequest(req)) {
				debugPrint("WS Server: Not WS, closing");
				req.response.statusCode = 404;
				req.response.close();
				continue;
			}

			final client = await WebSocketTransformer.upgrade(req);
			debugPrint("WS Server: upgraded client to WS");
			_clients.add(client);

			// Listen is empty, because The server is write only.
			// Writing clients should connect to the real backend!
			client.listen((msg) {
				//debugPrint("got Message: ${msg}");
				if(     msg[0] == MessageType.PLS_SEND_GAMEINDEX.value)
					sendSignal(MessageType.DATA_GAMEINDEX);
				else if(msg[0] == MessageType.PLS_SEND_GAMEPART.value)
					sendSignal(MessageType.DATA_GAMEPART);
				else if(msg[0] == MessageType.PLS_SEND_IS_PAUSE.value)
					sendSignal(MessageType.DATA_PAUSE_ON);
				else if(msg[0] == MessageType.PLS_SEND_TIME.value)
					sendSignal(MessageType.DATA_TIME);
				else if(msg[0] == MessageType.PLS_SEND_GAMESCOUNT.value)
					sendSignal(MessageType.DATA_GAMESCOUNT);
				else if(msg[0] == MessageType.PLS_SEND_JSON.value)
					sendSignal(MessageType.DATA_JSON);
			}, onDone: () => _clients.remove(client), onError: (e) => debugPrint("grrr, client couldnt be connected properly!"));
		}
	}

	void sendSignal(MessageType signal) {
		final msg = signalToMsg(signal, _mdl.value);
		if(msg != null) send(msg);
	}

	// We broadcast to all clients connected
	void send(List<int> data) {
		for (final client in _clients) {
			client.add(data);
		}
	}
}

class _WSClient {
	final String _url;
	// This is needed, so updates pushed by the listen function here triggers a UI redraw
	final ValueNotifier<Matchday> _mdl;
	WebSocket? _channel;
	bool boss = false; // This says, if we are the boss for the server

	_WSClient(this._url, this._mdl);

	void close() {
		_channel?.close();
		_channel = null;
	}

	Future<void> connect() async {
		debugPrint("Connecting to Server: ${_url}");
		try {
			_channel = await WebSocket.connect(_url);
			debugPrint("Connected: ${_url}");

			_channel!.listen(
				_listen,
				onDone: () {
					debugPrint("WS Client: Server \'${_url}\' closed connection");
					_channel = null;
				},
				onError: (err) {
					debugPrint("WS Client: ERR ${err}");
					_channel = null;
				}
			);
		} catch (e) {
			debugPrint("WS Client: Connection failed with error: ${e}");
			_channel = null;
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
			_mdl.value = md.setPause(msg[1] == 1 ? true : false);
		}
		else if(msg[0] == MessageType.DATA_GAMEPART.value) {
			if (msg.length < 2) return;
			_mdl.value = md.setCurrentGamepart(msg[1]);
		}
		else if(msg[0] == MessageType.DATA_TIME.value) {
			if (msg.length < 3) return;
			int time_diff = u16FromBytes(msg, 1) - md.meta.currentTime;
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
		final List<int>? msg = signalToMsg(signal, _mdl.value, additionalInfo: additionalInfo);
		if(msg == null) return;

		send(msg);
	}

	void send(List<int> msg) {
		//debugPrint("WS Client: sending: ${msg}");
		_channel?.add(msg);
	}
}

class InterscoreWS {
	_WSServer? server;
	_WSClient? client;
	// This is needed, so Matchday can be updated and trigger a UI redraw
	// Also we need the Matchday informations in sendSignal() to send them
	late final ValueNotifier<Matchday> _mdl;

	// We have to use a "factory" so the constructor can be async
	InterscoreWS(this._mdl);

	void close() {
		server?.close();
		client?.close();
	}

	void initServer(String url) {
		this.server = _WSServer(url, _mdl);
		// we dont await this, because it will run forever
		this.server?.run();
	}

	// Extra function is needed for await functionality
	Future<void> initClient(String url) async {
		client = _WSClient(url, _mdl);
		await this.client?.connect();
	}

	void sendSignal(MessageType signal, {int? additionalInfo}) {
		final List<int>? msg = signalToMsg(signal, _mdl.value, additionalInfo: additionalInfo);
		if(msg == null) return;

		send(msg);

		// TODO CONSIDER only send games, not gameparts
		// TODO TEMP this seems odd, but we dont send gameactions right now, but rather the whole json
		// the other device doesnt accept json data though. It only acceps games. Therefor we also send the game
		if(signal == MessageType.DATA_JSON)
			sendSignal(MessageType.DATA_GAME, additionalInfo: _mdl.value.meta.gameIndex);
	}

	void send(List<int> msg) {
		//debugPrint("sending: ${msg}");
		server?.send(msg);
		client?.send(msg);
	}

	bool get clientConnected {
		return (client?._channel ?? null) != null;
	}
}

List<int>? signalToMsg(MessageType msg, Matchday md, {int? additionalInfo}) {
	debugPrint("signalToMsg: ${msg}");
	// TODO Add all the DATA stuff, especially Widget toggeling
	if(msg == MessageType.DATA_GAME_ACTION)
		debugPrint("WARN: Game Actions sending is not implemented yet!");
	if(msg == MessageType.DATA_GAME) {
		if((additionalInfo ?? md.games.length) >= md.games.length) return null;
		return [msg.value, ... utf8.encode(jsonEncode(md.games[additionalInfo!]))];
	} else if(msg == MessageType.DATA_GAMEINDEX)
		return [msg.value, md.meta.gameIndex];
	else if(msg == MessageType.DATA_GAMEPART)
		return [msg.value, md.meta.currentGamepart];
	else if(msg == MessageType.DATA_PAUSE_ON)
		return [msg.value, md.meta.paused ? 1 : 0];
	else if(msg == MessageType.DATA_TIME)
		return [msg.value, ... u16ToBytes(md.meta.currentTime)];
	else if(msg == MessageType.DATA_GAMESCOUNT)
		return [msg.value, md.games.length];
	else if(msg == MessageType.DATA_SIDES_SWITCHED)
		return [msg.value, md.meta.sidesInverted ? 1 : 0];
	else if(msg == MessageType.DATA_JSON)
	  return utf8.encode(jsonEncode(md.toJson()));
	else if(msg == MessageType.DATA_WIDGET_SCOREBOARD_ON)
		return [msg.value, md.meta.widgetScoreboard ? 1 : 0];
	else if(msg == MessageType.DATA_WIDGET_GAMEPLAN_ON)
		return [msg.value, md.meta.widgetGameplan ? 1 : 0];
	else if(msg == MessageType.DATA_WIDGET_LIVETABLE_ON)
		return [msg.value, md.meta.widgetLiveplan ? 1 : 0];
	else if(msg == MessageType.DATA_WIDGET_GAMESTART_ON)
		return [msg.value, md.meta.widgetGamestart ? 1 : 0];
	else if(msg == MessageType.DATA_WIDGET_AD_ON)
		return [msg.value, md.meta.widgetAd ? 1 : 0];
	else if(msg == MessageType.DATA_OBS_STREAM_ON)
		return [msg.value, md.meta.streamStarted ? 1 : 0];
	else if(msg == MessageType.DATA_OBS_REPLAY_ON)
		return [msg.value, md.meta.replayStarted ? 1 : 0];
	else if(msg == MessageType.IM_THE_BOSS)
		return [msg.value, 1];
	else
		return [msg.value];
}
