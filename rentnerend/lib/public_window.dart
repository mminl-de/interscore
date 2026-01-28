import 'dart:async';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'md.dart';
import 'websocket.dart';
import 'lib.dart';


class PublicWindow extends StatefulWidget {
	const PublicWindow({super.key, required this.mdl, required this.ws});

	final ValueNotifier<Matchday> mdl;
	final InterscoreWS ws;

	@override
	State<PublicWindow> createState() => _PublicWindowState();
}

class _PublicWindowState extends State<PublicWindow> {
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

	final teamsTextGroup = AutoSizeGroup();

	Widget blockTeam(String name, int goals) {
		return Column(children: [
			Expanded(flex: 5, child: SizedBox(width: 5)),
			Expanded(flex: 15, child: Center(child: AutoSizeText(
				name,
				maxLines: 1,
				group: teamsTextGroup,
				style: const TextStyle(fontSize: 1000, fontWeight: FontWeight.bold, height: 0.9)
			))),
			Expanded(flex: 73, child: Center(child: AutoSizeText(
				goals.toString(),
				maxLines: 1,
				style: const TextStyle(fontSize: 1000, height: 0.9,)
			))),
			Expanded(flex: 2, child: SizedBox(width: 5)),
		]);
	}

	Widget blockTeams(Matchday md) {
		// We invert by default
		String t1name = md.currentGame.team2.whenOrNull(
			byName: (name, _) => name,
			byQueryResolved: (name, __) => name,
		) ?? "[???]";

		String t2name = md.currentGame.team1.whenOrNull(
			byName: (name, _) => name,
			byQueryResolved: (name, __) => name,
		) ?? "[???]";

		final int inverted = ((md.meta.sidesInverted ? 1 : 0) - (md.currentGamepart!.sidesInverted ? 1 : 0)).abs();
		final int t1_score = md.currentGame.teamGoals(2 - inverted);
		final int t2_score = md.currentGame.teamGoals(1 + inverted);

		final String gameName = md.currentGame.name;

		if(md.meta.sidesInverted) {
			final tmp = t1name;
			t1name = t2name;
			t2name = tmp;
		}
		if(md.currentGamepart!.sidesInverted) {
			final tmp = t1name;
			t1name = t2name;
			t2name = tmp;
		}

		final t1_color = colorFromHexString(md.teamFromName(t1name)?.color ?? "#ffffff");
		final t2_color = colorFromHexString(md.teamFromName(t2name)?.color ?? "#ffffff");

		final String curTimeMin = (md.meta.currentTime ~/ 60).toString().padLeft(2, '0');
		final String curTimeSec = (md.meta.currentTime % 60).toString().padLeft(2, '0');
		final curTimeString = "${curTimeMin}:${curTimeSec}";

		return Column(children: [
			Expanded(flex: 140, child: Container(color: Colors.black, child:
				Center(child: AutoSizeText(
					gameName,
					maxLines: 1,
					style: const TextStyle(fontSize: 1000, height: 1.5)
				))
			)),
			Expanded(flex: 610, child:
				Row(children: [
					Expanded(flex: 150, child: Container(color: t1_color, child: blockTeam(t1name, t1_score))),
					Expanded(flex: 2, child: Container(color: Colors.black, child: SizedBox.expand())),
					Expanded(flex: 150, child: Container(color: t2_color, child: blockTeam(t2name, t2_score))),
				])
			),
			// Expanded(flex: 1, child: SizedBox.expand()),
			// Expanded(flex: 2, child: Container(color: Colors.green, child: SizedBox.expand())),
			Expanded(flex: 10, child: Container(color: Colors.black, child: SizedBox.expand())),
			Expanded(flex: 240, child: Container(color: Colors.green, child:
				Center(child: Transform.translate(
    offset: const Offset(0, -8), child: AutoSizeText(
					curTimeString,
					maxLines: 1,
					style: const TextStyle(fontSize: 1000, height: 0.85,   fontFamily: 'RobotoMono',)
				))
			))),
			// Expanded(flex: 1, child: Container(color: Colors.green, child: SizedBox.expand())),
		]);
	}

	@override
	Widget build(BuildContext context) {
		// debugPrint("Matchday: ${mdl.value}\n\n");
		// debugPrint("Matchday Generated: ${JsonEncoder.withIndent('  ').convert(mdl.value.toJson())}");
		return PopScope(
			child: Scaffold(
				body: ValueListenableBuilder<Matchday>(
					valueListenable: mdl,
					builder: (context, md, _) {
						return Column(
							children: [
								Expanded(child: blockTeams(md)),
							]
						);
					}
				)
			)
		);
	}
}
