import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_rentnerend/lib.dart';
//import 'package:flutter_rentnerend/matchday.dart';
import 'package:flutter_rentnerend/md.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';


class InputWindow extends StatefulWidget {
	const InputWindow({super.key, required this.md});

	final Matchday md;

	@override
	State<InputWindow> createState() => _InputWindowState();
}

class _InputWindowState extends State<InputWindow> {
	late ValueNotifier<Matchday> mdl;
	Timer? ticker;

	@override
	void initState() {
		super.initState();

		mdl = ValueNotifier(widget.md);

		mdl.addListener(() {
			inputJsonWriteState(mdl.value);
		});
		startTimer();
	}

	@override
	void dispose() {
		mdl.dispose();
		stopTimer();

		super.dispose();
	}

	// returns if the window should close
	Future<bool> onWindowClose() async {
		final result = await showDialog<int>(
			context: context,
			builder: (context) => AlertDialog(
				title: const Text("Save?"),
				content: const Text("Do you want to save? This will overwrite the original"),
				actions: [
				TextButton(onPressed: () => Navigator.pop(context, 0), child: const Text("Stay")),
				TextButton(onPressed: () => Navigator.pop(context, 1), child: const Text("Dont Save")),
				TextButton(onPressed: () => Navigator.pop(context, 2), child: const Text("Save")),
				],
			),
		);

		if (result == 2) {
			inputJsonWrite(mdl.value);
			deleteMatchdayStateFile();
		} else if (result == 1)
			deleteMatchdayStateFile();
		else if (result == null || result == 0)
			return false;

		return true;
	}

