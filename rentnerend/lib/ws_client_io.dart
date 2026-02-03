import 'package:flutter/material.dart';

import 'dart:io';

import 'ws_client.dart';
import 'md.dart';

class WSClientIO extends WSClient {
	WebSocket? _ws;

	WSClientIO(String url, ValueNotifier<Matchday> mdl, bool allowRead, bool allowWrite) :
		super(url, mdl, allowRead, allowWrite);

	@override
	Future<void> connect() async {
		if (connected.value) return;
		debugPrint("Connecting to Server: ${url}");
		try {
			_ws = await WebSocket.connect(url);
			debugPrint("Connected: ${url}");
			connected.value = true;

			_ws!.listen(
				listen,
				onDone: () {
					debugPrint("WS Client: Server \'${url}\' closed connection");
					connected.value = false;
					_ws = null;
					boss = false;
				},
				onError: (err) {
					debugPrint("WS Client: ERR ${err}");
					connected.value = false;
					_ws = null;
					boss = false;
				}
			);
		} catch (e) {
			debugPrint("WS Client: Connection failed with error: ${e}");
			_ws = null;
			boss = false;
		}
	}

	@override
	void send(List<int> msg) {
		debugPrint("WS Client: sending: ${msg}");
		_ws?.add(msg);
	}

	@override
	void close() {
		_ws?.close();
		_ws = null;
		boss = false;
	}
}

WSClient createClient(String url, ValueNotifier<Matchday> mdl, bool allowRead, bool allowWrite) {
		return WSClientIO(url, mdl, allowRead, allowWrite);
}
