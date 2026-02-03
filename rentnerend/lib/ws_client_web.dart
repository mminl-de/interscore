import 'package:flutter/material.dart';

import 'dart:typed_data';
import 'package:web/web.dart';
import 'dart:js_interop';

import 'ws_client.dart';
import 'md.dart';

class WSClientWeb extends WSClient{
	WebSocket? _ws;

	WSClientWeb(String url, ValueNotifier<Matchday> mdl, bool allowRead, bool allowWrite) :
		super(url, mdl, allowRead, allowWrite);

	@override
	Future<void> connect() async {
		if (connected.value) return;
		debugPrint("Connecting to Server: ${url}");
		try {
			final ws = WebSocket(url);
			ws.binaryType = 'arraybuffer';

			ws.onopen = ((Event e) {
				debugPrint("Connected '${url}'");
				connected.value = true;
			}).toJS;
			ws.onmessage = ((MessageEvent e) {
				final JSAny? data = e.data;
				if(data == null) return;

				if (data.isA<JSArrayBuffer>())
					super.listen((data as JSArrayBuffer).toDart.asUint8List());
				else
					debugPrint("WS Client: Non-binary message ignored: $data");
			}).toJS;
			ws.onerror = ((Event e) {
				debugPrint("WS Client: ERR");
				connected.value = false;
				_ws = null;
			}).toJS;
			ws.onclose = ((CloseEvent e) {
				debugPrint("WS Client: Server '$url' closed connection");
				connected.value = false;
				_ws = null;
			}).toJS;

			_ws = ws;
		} catch (e) {
			debugPrint("WS Client: Connection failed with error: ${e}");
			_ws = null;
		}
	}

	@override
	void send(List<int> msg) {
		debugPrint("WS Client: sending: ${msg}");
		_ws?.send(Uint8List.fromList(msg).toJS);
	}

	@override
	void close() {
		_ws?.close();
		_ws = null;
		boss = false;
	}
}

WSClient createClient(String url, ValueNotifier<Matchday> mdl, bool allowRead, bool allowWrite) {
		return WSClientWeb(url, mdl, allowRead, allowWrite);
}