	void startTimer() {
		ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
			final Matchday md = mdl.value;
			if(!md.meta.paused) {
				if (md.meta.currentTime == 0)
					mdl.value = md.copyWith(meta: md.meta.copyWith(paused: true));
				else {
					mdl.value = md.copyWith(meta: md.meta.copyWith(currentTime: md.meta.currentTime-1));
					if(mdl.value.meta.currentTime == 0)
						mdl.value = mdl.value.copyWith(meta: mdl.value.meta.copyWith(paused: true));
				}

			}
		});
	}

	void stopTimer() {
		ticker?.cancel();
		ticker = null;
	}

	Widget blockTeams(double width, double height, Matchday md) {
		const double paddingHorizontal = 16.0;
		const double paddingVertical = 0;
		final switchSideWidth = width * 0.1;
		final forwardBackwardWidth = width * 0.05;
		final teamNameWidth = (width-switchSideWidth-forwardBackwardWidth*2-paddingHorizontal*2) / 2;

		final teamsTextGroup = AutoSizeGroup();

		String t1name = md.currentGame?.team1.when(
			byName: (name, _) => name,
			byQuery: (_, __) => "[???]", // TODO resolve
		) ?? "[???]";

		String t2name = md.currentGame?.team2.when(
			byName: (name, _) => name,
			byQuery: (_, __) => "[???]", // TODO resolve
		) ?? "[???]";

		if(md.meta.sidesInverted) {
			final tmp = t1name;
			t1name = t2name;
			t2name = tmp;
		}

		return SizedBox(
			height: height,
			width: width,
			child: Padding(padding: const EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: paddingVertical), child: Row(
				children: [
					SizedBox(
						width: forwardBackwardWidth,
						height: height, // use max height
						child: buttonWithIcon(context, () => mdl.value = md.prevGame(), Icons.arrow_back_rounded)
					),
					SizedBox(
						width: teamNameWidth,
						//child: Center(child: AutoSizeText(md.games[md.meta.gameIndex].team1.name, maxLines: 1, group: teamsTextGroup, style: const TextStyle(fontSize: 1000)))
						child: Center(child: AutoSizeText(t1name, maxLines: 1, group: teamsTextGroup, style: const TextStyle(fontSize: 1000)))
					),
					SizedBox(
						width: switchSideWidth,
						height: height, // use max height
						child: buttonWithIcon(context, () => mdl.value = md.switchSides(), Icons.compare_arrows_rounded)
					),
					SizedBox(
						width: teamNameWidth,
						child: Center(child: AutoSizeText(t2name, maxLines: 1, group: teamsTextGroup, style: const TextStyle(fontSize: 1000)))
					),
					SizedBox(
						width: forwardBackwardWidth,
						height: height, // use max height
						child: buttonWithIcon(context, () => mdl.value = md.nextGame(), Icons.arrow_forward_rounded)
					)
				]
			))
		);
	}

	Widget blockGoals(double width, double height, Matchday md) {
		const double paddingHorizontal = 16;
		const double paddingVertical = 8;

		final buttonWidth = (width * 0.5) * 0.2;
		final upDownHeight = height * 0.15;
		final textHeight = height - upDownHeight * 2 - paddingVertical * 2;

		int t1 = 1 + (md.meta.sidesInverted ? 1 : 0 );
		int t2 = 2 - (md.meta.sidesInverted ? 1 : 0 );

		return SizedBox(
			width: width,
			height: height,
			child: Padding(padding: const EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: paddingVertical),
				child: Row( children: [
					//Expanded( child: Column(spacing: -(height * 0.05), children:[
					Expanded( child: Column(children:[
						SizedBox(height: upDownHeight, width: buttonWidth, child: buttonWithIcon(context, () => mdl.value = md.goalAdd(team: t1), Icons.arrow_upward_rounded)),
						SizedBox(height: textHeight, child: Center(child:
							AutoSizeText(md.currentGame?.goalsTeam(t1).toString() ?? '0',
							maxLines: 1, style: const TextStyle(fontSize: 1000)))),
						SizedBox(height: upDownHeight, width: buttonWidth, child: buttonWithIcon(context, () => mdl.value = md.goalRemoveLast(team: t1), Icons.arrow_downward_rounded)),
					])),
					//Expanded( child: Column(spacing: -(height * 0.05), children:[
					Expanded( child: Column(children:[
						SizedBox(height: upDownHeight, width: buttonWidth, child: buttonWithIcon(context, () => mdl.value = md.goalAdd(team: t2), Icons.arrow_upward_rounded)),
						SizedBox(height: textHeight, child: Center(child: AutoSizeText(md.currentGame?.goalsTeam(t2).toString() ?? '0', maxLines: 1, style: const TextStyle(fontSize: 1000)))),
						SizedBox(height: upDownHeight, width: buttonWidth, child: buttonWithIcon(context, () => mdl.value = md.goalRemoveLast(team: t2), Icons.arrow_downward_rounded)),
					])),
				])
			)
		);
	}

	Widget blockTime(double width, double height, Matchday md) {
		const double paddingHorizontal = 16;
		const double paddingVertical = 8;

		final upDownWidth = width * 0.05;
		final pauseResetHeight = height * 0.2;
		final textHeight = height - pauseResetHeight - paddingVertical * 2;
		final pauseResetWidth = width/2 - (upDownWidth * 4 + (paddingHorizontal/2 * 5));

		final String curTimeMin = (md.meta.currentTime ~/ 60).toString().padLeft(2, '0');
		final String curTimeSec = (md.meta.currentTime % 60).toString().padLeft(2, '0');
		final curTimeString = "${curTimeMin}:${curTimeSec}";

		final defTime = md.currentGamePart?.whenOrNull(timed: (_, len, _, _, _) => len);

		return SizedBox(
			width: width,
			height: height,
			child: Padding(padding: const EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: paddingVertical),
				child: Row(mainAxisAlignment: MainAxisAlignment.center, spacing: paddingHorizontal/2, children: [
					SizedBox(height: height, width: upDownWidth, child: buttonWithIcon(context, () => mdl.value = md.timeChange(-20), Icons.arrow_downward_rounded)),
					SizedBox(height: height, width: upDownWidth, child: buttonWithIcon(context, () => mdl.value = md.timeChange(-1), Icons.arrow_downward_rounded)),
					Column( children: [
						Row( spacing: paddingHorizontal/2, children: [
							SizedBox(height: pauseResetHeight, width: pauseResetWidth,
								child: buttonWithIcon(
									context, () {
										// We need to reset the timer because otherwise we could disable pause
										// and then 50ms after the Timer activates and sets timer - 1 950ms before it should
										stopTimer();
										mdl.value = md.togglePause();
										startTimer();
									},
									md.meta.paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
									inverted: !md.meta.paused)),
							SizedBox(height: pauseResetHeight, width: pauseResetWidth,
								child: buttonWithIcon(
									context,
									md.meta.currentTime == defTime
										? null
										: () => mdl.value = md.timeReset(),
									Icons.autorenew,
									inverted: md.meta.currentTime == defTime))
						]),
						SizedBox(height: textHeight, width: pauseResetWidth, child: Center(child: AutoSizeText(curTimeString, maxLines: 1, style: const TextStyle(fontSize: 1000)))),
					]),
					SizedBox(height: height, width: upDownWidth, child: buttonWithIcon(context, () => mdl.value = md.timeChange(1), Icons.arrow_upward_rounded)),
					SizedBox(height: height, width: upDownWidth, child: buttonWithIcon(context, () => mdl.value = md.timeChange(20), Icons.arrow_upward_rounded))
				])
			)
		);
	}

	@override
	Widget build(BuildContext context) {
		final screenHeight = MediaQuery.of(context).size.height;
		final screenWidth = MediaQuery.of(context).size.width;

		final blockTeamsHeight = screenHeight * 0.1;
		final blockGoalsHeight = screenHeight * 0.3;
		final blockTimeHeight = screenHeight - blockTeamsHeight - blockGoalsHeight - screenHeight * 0.1;

		// debugPrint("Matchday: ${mdl.value}\n\n");
		// debugPrint("Matchday Generated: ${JsonEncoder.withIndent('  ').convert(mdl.value.toJson())}");
		return PopScope(
			canPop: false,
			onPopInvokedWithResult: (didPop, _) async {
				if(didPop) return;
				final bool shouldClose = await onWindowClose();
				if(shouldClose == true)
					Navigator.of(context).pop();
			},
			child: Scaffold(
				appBar: AppBar(title: const Text('Input Window')),
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
