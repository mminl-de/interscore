import 'dart:async';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'md.dart';
import 'ws_client.dart';
import 'MessageType.dart';


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
	late Timer _reconnectTimer;

	@override
	void initState() {
		super.initState();

		mdl = widget.mdl;
		ws = widget.ws;

		_reconnectTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
			if (!ws.connected.value && mounted) {
				connectWS();
			}
		});

		startTimer();
	}

	@override
	void dispose() {
		_timer?.cancel();
		_reconnectTimer.cancel();

		ws.close();
		mdl.dispose();

		super.dispose();
	}

	Future<void> connectWS() async {
		ws.connect();
		// TODO add quitting after 1sec or smth
		await Future.doWhile(() async {
			await Future.delayed(Duration(milliseconds: 10));
			return !ws.connected.value;
		});
		if(!ws.connected.value) return;

		ws.sendSignal(MessageType.DATA_JSON);
	}

	final textGroup = AutoSizeGroup();

	final remainingTime = ValueNotifier<int>(0);
	Timer? _timer;

	void startTimer() {
		_timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
			final curTime = mdl.value.currentTime();
			if(remainingTime.value != curTime)
				remainingTime.value = curTime;
		});
	}

	Widget blockCurGame(Matchday md, Color bg) {
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

		Color t1_color = Colors.grey;
		Color t2_color = Colors.grey;
		if(t1_score > t2_score) {
			t1_color = Colors.green;
			t2_color = Colors.red;
		} else if (t2_score > t1_score) {
			t1_color = Colors.red;
			t2_color = Colors.green;
		}


		return Padding(
			padding: EdgeInsetsGeometry.symmetric(vertical: 20, horizontal: 20),
			child: Container(
				decoration: BoxDecoration(
					color: bg,
					borderRadius: BorderRadius.circular(40),
				),
				child: Row(children: [
						Expanded(flex: 15, child:
							Padding(padding: EdgeInsetsGeometry.all(5), child:
								Container(
									decoration: BoxDecoration(
										color: md.meta.time.paused ? Colors.yellow : Colors.green,
										borderRadius: BorderRadius.circular(40),
									),
									child: ValueListenableBuilder<int>(
										valueListenable: remainingTime,
										builder: (_, time, __) {
											final String curTimeMin = (time ~/ 60).toString().padLeft(2, '0');
											final String curTimeSec = (time % 60).toString().padLeft(2, '0');
											final curTimeString = "${curTimeMin}:${curTimeSec}";

											return Center(child: AutoSizeText(group: textGroup, curTimeString, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)));
										}
									)
								)
							),
						),
						Expanded(flex: 30, child: Center(child: AutoSizeText(group: textGroup, maxLines: 1, softWrap: true, t1name))),
						Expanded(flex: 20, child: Center(child: AutoSizeText.rich(group: textGroup, maxLines: 1, softWrap: true,
							TextSpan(children: [
								TextSpan(text: "$t1_score", style: TextStyle(color: t1_color, fontWeight: FontWeight.bold)),
								const TextSpan(text: ' : '),
								TextSpan(text: "$t2_score", style: TextStyle(color: t2_color, fontWeight: FontWeight.bold))
							])
						))),
						Expanded(flex: 30, child: Center(child: AutoSizeText(group: textGroup, maxLines: 1, softWrap: true, t2name)))
				]),
			)

		);
	}

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
					children: [
						for(int i=0; i < md.games.length; i++) ...[
							if (i > 0)
								const Divider(height: 1, thickness: 0.5, color: Colors.white),
							blockGame(md, md.games[i], i, bg)
						]
					]
				)
			)
		);
	}

	TableRow blockLivetableTeam(Matchday md, Group g, Team t, int index, Color bg) {
		final gamesAmount = md.teamGamesPlayed(t.name, g.name).length;
		final gamesWon = md.teamGamesWon(t.name, g.name).length;
		final gamesTied = md.teamGamesTied(t.name, g.name).length;
		final gamesLost = md.teamGamesLost(t.name, g.name).length;
		final goalsPlus = md.teamGoalsPlus(t.name, g.name);
		final goalsMinus = md.teamGoalsMinus(t.name, g.name);

  		const style = TextStyle(fontFeatures: [FontFeature.tabularFigures()]);

		Widget num(dynamic v, {bool fat = false}) => Center(child:
			Padding(
          		padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          		child: Text("$v", maxLines: 1,
					style: TextStyle(fontFeatures: [FontFeature.tabularFigures()], fontWeight: fat ? FontWeight.bold : FontWeight.normal)),
        	),
      	);

		return TableRow(
			decoration: BoxDecoration(
				color: index > 1 ? bg : Colors.green.withValues(alpha: 0.5),
				//borderRadius: BorderRadius.circular(40),
    		),
    		children: [
      			Padding( padding: const EdgeInsets.symmetric(horizontal: 6), child: num(index+1)),
				Padding(
					padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
					child: Text(t.name, style: style, maxLines: 1)
				),
      			num(gamesAmount),
      			num(gamesWon),
      			num(gamesTied),
      			num(gamesLost),
      			num("$goalsPlus : $goalsMinus"),
      			num(goalsPlus - goalsMinus),
      			num(md.teamPoints(t.name, g.name), fat: true),
    		],
  		);
	}


	Widget blockLivetable(Matchday md, Group g, Color bg) {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 10),
			child: Material(
				color: bg,
				borderRadius: BorderRadius.circular(13),
				clipBehavior: Clip.hardEdge,
				child: Padding(padding: const EdgeInsets.only(top: 4), child: Table(
					defaultVerticalAlignment: TableCellVerticalAlignment.middle,
					columnWidths: const {
						0: IntrinsicColumnWidth(), // GP
						1: FlexColumnWidth(),   // team
						2: IntrinsicColumnWidth(), // GP
						3: IntrinsicColumnWidth(), // W
						4: IntrinsicColumnWidth(), // D
						5: IntrinsicColumnWidth(), // L
						6: IntrinsicColumnWidth(), // goals
						7: IntrinsicColumnWidth(), // diff
						8: IntrinsicColumnWidth(), // pts
					},
					children: [
						TableRow( children: [
							Padding(padding: const EdgeInsets.only(left: 14), child: Text("P")),
							Padding(padding: const EdgeInsets.only(left: 12), child: Text("Team")),
							Center(child: Text("SP")),
							Center(child: Text("S")),
							Center(child: Text("U")),
							Center(child: Text("N")),
							Center(child: Text("Tore")),
							Center(child: Text("Diff")),
							Center(child: Text("P")),
						],
					),
					...md
					.rankingFromGroup(g.name)!
					.entries.toList().asMap().entries
					.map((e) => blockLivetableTeam(md, g, md.teamFromName(e.value.key)!, e.key, bg))
					.toList(),
					]
				)),
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
			f = () => connectWS();
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
									blockCurGame(md, secondBgColor),
									blockGameplan(md, secondBgColor),
									blockLivetable(md, md.groups[0], secondBgColor),
								]
							);
						}
					)
				)
			)
		);
	}
}
