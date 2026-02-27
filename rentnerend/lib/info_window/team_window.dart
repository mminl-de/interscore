import 'dart:async';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../md.dart';
import '../ws_client.dart';
import '../lib.dart' as lib;


class TeamWindow extends StatefulWidget {
	const TeamWindow({super.key, required this.mdl, required this.ws, required this.teamIndex});

	final ValueNotifier<Matchday> mdl;
	final WSClient ws;
	final int teamIndex;

	@override
	State<TeamWindow> createState() => _TeamWindowState();
}

class _TeamWindowState extends State<TeamWindow> {
	late ValueNotifier<Matchday> mdl;
	late WSClient ws;
	late final int teamIndex;
	late Timer _reconnectTimer;

	@override
	void initState() {
		super.initState();

		mdl = widget.mdl;
		ws = widget.ws;
		teamIndex = widget.teamIndex;

		_reconnectTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
			if (!ws.connected.value && mounted) {
				lib.connectWS(ws);
			}
		});
	}

	@override
	void dispose() {
		_reconnectTimer.cancel();

		super.dispose();
	}

	final textGroup = AutoSizeGroup();

	final remainingTime = ValueNotifier<int>(0);

	Widget blockGame(Matchday md, Game g, int index, Color bg) {
		String t1name = g.team1.whenOrNull(
			byName: (name, _) => name,
			byQueryResolved: (name, __) => name,
		) ?? "[???]";

		String t2name = g.team2.whenOrNull(
			byName: (name, _) => name,
			byQueryResolved: (name, __) => name,
		) ?? "[???]";

		final int? t1_score = index <= md.meta.game.index ? g.teamGoals(1) : null;
		final int? t2_score = index <= md.meta.game.index ? g.teamGoals(2) : null;

		Color t1_color = Colors.grey;
		Color t2_color = Colors.grey;
		if(t1_score != null && t2_score != null) {
			if(t1_score > t2_score) {
				t1_color = Colors.green;
				t2_color = Colors.red;
			} else if (t2_score > t1_score) {
				t1_color = Colors.red;
				t2_color = Colors.green;
			} else {
				t1_color = Colors.orange;
				t2_color = Colors.orange;
			}
		}

		return Container(
				decoration: BoxDecoration(
					color: md.currentGame == g ? Colors.white.withValues(alpha: 0.3) : null,
				),
				child: Padding(
					padding: EdgeInsetsGeometry.symmetric(vertical: 5),
					child: Row(children: [
						Expanded(flex: 10, child: Center(child: Padding(padding: EdgeInsetsGeometry.only(left: 5), child: AutoSizeText(group: textGroup, maxLines: 1, g.name)))),
						Expanded(flex: 35, child: Center(child: AutoSizeText(group: textGroup, maxLines: 1, softWrap: true, t1name))),
						Expanded(flex: 20, child: Center(child: AutoSizeText.rich(group: textGroup, maxLines: 1, softWrap: true,
							TextSpan(children: [
								TextSpan(text: "${t1_score ?? '?'}", style: TextStyle(color: t1_color, fontWeight: FontWeight.bold)),
								const TextSpan(text: ' : '),
								TextSpan(text: "${t2_score ?? '?'}", style: TextStyle(color: t2_color, fontWeight: FontWeight.bold))
							])
						))),
						Expanded(flex: 35, child: Center(child: AutoSizeText(group: textGroup, maxLines: 1, softWrap: true, t2name)))
				]),
			)
		);
	}

	Widget blockGameplan(Matchday md, Color bg) {
		return Padding(
			padding: const EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 40),
			child: Material(
				color: bg,
				borderRadius: BorderRadius.circular(13),
				clipBehavior: Clip.hardEdge,
				child: Column(
					mainAxisSize: MainAxisSize.min,
					children: md.teamGames(md.teams[teamIndex].name, md.groups[0].name) // TODO make this work properly
						.entries
						.map((entry) => blockGame(md, entry.key, entry.value, bg))
						.toList()
				)
			)
		);
	}

	Widget blockWSStatus(Matchday md) {
		String? error;
		Color c = Colors.green;
		Function? f;
		if(!ws.connected.value) {
			error = "NOT CONNECTED TO SERVER";
			c = Colors.red;
			f = () => lib.connectWS(ws);
		}

		final double size = (error == null) ? 5 : 18;
		return Material(color: c, child:
			InkWell(
      			onTap: f as void Function()?,
				child: Container(
					width: double.infinity,
					child: Center(child: Text(
					   	error ?? "",
            		   	textAlign: TextAlign.center,
            		   	style: TextStyle( fontWeight: FontWeight.bold, fontSize: size),
					)),
				),
			)
		);
	}

	Widget blockTeamInfo(Team t, Color secondBgColor) {
		return Column(children: [
			Stack(fit: StackFit.passthrough, children: [
				Align( alignment: Alignment.centerLeft, child:
					BackButton(onPressed: () => Navigator.of(context).maybePop())),
				Center(child:
					Padding(padding: EdgeInsetsGeometry.only(left: 20, right: 20, top: 20, bottom: 5), child:
						AutoSizeText(
							t.name,
							maxLines: 1,
							style: const TextStyle(fontSize: 1000)
						)
					)
				)
			])
		]);
	}

	@override
	Widget build(BuildContext context) {
		final secondBgColor = Theme.of(context).scaffoldBackgroundColor;

		return PopScope(
			child: Scaffold(
				backgroundColor: Colors.black,
				body: SingleChildScrollView(
					child: ValueListenableBuilder<Matchday>(
						valueListenable: mdl,
						builder: (context, md, _) {
							return Column(
								mainAxisSize: MainAxisSize.min,
								children: [
									ValueListenableBuilder<bool>(
										valueListenable: ws.connected,
										builder: (context, _, __) {
											return blockWSStatus(md);
										}
									),
									blockTeamInfo(md.teams[teamIndex], secondBgColor),
									blockGameplan(md, secondBgColor),
								]
							);
						}
					)
				)
			)
		);
	}
}
