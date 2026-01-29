import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'md.dart';
import 'ws_client.dart';
import 'lib.dart';


class InfosWindow extends StatefulWidget {
	const InfosWindow({super.key, required this.mdl, required this.ws});

	final ValueNotifier<Matchday> mdl;
	final WSClient ws;

	@override
	State<InfosWindow> createState() => _PublicWindowState();
}

class _PublicWindowState extends State<InfosWindow> {
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

		return Row(children: [
			Text(curTimeString),
			Text(t1name),
			Text("$t1_score : $t2_score"),
			Text(t2name)
		]);
	}

	Widget blockGame(Game g) {
		return Row(children: [

		]);
	}

	Widget blockGameplan(Matchday md) {

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
