import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//import 'package:just_audio/just_audio.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:flutter_rentnerend/MessageType.dart';
import 'package:flutter_rentnerend/lib.dart';
import 'package:flutter_rentnerend/md.dart';
import 'package:flutter_rentnerend/websocket.dart';

class ControllerWindow extends StatefulWidget {
	const ControllerWindow({super.key, required this.mdl, required this.ws});

	final ValueNotifier<Matchday> mdl;
	final InterscoreWS ws;

	@override
	State<ControllerWindow> createState() => _InputControllerState();
}

class _InputControllerState extends State<ControllerWindow> {
	late ValueNotifier<Matchday> mdl;
	late InterscoreWS ws;

	@override
	void initState() {
		super.initState();

		mdl = widget.mdl;
		ws = widget.ws;

		ws.connection?.addListener(() {
			if (!ws.connection!.value && mounted) {
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
					mdl.value = md.copyWith(meta: md.meta.copyWith(widgetScoreboard: !md.meta.widgetScoreboard));
					ws.sendSignal(MessageType.DATA_WIDGET_SCOREBOARD_ON);
			}, Text("Scoreboard"), inverted: md.meta.widgetScoreboard))),
			Expanded(child: SizedBox(width: double.infinity, child: buttonWithChild(context, () {
				mdl.value = md.copyWith(meta: md.meta.copyWith(widgetGameplan: !md.meta.widgetGameplan));
				ws.sendSignal(MessageType.DATA_WIDGET_GAMEPLAN_ON);
			}, Text("Gameplan"), inverted: md.meta.widgetGameplan))),
			Expanded(child: SizedBox(width: double.infinity, child: buttonWithChild(context, () {
				mdl.value = md.copyWith(meta: md.meta.copyWith(widgetLiveplan: !md.meta.widgetLiveplan));
				ws.sendSignal(MessageType.DATA_WIDGET_LIVETABLE_ON);
			}, Text("Liveplan"), inverted: md.meta.widgetLiveplan))),
			Expanded(child: SizedBox(width: double.infinity, child: buttonWithChild(context, () {
				mdl.value = md.copyWith(meta: md.meta.copyWith(widgetGamestart: !md.meta.widgetGamestart));
				ws.sendSignal(MessageType.DATA_WIDGET_GAMESTART_ON);
			}, Text("Gamestart"), inverted: md.meta.widgetGamestart))),
			Expanded(child: SizedBox(width: double.infinity, child: buttonWithChild(context, () {
				mdl.value = md.copyWith(meta: md.meta.copyWith(widgetAd: !md.meta.widgetAd));
				ws.sendSignal(MessageType.DATA_WIDGET_AD_ON);
			}, Text("Ad"), inverted: md.meta.widgetAd))),
			Expanded(child: SizedBox(width: double.infinity, child: buttonWithChild(context, () {
				mdl.value = md.copyWith(meta: md.meta.copyWith(streamStarted: !md.meta.streamStarted));
				ws.sendSignal(MessageType.DATA_OBS_STREAM_ON);
			}, Text("Stream starten"), inverted: md.meta.streamStarted))),
			Expanded(child: SizedBox(width: double.infinity, child: buttonWithChild(context, () {
				mdl.value = md.copyWith(meta: md.meta.copyWith(replayStarted: !md.meta.replayStarted));
				ws.sendSignal(MessageType.DATA_OBS_REPLAY_ON);
			}, Text("Start Replay"), inverted: md.meta.replayStarted)))
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
									// Expanded(flex: 18, child: blockTeams(md)),
									// Expanded(flex: 25, child: blockGoals(md)),
									// Expanded(flex: 35, child: blockTime(md)),
									Expanded(flex: 100, child: blockWidgets(md))
									//Expanded(flex: 25, child: blockTeams(md, recAct)),
									//Expanded(flex: 33, child: blockGoals(md, recAct)),
									//Expanded(flex: 42, child: blockTime(md, recAct)),
								]
							);
						}
					)
				)
			)
		);
	}
}
