
// import 'package:web_socket_channel/web_socket_channel.dart';
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
	ValueNotifier<Matchday> _mdl;

	_WSServer(this._url, this._mdl);

	Future<void> run() async {
		debugPrint("WS Server: Starting...");
		// TODO how to handle failure because someone already got that port or url is illegal
		final server = await HttpServer.bind(Uri.parse(_url).host, Uri.parse(_url).port, shared: true);

		await for (final req in server) {
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
				debugPrint("got Message: ${msg}");
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
		debugPrint("WS Server: Sending: ${data}, with Type: ${data.runtimeType}");
		for (final client in _clients) {
			debugPrint("Sending to client!");
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

	Future<void> connect() async {
		debugPrint("Connecting to Server: {$_url}");
		try {
			// TODO check that this is successfull and reconnect if not
			_channel = await WebSocket.connect(_url);
			debugPrint("Connected: {$_url}");

			_channel!.listen(
				_listen,
				onDone: () => debugPrint("WS Client: Server \'${_url}\' closed connection"),
				onError: (err) => debugPrint("WS Client: ERR ${err}")
			);
		} catch (e) {
			debugPrint("WS Client: Connection failed with error: ${e}");
		}
	}

	void _listen(dynamic msg) {
		debugPrint("WS Client: Received message: ${msg}");
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
		if(     msg[0] == MessageType.DATA_WIDGET_SCOREBOARD_ON.value);
		else if(msg[0] == MessageType.DATA_WIDGET_GAMEPLAN_ON.value);
		else if(msg[0] == MessageType.DATA_WIDGET_LIVETABLE_ON.value);
		else if(msg[0] == MessageType.DATA_WIDGET_GAMESTART_ON.value);
		else if(msg[0] == MessageType.DATA_WIDGET_AD_ON.value);
		else if(msg[0] == MessageType.DATA_OBS_STREAM_ON.value);
		else if(msg[0] == MessageType.DATA_OBS_REPLAY_ON.value);
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
			debugPrint("grrr?");
			_mdl.value = Matchday.fromJson(jsonDecode(utf8.decode(msg)) as Map<String, dynamic>);
			debugPrint("grrr^22?");
		}
		else if(msg[0] == MessageType.PLS_SEND_GAMEINDEX.value)
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

	}

	sendSignal(MessageType signal) {
		final List<int>? msg = signalToMsg(signal, _mdl.value);
		if(msg == null) return;

		send(msg);
	}

	void send(List<int> msg) {
		debugPrint("WS Client: sending: ${msg}");
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

	void initServer(String url) {
		// TODO use mdl in Server?
		this.server = _WSServer(url, _mdl);
		// we dont await this, because it will run forever
		this.server?.run();
	}

	// Extra function is needed for await functionality
	Future<void> initClient(String url) async {
		client = _WSClient(url, _mdl);
		await this.client?.connect();
	}

	void sendSignal(MessageType signal) {
		final List<int>? msg = signalToMsg(signal, _mdl.value);
		if(msg == null) return;

		send(msg);
	}

	void send(List<int> msg) {
		debugPrint("sending: ${msg}");
		server?.send(msg);
		client?.send(msg);
	}

	bool get clientConnected {
		return (client?._channel ?? null) != null;
	}
}

List<int>? signalToMsg(MessageType msg, Matchday md) {
	debugPrint("signalToMsg: ${msg}");
	// TODO Add all the DATA stuff, especially Widget toggeling
	if(msg == MessageType.DATA_GAME_ACTION)
		debugPrint("WARN: Game Actions sending is not implemented yet!");
	else if(msg == MessageType.DATA_GAMEINDEX)
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
	return null;
}
