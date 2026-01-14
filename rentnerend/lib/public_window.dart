import 'dart:async';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'md.dart';
import 'websocket.dart';


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
	Timer? ticker;

	@override
	void initState() {
		super.initState();

		mdl = widget.mdl;
		ws = widget.ws;
	}

	@override
	void dispose() {
		mdl.dispose();

		super.dispose();
	}

	Widget blockTeams(double width, double height, Matchday md) {
		const double paddingHorizontal = 16.0;
		const double paddingVertical = 0;
		final teamNameWidth = (width-paddingHorizontal*2) / 2;
		final gameNameHeight = height * 0.35;
		final teamsHeight = height - gameNameHeight;

		final teamsTextGroup = AutoSizeGroup();

		// We invert by default
		String t1name = md.currentGame.team2.whenOrNull(
			byName: (name, _) => name,
			byQueryResolved: (name, __) => name,
		) ?? "[???]";

		String t2name = md.currentGame.team1.whenOrNull(
			byName: (name, _) => name,
			byQueryResolved: (name, __) => name,
		) ?? "[???]";

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

		return SizedBox(
			height: height,
			width: width,
			child: Padding(padding: const EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: paddingVertical),
				child: Column( children: [
					SizedBox(height: gameNameHeight, child: Center(child: AutoSizeText(gameName, maxLines: 1, style: const TextStyle(fontSize: 1000)))),
					SizedBox(height: teamsHeight, child: Row( children: [
						SizedBox(
							width: teamNameWidth,
							//child: Center(child: AutoSizeText(md.games[md.meta.gameIndex].team1.name, maxLines: 1, group: teamsTextGroup, style: const TextStyle(fontSize: 1000)))
							child: Center(child: AutoSizeText(t1name, maxLines: 1, group: teamsTextGroup, style: const TextStyle(fontSize: 1000)))
						),
						SizedBox(
							width: teamNameWidth,
							child: Center(child: AutoSizeText(t2name, maxLines: 1, group: teamsTextGroup, style: const TextStyle(fontSize: 1000)))
						),
					]))
				])
			)
		);
	}

	Widget blockGoals(double width, double height, Matchday md) {
		final textHeight = height;

		final int inverted = ((md.meta.sidesInverted ? 1 : 0) - (md.currentGamepart!.sidesInverted ? 1 : 0)).abs();
		int t2 = 1 + inverted;
		int t1 = 2 - inverted;

		return SizedBox(
			width: width,
			height: height,
			child: Row( children: [
				Expanded( child: Column(children:[
					SizedBox(height: textHeight, child: Center(child:
						AutoSizeText(md.currentGame.teamGoals(t1).toString(),
						maxLines: 1, style: const TextStyle(fontSize: 1000)))),
				])),
				Expanded( child: Column(children:[
					SizedBox(height: textHeight, child: Center(child: AutoSizeText(md.currentGame.teamGoals(t2).toString(), maxLines: 1, style: const TextStyle(fontSize: 1000)))),
				])),
			])
		);
	}

	Widget blockTime(double width, double height, Matchday md) {
		final String curTimeMin = (md.meta.currentTime ~/ 60).toString().padLeft(2, '0');
		final String curTimeSec = (md.meta.currentTime % 60).toString().padLeft(2, '0');
		final curTimeString = "${curTimeMin}:${curTimeSec}";

		return SizedBox(
			width: width,
			height: height,
			child: Center(child: AutoSizeText(curTimeString, maxLines: 1, style: const TextStyle(fontSize: 1000))),
		);
	}

	@override
	Widget build(BuildContext context) {
		final screenHeight = MediaQuery.of(context).size.height;
		final screenWidth = MediaQuery.of(context).size.width;

		final blockTeamsHeight = screenHeight * 0.25;
		final blockGoalsHeight = screenHeight * 0.35;
		final blockTimeHeight = screenHeight - blockTeamsHeight - blockGoalsHeight;

		// debugPrint("Matchday: ${mdl.value}\n\n");
		// debugPrint("Matchday Generated: ${JsonEncoder.withIndent('  ').convert(mdl.value.toJson())}");
		return PopScope(
			child: Scaffold(
				body: ValueListenableBuilder<Matchday>(
					valueListenable: mdl,
					builder: (context, md, _) {
						return Column(
							children: [
								blockTeams(screenWidth, blockTeamsHeight, md),
								blockGoals(screenWidth, blockGoalsHeight, md),
								blockTime(screenWidth, blockTimeHeight, md)
							]
						);
					}
				)
			)
		);
	}
}
