import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:io';

import 'MessageType.dart';
import 'md.dart';
import 'lib.dart' as lib;

class WSServer {
	String _url;
	final Set<WebSocket> _clients = <WebSocket>{};
	HttpServer? _server;
	ValueNotifier<Matchday> _mdl;
	bool readonly = true;

	WSServer(this._url, this._mdl, {this.readonly = true});

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
			client.listen(
				_listen,
				onDone: () => _clients.remove(client),
				onError: (e) => debugPrint("grrr, client couldnt be connected properly!")
			);
		}
	}

	void _listen(final dynamic msg) {
		debugPrint("WS Server: Received message: ${msg}");
		if(msg is! List<int>) {
			debugPrint("WS Client: Received msg with unknown type(${msg.runtimeType}): ${msg}. Ignoring...");
			return;
		}
		if(msg.length == 0) {
			debugPrint("WS Client: Received empty message...");
			return;
		}

		// Parse the message
		_listenRead(msg);
		if(!readonly) {
			debugPrint("WARN: server is not readonly, but only readonly mode is supported right now! Skipping...");
		}
	}

	void _listenRead(final List<int> msg) {
		if(msg[0] == MessageType.PLS_SEND_META.value)
			sendSignal(MessageType.DATA_META);
		else if(msg[0] == MessageType.PLS_SEND_META_GAME.value)
			sendSignal(MessageType.DATA_META_GAME);
		else if(msg[0] == MessageType.PLS_SEND_META_OBS.value)
			sendSignal(MessageType.DATA_META_OBS);
		else if(msg[0] == MessageType.PLS_SEND_META_WIDGETS.value)
			sendSignal(MessageType.DATA_META_WIDGETS);
		else if(msg[0] == MessageType.PLS_SEND_GAMES.value)
			sendSignal(MessageType.DATA_GAMES);
		else if(msg[0] == MessageType.PLS_SEND_GAME.value)
			sendSignal(MessageType.DATA_GAME);
		else if(msg[0] == MessageType.PLS_SEND_GAMEACTIONS.value)
			sendSignal(MessageType.DATA_GAMEACTIONS);
		else if(msg[0] == MessageType.PLS_SEND_GAMEACTION.value)
			sendSignal(MessageType.DATA_GAMEACTION);
		else if(msg[0] == MessageType.PLS_SEND_FORMATS.value)
			sendSignal(MessageType.DATA_FORMATS);
		else if(msg[0] == MessageType.PLS_SEND_FORMAT.value)
			sendSignal(MessageType.DATA_FORMAT);
		else if(msg[0] == MessageType.PLS_SEND_TEAMS.value)
			sendSignal(MessageType.DATA_TEAMS);
		else if(msg[0] == MessageType.PLS_SEND_TEAM.value)
			sendSignal(MessageType.DATA_TEAM);
		else if(msg[0] == MessageType.PLS_SEND_GROUPS.value)
			sendSignal(MessageType.DATA_GROUPS);
		else if(msg[0] == MessageType.PLS_SEND_GROUP.value)
			sendSignal(MessageType.DATA_GROUP);
		else if(msg[0] == MessageType.PLS_SEND_IM_BOSS.value)
			sendSignal(MessageType.DATA_IM_BOSS);
		else if(msg[0] == MessageType.PLS_SEND_TIMESTAMP.value)
			sendSignal(MessageType.DATA_TIMESTAMP);
		else if(msg[0] == MessageType.PLS_SEND_JSON.value)
			sendSignal(MessageType.DATA_JSON);
		else {
			debugPrint("WS Server: Received unknown signal");
		}
	}


	void sendSignal(MessageType signal) {
		final msg = lib.signalToMsg(signal, _mdl.value);
		debugPrint("WS Server: sending ${msg}");
		if(msg != null) send(msg);
	}

	// We broadcast to all clients connected
	void send(List<int> data) {
		for (final client in _clients) {
			client.add(data);
		}
	}
}
