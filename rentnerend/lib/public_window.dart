import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/scheduler.dart';

import 'md.dart';
import 'ws_client.dart';
import 'lib.dart';


class PublicWindow extends StatefulWidget {
	const PublicWindow({super.key, required this.mdl, required this.ws});

	final ValueNotifier<Matchday> mdl;
	final WSClient ws;

	@override
	State<PublicWindow> createState() => _PublicWindowState();
}

class _PublicWindowState extends State<PublicWindow> {
	late ValueNotifier<Matchday> mdl;
	late WSClient ws;

	int _lastSecond = 0;
	// int _lastSecondTimestamp = 0;
	late final Ticker _ticker;

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

		mdl.addListener(() {
			final cur = mdl.value.currentTime();
			if (cur != _lastSecond) {
				_lastSecond = cur;
				// _lastSecondTimestamp = DateTime.now().millisecondsSinceEpoch;
			}
		});

		_ticker = Ticker((_) {
			if (!mdl.value.meta.time.paused) {
			  setState(() {});
			}
  		})..start();
	}

	@override
	void dispose() {
		ws.close();
		mdl.dispose();

		_ticker.dispose();

		super.dispose();
	}

	// TODO Test this
	double get smoothSeconds {
		final Matchday md = mdl.value;
		return md.currentTime().toDouble();

		// final now = DateTime.now().millisecondsSinceEpoch;
		// final deltaMs = now - _lastSecondTimestamp;

		// return md.currentTime() - (deltaMs / 1000.0);
	}

	double get progress {
		final Matchday md = mdl.value;
		final int? defTime = md.currentGamepart?.mapOrNull(timed: (g) => g.length);
		if(defTime == null) return 1.0;

		final remaining = (defTime - smoothSeconds)
		    .clamp(0.0, defTime.toDouble());
		return remaining / defTime;
	}

	final teamsTextGroup = AutoSizeGroup();

	Widget blockTeam(String name, int goals, Color textColor) {
		return Column(children: [
			Expanded(flex: 5, child: SizedBox(width: 5)),
			Expanded(flex: 15, child: Center(child: AutoSizeText(
				name,
				maxLines: 1,
				group: teamsTextGroup,
				style: TextStyle(fontSize: 1000, fontWeight: FontWeight.bold, height: 0.9, color: textColor, fontFamily: 'Kanit')
			))),
			Expanded(flex: 73, child: Center(child: AutoSizeText(
				goals.toString(),
				maxLines: 1,
				style: TextStyle(fontSize: 1000, height: 0.9, color: textColor, fontFamily: 'Kanit')
			))),
			Expanded(flex: 2, child: SizedBox(width: 5)),
		]);
	}

	Widget blockTeams(Matchday md) {
		Game g = md.currentGame ?? md.games[md.games.length-1];
		// We invert by default
		String t1name = g.team2.whenOrNull(
			byName: (name, _) => name,
			byQueryResolved: (name, __) => name,
		) ?? "[???]";

		String t2name = g.team1.whenOrNull(
			byName: (name, _) => name,
			byQueryResolved: (name, __) => name,
		) ?? "[???]";

		final int inverted = ((md.meta.game.sidesInverted ? 1 : 0) - (md.currentGamepart!.sidesInverted ? 1 : 0)).abs();
		final int t1_score = g.teamGoals(2 - inverted);
		final int t2_score = g.teamGoals(1 + inverted);

		final String gameName = g.name;

		if(md.meta.game.sidesInverted) {
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

		final String curTimeMin = (md.currentTime() ~/ 60).toString().padLeft(2, '0');
		final String curTimeSec = (md.currentTime() % 60).toString().padLeft(2, '0');
		final curTimeString = "${curTimeMin}:${curTimeSec}";

		final int? defTime = md.currentGamepart?.mapOrNull(timed: (g) => g.length);

		Color contrastColor(Color background) {
			// computeLuminance returns 0 (dark) → 1 (light)
			return background.computeLuminance() > 0.5
				? Colors.black
				: Colors.white;
		}

		return Column(children: [
			Expanded(flex: 140, child: Container(color: Colors.black, child:
				Center(child: AutoSizeText(
					gameName,
					maxLines: 1,
					style: const TextStyle(fontSize: 1000, height: 1.5, fontFamily: 'Kanit')
				))
			)),
			Expanded(flex: 610, child:
				Row(children: [
					Expanded(flex: 150, child: Container(color: t1_color, child: blockTeam(t1name, t1_score, contrastColor(t1_color)))),
					Expanded(flex: 2, child: Container(color: Colors.black, child: SizedBox.expand())),
					Expanded(flex: 150, child: Container(color: t2_color, child: blockTeam(t2name, t2_score, contrastColor(t2_color)))),
				])
			),
			Expanded(flex: 10, child: Container(color: Colors.black, child: SizedBox.expand())),
			Expanded(flex: 240, child: Container(color: Colors.black, child:
				LayoutBuilder(builder: (context, constraints) {
					final double progress = defTime == null ? 1.0 : (smoothSeconds / defTime).clamp(0.0, 1.0);

					return Stack(children: [
						Container(width: constraints.maxWidth * progress, color: Colors.green),
						Padding(padding: const EdgeInsets.all(10), child: Center(child: Transform.translate(
							offset: const Offset(0, -8), child: AutoSizeText(
							curTimeString,
							maxLines: 1,
							style: const TextStyle(fontSize: 1000, height: 0.85, fontFamily: 'Kanit', fontFeatures: [FontFeature.tabularFigures()])
						))))
					]);
				})
			)),
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
					builder: (context, mdOld, _) {
						final md = mdOld.setEnded(false, send: ws.sendSignal);
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
