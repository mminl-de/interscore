import 'package:flutter/material.dart';

import 'dart:async';

import 'lib.dart' as lib;
import 'MessageType.dart';
import 'md.dart';

import 'ws_server.dart';
import 'ws_client.dart';
import 'ws_client_factory.dart';

class InterscoreWS {
	late WSServer server;
	late WSClient client;
	// This is needed, so Matchday can be updated and trigger a UI redraw
	// Also we need the Matchday informations in sendSignal() to send them
	late final ValueNotifier<Matchday> _mdl;
	ValueNotifier<bool>? get connection => client.connected;

	// We have to use a "factory" so the constructor can be async
	InterscoreWS(String server_url, String client_url, this._mdl) {
		this.client = createWSClient(client_url, _mdl, true, false);
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
		// We let the caller do this
		// await this.client.connect();
	}

	void sendSignal(final MessageType signal, {final int? additionalInfo, final int? additionalInfo2, final Matchday? md}) {
		final List<int>? msg = lib.signalToMsg(signal, md ?? _mdl.value, additionalInfo: additionalInfo, additionalInfo2: additionalInfo2);
		if(msg == null) return;

		send(msg);

		// TODO CONSIDER only send games, not gameparts
		// TODO TEMP this seems odd, but we dont send gameactions right now, but rather the whole json
		// the other device doesnt accept json data though. It only acceps games. Therefor we also send the game
		// TODO Is this still needed? Who doesnt accept DATA_JSON but DATA_GAME?
		if(signal == MessageType.DATA_JSON)
			sendSignal(MessageType.DATA_GAME, additionalInfo: _mdl.value.meta.game.index);
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
