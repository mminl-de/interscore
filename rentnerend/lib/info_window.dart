import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'md.dart';
import 'ws_client.dart';
import 'lib.dart';


class InfoWindow extends StatefulWidget {
	const InfoWindow({super.key, required this.mdl, required this.ws});

	final ValueNotifier<Matchday> mdl;
	final WSClient ws;

	@override
	State<InfoWindow> createState() => _InfoWindowState();
}

class _InfoWindowState extends State<InfoWindow> {
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

	final teamsTextGroup = AutoSizeGroup();

	Widget blockCurGame(Matchday md) {
		final String curTimeMin = (md.meta.currentTime ~/ 60).toString().padLeft(2, '0');
		final String curTimeSec = (md.meta.currentTime % 60).toString().padLeft(2, '0');
		final curTimeString = "${curTimeMin}:${curTimeSec}";

		String t1name = md.currentGame.team1.whenOrNull(
			byName: (name, _) => name,
			byQueryResolved: (name, __) => name,
		) ?? "[???]";

		String t2name = md.currentGame.team2.whenOrNull(
			byName: (name, _) => name,
			byQueryResolved: (name, __) => name,
		) ?? "[???]";

		final int t1_score = md.currentGame.teamGoals(1);
		final int t2_score = md.currentGame.teamGoals(2);

		return Padding(
			padding: EdgeInsetsGeometry.symmetric(vertical: 20, horizontal: 20),
			child: Container(
				decoration: BoxDecoration(
					color: Colors.black,
					borderRadius: BorderRadius.circular(40),
				),
				child: Row(children: [
						Expanded(flex: 10, child: Center(child: Text(curTimeString))),
						Expanded(flex: 35, child: Center(child: Text(t1name))),
						Expanded(flex: 20, child: Center(child: Text("$t1_score : $t2_score"))),
						Expanded(flex: 35, child: Center(child: Text(t2name)))
				]),
			)

		);
	}

	Widget blockGame(Game g) {
		String t1name = g.team1.whenOrNull(
			byName: (name, _) => name,
			byQueryResolved: (name, __) => name,
		) ?? "[???]";

		String t2name = g.team2.whenOrNull(
			byName: (name, _) => name,
			byQueryResolved: (name, __) => name,
		) ?? "[???]";

		final int t1_score = g.teamGoals(1);
		final int t2_score = g.teamGoals(2);

		return Padding(
			padding: EdgeInsetsGeometry.symmetric(vertical: 5, horizontal: 20),
			child: Container(
				decoration: BoxDecoration(
					color: Colors.black,
					borderRadius: BorderRadius.circular(40),
				),
				child: Row(children: [
						Expanded(flex: 10, child: Center(child: Text(g.name))),
						Expanded(flex: 35, child: Center(child: Text(t1name))),
						Expanded(flex: 20, child: Center(child: Text("$t1_score : $t2_score"))),
						Expanded(flex: 35, child: Center(child: Text(t2name)))
				]),
			)

		);
	}

	Widget blockGameplan(Matchday md) {
		return Column(children: md.games.map((g) => blockGame(g)).toList());
	}

	@override
	Widget build(BuildContext context) {
		return PopScope(
			child: Scaffold(
				body: ValueListenableBuilder<Matchday>(
					valueListenable: mdl,
					builder: (context, md, _) {
						return Column(
							children: [
								Expanded(flex: 10, child: blockCurGame(md)),
								Expanded(flex: 90, child: blockGameplan(md)),
							]
						);
					}
				)
			)
		);
	}
}
