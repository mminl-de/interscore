import 'package:flutter/material.dart';

import 'dart:async';

import 'lib.dart' as lib;
import 'MessageType.dart';
import 'md.dart';

import 'ws_server.dart';
import 'ws_client.dart';

class InterscoreWS {
	late WSServer server;
	late WSClient client;
	// This is needed, so Matchday can be updated and trigger a UI redraw
	// Also we need the Matchday informations in sendSignal() to send them
	late final ValueNotifier<Matchday> _mdl;
	ValueNotifier<bool>? get connection => client.connected;

	// We have to use a "factory" so the constructor can be async
	InterscoreWS(String server_url, String client_url, this._mdl) {
		this.client = WSClient(client_url, _mdl);
		this.server = WSServer(server_url, _mdl);
		init();
	}

	void close() {
		server.close();
		client.close();
	}

	// Extra function is needed for await functionality
	Future<void> init() async {
		// we dont await this, because it will run forever
		this.server.run();
		await this.client.connect();
	}

	void sendSignal(MessageType signal, {int? additionalInfo}) {
		final List<int>? msg = lib.signalToMsg(signal, _mdl.value, additionalInfo: additionalInfo);
		if(msg == null) return;

		send(msg);

		// TODO CONSIDER only send games, not gameparts
		// TODO TEMP this seems odd, but we dont send gameactions right now, but rather the whole json
		// the other device doesnt accept json data though. It only acceps games. Therefor we also send the game
		if(signal == MessageType.DATA_JSON)
			sendSignal(MessageType.DATA_GAME, additionalInfo: _mdl.value.meta.gameIndex);
	}

	void send(List<int> msg) {
		debugPrint("sending: ${msg}");
		server.send(msg);
		client.send(msg);
	}

	bool get clientConnected {
		return client.connected.value;
	}
}
