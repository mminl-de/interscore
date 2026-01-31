import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_rentnerend/lib.dart';

import 'md.dart';
import 'ws_client.dart';


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

	final textGroup = AutoSizeGroup();

	Widget blockCurGame(Matchday md) {
		final String curTimeMin = (md.currentTime() ~/ 60).toString().padLeft(2, '0');
		final String curTimeSec = (md.currentTime() % 60).toString().padLeft(2, '0');
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
					color: Colors.black,
					borderRadius: BorderRadius.circular(40),
				),
				child: Row(children: [
						Expanded(flex: 15, child:
							Padding(padding: EdgeInsetsGeometry.all(5), child:
							Container(
								decoration: BoxDecoration(
								color: md.meta.paused ? Colors.red : Colors.green,
								borderRadius: BorderRadius.circular(40),
							),
							child: Center(child: AutoSizeText(group: textGroup, curTimeString)))
							)
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

	Widget blockGame(Matchday md, Game g, int index) {
		String t1name = g.team1.whenOrNull(
			byName: (name, _) => name,
			byQueryResolved: (name, __) => name,
		) ?? "[???]";

		String t2name = g.team2.whenOrNull(
			byName: (name, _) => name,
			byQueryResolved: (name, __) => name,
		) ?? "[???]";

		final int? t1_score = index <= md.meta.gameIndex ? g.teamGoals(1) : null;
		final int? t2_score = index <= md.meta.gameIndex ? g.teamGoals(2) : null;

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
				t1_color = Colors.yellow;
				t2_color = Colors.yellow;
			}
		}

		final textColor = TextStyle(color: md.currentGame == g ? Colors.black : null);

		return Padding(
			padding: EdgeInsetsGeometry.symmetric(vertical: 2, horizontal: 20),
			child: Container(
				decoration: BoxDecoration(
					color: md.currentGame == g ? Colors.white.withValues(alpha: 0.8): Colors.black,
					borderRadius: BorderRadius.circular(40),
				),
				child: Row(children: [
						Expanded(flex: 10, child: Center(child: Padding(padding: EdgeInsetsGeometry.only(left: 5), child: AutoSizeText(group: textGroup, maxLines: 1, style: textColor, g.name)))),
						Expanded(flex: 35, child: Center(child: AutoSizeText(group: textGroup, maxLines: 1, style: textColor, softWrap: true, t1name))),
						Expanded(flex: 20, child: Center(child: AutoSizeText.rich(group: textGroup, maxLines: 1, style: textColor, softWrap: true,
							TextSpan(children: [
								TextSpan(text: "${t1_score ?? '?'}", style: TextStyle(color: t1_color, fontWeight: FontWeight.bold)),
								const TextSpan(text: ' : '),
								TextSpan(text: "${t2_score ?? '?'}", style: TextStyle(color: t2_color, fontWeight: FontWeight.bold))
							])
						))),
						Expanded(flex: 35, child: Center(child: AutoSizeText(group: textGroup, maxLines: 1, style: textColor, softWrap: true, t2name)))
				]),
			)

		);
	}

	Widget blockGameplan(Matchday md) {
		return Column(children:
			List.generate(
				md.games.length,
				(i) => blockGame(md, md.games[i], i)
			)
		);
	}

	// Widget blockLivetableTeam(Matchday md, Group g, Team t) {
	// 	final games_amount = md.teamGamesPlayed(t.name, g.name).length;
	// 	final games_won = md.teamGamesWon(t.name, g.name).length;
	// 	final games_tied = md.teamGamesTied(t.name, g.name).length;
	// 	final games_lost = md.teamGamesLost(t.name, g.name).length;
	// 	final goals_plus = md.teamGoalsPlus(t.name, g.name);
	// 	final goals_minus = md.teamGoalsMinus(t.name, g.name);

	// 	const style = TextStyle( fontFeatures: [FontFeature.tabularFigures()]);

	// 	return Padding(
	// 		padding: EdgeInsetsGeometry.symmetric(vertical: 2, horizontal: 20),
	// 		child: Container(
	// 			decoration: BoxDecoration(
	// 				color: md.currentGame == g ? Colors.white: Colors.black,
	// 				borderRadius: BorderRadius.circular(40),
	// 			),
	// 			child: Row(children: [
	// 				Expanded(flex: 20, child:
	// 					Padding(padding: EdgeInsetsGeometry.all(4), child:
	// 						Container(
	// 							decoration: BoxDecoration(
	// 								color: colorFromHexString(t.color),
	// 								borderRadius: BorderRadius.circular(40),
	// 							),
	// 							child: Padding(padding: EdgeInsetsGeometry.only(left: 3), child: Text(style: style, t.name)),
	// 						)
	// 					)
	// 				),
	// 				Expanded(flex: 20, child: SizedBox()),
	// 				Expanded(flex: 7, child: Text(style: style, "$games_amount")),
	// 				Expanded(flex: 3, child: Text(style: style, "$games_won")),
	// 				Expanded(flex: 3, child: Text(style: style, "$games_tied")),
	// 				Expanded(flex: 15, child: Text(style: style, "$games_lost")),
	// 				Expanded(flex: 10, child: Text(style: style, "$goals_plus : $goals_minus")),
	// 				Expanded(flex: 15, child: Text(style: style, "${goals_plus-goals_minus}")),
	// 				Expanded(flex: 10, child: Text(style: style, "${md.teamPoints(t.name, g.name)}")),
	// 			])
	// 		)
	// 	);
	// }

	// Widget blockLivetable(Matchday md, Group g) {
	// 	return Column(children:
	// 		md.rankingFromGroup(g.name)!.entries.map((t) => blockLivetableTeam(md, g, md.teamFromName(t.key)!)).toList()
	// 	);
	// }
	TableRow blockLivetableTeam(Matchday md, Group g, Team t, int index) {
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
				color: index > 1 ? Colors.black : Colors.green.withValues(alpha: 0.5),
				borderRadius: BorderRadius.circular(40),
    		),
    		children: [
				Container(
					decoration: BoxDecoration(
						// gradient: LinearGradient(
						// 	colors: [colorFromHexString(t.color), Colors.black],
						// 	stops: [0, 1],
						// 	begin: Alignment.centerLeft,
						// 	end: Alignment.centerRight,
						// ),
            			borderRadius: BorderRadius.only(topLeft: Radius.circular(40), bottomLeft: Radius.circular(40)),
          			),
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


	Widget blockLivetable(Matchday md, Group g) {
		return LayoutBuilder(
			builder: (context, constraints) {
				return SingleChildScrollView(
					scrollDirection: Axis.horizontal,
					child: ConstrainedBox(
						constraints: BoxConstraints(minWidth: constraints.maxWidth),
						child: Padding(
							padding: const EdgeInsets.symmetric(horizontal: 5),
    						child: Table(
        						defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        						columnWidths: const {
									0: FlexColumnWidth(),   // team
          							1: IntrinsicColumnWidth(), // GP
          							2: IntrinsicColumnWidth(), // W
          							3: IntrinsicColumnWidth(), // D
          							4: IntrinsicColumnWidth(), // L
          							5: IntrinsicColumnWidth(), // goals
          							6: IntrinsicColumnWidth(), // diff
          							7: IntrinsicColumnWidth(), // pts
								},
        						children: [
									TableRow( children: [
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
            						.map((e) => blockLivetableTeam(md, g, md.teamFromName(e.value.key)!, e.key))
            						.toList(),
								]
      						),
    					),
					)
				);
			}
		);
	}


	@override
	Widget build(BuildContext context) {
		final secondBgColor = Theme.of(context).scaffoldBackgroundColor;

		return PopScope(
			child: Scaffold(
				backgroundColor: Colors.black,
				body: ValueListenableBuilder<Matchday>(
					valueListenable: mdl,
					builder: (context, md, _) {
						return Column(
							children: [
								Expanded(flex: 3, child: Container(color: Colors.yellow, alignment: Alignment.center, child: Text(style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,), "BETA"))),
								Expanded(flex: 10, child: blockCurGame(md)),
								Expanded(flex: 40, child: blockGameplan(md)),
								Expanded(flex: 30, child: blockLivetable(md, md.groups[0])),
							]
						);
					}
				)
			)
		);
	}
}
