// import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

//import 'package:just_audio/just_audio.dart';
// import 'package:auto_size_text/auto_size_text.dart';

import 'MessageType.dart';
import 'lib.dart';
import 'md.dart';
import 'ws_client.dart';

class ControllerWindow extends StatefulWidget {
	const ControllerWindow({super.key, required this.mdl, required this.ws});

	final ValueNotifier<Matchday> mdl;
	final WSClient ws;

	@override
	State<ControllerWindow> createState() => _InputControllerState();
}

class _InputControllerState extends State<ControllerWindow> {
	late ValueNotifier<Matchday> mdl;
	late WSClient ws;

	@override
	void initState() {
		super.initState();

		mdl = widget.mdl;
		ws = widget.ws;

		ws.connected.addListener(() {
			if (!ws.connected.value && mounted) {
				Navigator.of(context).pop();
			}
		});
	}

	@override
	void dispose() {
		ws.close();
		mdl.dispose();

		super.dispose();
	}

	Widget blockWidgets(Matchday md) {
		return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, spacing: 8, children: [
			Expanded(child: SizedBox(
				width: double.infinity,
				child: buttonWithChild(context, () {
					mdl.value = md.copyWith(meta: md.meta.copyWith(widgets: md.meta.widgets.copyWith(scoreboard: !md.meta.widgets.scoreboard)));
					ws.sendSignal(MessageType.DATA_META_WIDGETS);
			}, Text("Scoreboard"), inverted: md.meta.widgets.scoreboard))),
			Expanded(child: SizedBox(width: double.infinity, child: buttonWithChild(context, () {
				mdl.value = md.copyWith(meta: md.meta.copyWith(widgets: md.meta.widgets.copyWith(gameplan: !md.meta.widgets.gameplan)));
				ws.sendSignal(MessageType.DATA_META_WIDGETS);
			}, Text("Gameplan"), inverted: md.meta.widgets.gameplan))),
			Expanded(child: SizedBox(width: double.infinity, child: buttonWithChild(context, () {
				mdl.value = md.copyWith(meta: md.meta.copyWith(widgets: md.meta.widgets.copyWith(liveplan: !md.meta.widgets.liveplan)));
				ws.sendSignal(MessageType.DATA_META_WIDGETS);
			}, Text("Liveplan"), inverted: md.meta.widgets.liveplan))),
			Expanded(child: SizedBox(width: double.infinity, child: buttonWithChild(context, () {
				mdl.value = md.copyWith(meta: md.meta.copyWith(widgets: md.meta.widgets.copyWith(gamestart: !md.meta.widgets.gamestart)));
				ws.sendSignal(MessageType.DATA_META_WIDGETS);
			}, Text("Gamestart"), inverted: md.meta.widgets.gamestart))),
			Expanded(child: SizedBox(width: double.infinity, child: buttonWithChild(context, () {
				mdl.value = md.copyWith(meta: md.meta.copyWith(widgets: md.meta.widgets.copyWith(ad: !md.meta.widgets.ad)));
				ws.sendSignal(MessageType.DATA_META_WIDGETS);
			}, Text("Ad"), inverted: md.meta.widgets.ad))),
			Expanded(child: SizedBox(width: double.infinity, child: buttonWithChild(context, () {
				debugPrint("WARN: This action is disabled at the moment!");
				// mdl.value = md.copyWith(meta: md.meta.copyWith(obs: md.meta.obs.copyWith(streamStarted: !md.meta.obs.streamStarted)));
				// mdl.value = md.copyWith(meta: md.meta.copyWith(streamStarted: !md.meta.streamStarted));
				// ws.sendSignal(MessageType.DATA_OBS_STREAM_ON);
			}, Text("Stream starten"), inverted: md.meta.obs.streamStarted ?? false))), // TODO This is tmp
			Expanded(child: SizedBox(width: double.infinity, child: buttonWithChild(context, () {
				debugPrint("WARN: This action is disabled at the moment!");
				// mdl.value = md.copyWith(meta: md.meta.copyWith(replayStarted: !md.meta.replayStarted));
				// ws.sendSignal(MessageType.DATA_OBS_REPLAY_ON);
			}, Text("Start Replay"), inverted: md.meta.obs.replayStarted ?? false))) // TODO This is tmp
		]);
	}

	@override
	Widget build(BuildContext context) {
		// debugPrint("Matchday: ${mdl.value}\n\n");
		// debugPrint("Matchday Generated: ${JsonEncoder.withIndent('  ').convert(mdl.value.toJson())}");
		return PopScope(
			child: Focus(
				autofocus: true,
				child: Scaffold(
					appBar: AppBar(title: const Text('Input Window')),
					body: ValueListenableBuilder<Matchday>(
						valueListenable: mdl,
						builder: (context, md, _) {
							return Column(
								children: [
									Expanded(flex: 100, child: blockWidgets(md))
									// Log messages
									// OBS live stream
								]
							);
						}
					)
				)
			)
		);
	}
}
