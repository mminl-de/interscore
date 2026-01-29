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

	WSServer(this._url, this._mdl);

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
		final msg = lib.signalToMsg(signal, _mdl.value);
		if(msg != null) send(msg);
	}

	// We broadcast to all clients connected
	void send(List<int> data) {
		for (final client in _clients) {
			client.add(data);
		}
	}
}
