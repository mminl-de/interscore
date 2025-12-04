
import 'package:web_socket_channel/web_socket_channel.dart';
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

	_WSServer(this._url);

	Future<void> run() async {
		debugPrint("WS Server: Starting...");
		// TODO how to handle failure because someone already got that port or url is illegal
		final server = await HttpServer.bind(Uri.parse(_url).host, Uri.parse(_url).port);

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
			client.listen((msg) {}, onDone: () => _clients.remove(client), onError: (e) => debugPrint("grrr, client couldnt be connected properly!"));
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

	void connect() async {
		debugPrint("Connecting to Server: {$_url}");
		try {
			// TODO check that this is successfull and reconnect if not
			_channel = WebSocketChannel.connect(Uri.parse(_url));

			await _channel.ready.timeout(
				const Duration(seconds: 5),
				onTimeout: () => throw TimeoutException("Cant connect to server")
			);

			debugPrint("Connecting to Server..");
			_channel.stream.listen(
				_listen,
				onDone: () => debugPrint("WS Client: Server \'${_url}\' closed connection"),
				onError: (err) => debugPrint("WS Client: ERR ${err}")
			);
		} catch (e) {
			debugPrint("WS Client: Connection failed with error: ${e}");
		}
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
		else if(msg[0] == MessageType.DATA_JSON.value)
			_mdl.value = Matchday.fromJson(jsonDecode(msg.toString()));
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

	void send(dynamic msg) {
		_channel.sink.add(msg);
	}
}

class InterscoreWS {
	_WSServer? server;
	_WSClient? client;
	// This is needed, so Matchday can be updated and trigger a UI redraw
	// Also we need the Matchday informations in sendSignal() to send them
	late final ValueNotifier<Matchday> _mdl;

	InterscoreWS({required String clientUrl, String? serverUrl, required mdl, bool server = true}) {
		debugPrint("server: ${server}, serverURL: ${serverUrl}");
		if(server && serverUrl != null) {
			this.server = _WSServer(serverUrl);
			this.server?.run();
		}
		client = _WSClient(clientUrl, mdl);
		this.client?.connect();
		this._mdl = mdl;
	}

	void sendSignal(MessageType signal) {
		final List<int>? msg = signalToMsg(signal, _mdl.value);
		if(msg == null) return;

		send(msg);
	}

	void send(dynamic msg) {
		server?.send(msg);
		client?.send(msg);
	}
}

List<int>? signalToMsg(MessageType msg, Matchday md) {
	// TODO Add all the DATA stuff, especially Widget toggeling
	if(msg == MessageType.DATA_GAME_ACTION.value)
		debugPrint("WARN: Game Actions sending is not implemented yet!");
	if(msg == MessageType.DATA_GAME_ACTION.value)
		debugPrint("WARN: Not implemented yet!");
	else if(msg == MessageType.DATA_GAMEINDEX.value)
		return [msg.value, md.meta.gameIndex];
	else if(msg == MessageType.DATA_GAMEPART.value)
		return [msg.value, md.meta.currentGamepart];
	else if(msg == MessageType.DATA_PAUSE_ON.value)
		return [msg.value, md.meta.paused ? 1 : 0];
	else if(msg == MessageType.DATA_TIME.value)
		return [msg.value, ... u16ToBytes(md.meta.currentTime)];
	else if(msg == MessageType.DATA_GAMESCOUNT.value)
		return [msg.value, md.games.length];
	else if(msg == MessageType.DATA_JSON.value)
		return utf8.encode(jsonEncode(md.toJson()));
	else
		return [msg.value];
	return null;
}
