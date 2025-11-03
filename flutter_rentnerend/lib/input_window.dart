import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_rentnerend/lib.dart';
import 'package:flutter_rentnerend/matchday.dart';

class InputWindow extends StatelessWidget {
	const InputWindow({super.key, Matchday? md});

	Widget blockTeams(double width, double height) {
		const double paddingHorizontal = 16.0;
		const double paddingVertical = 0;
		final switchSideWidth = width * 0.1;
		final forwardBackwardWidth = width * 0.05;
		final teamNameWidth = (width-switchSideWidth-forwardBackwardWidth*2-paddingHorizontal*2) / 2;

		final teamsTextGroup = AutoSizeGroup();

		return SizedBox(
			height: height,
			width: width,
			child: Padding(padding: const EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: paddingVertical), child: Row(
				children: [
					SizedBox(
						width: forwardBackwardWidth,
						height: height, // use max height
						child: buttonWithIcon(() {}, Icons.arrow_back_rounded)
					),
					SizedBox(
						width: teamNameWidth,
						child: Center(child: AutoSizeText("NORDSHAUSEN I", maxLines: 1, group: teamsTextGroup, style: const TextStyle(fontSize: 1000)))
					),
					SizedBox(
						width: switchSideWidth,
						height: height, // use max height
						child: buttonWithIcon(() {}, Icons.compare_arrows_rounded)
					),
					SizedBox(
						width: teamNameWidth,
						child: Center(child: AutoSizeText("GIFHORN II", maxLines: 1, group: teamsTextGroup, style: const TextStyle(fontSize: 1000)))
					),
					SizedBox(
						width: forwardBackwardWidth,
						height: height, // use max height
						child: buttonWithIcon(() {}, Icons.arrow_forward_rounded)
					)
				]
			))
		);
	}

	Widget blockGoals(double width, double height) {
		const double paddingHorizontal = 16;
		const double paddingVertical = 8;

		final buttonWidth = (width * 0.5) * 0.2;
		final upDownHeight = height * 0.15;
		final textHeight = height - upDownHeight * 2 - paddingVertical * 2;

		return SizedBox(
			width: width,
			height: height,
			child: Padding(padding: const EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: paddingVertical),
				child: Row( children: [
					Expanded( child: Column(spacing: -(height * 0.05), children:[
						SizedBox(height: upDownHeight, width: buttonWidth, child: buttonWithIcon(() {}, Icons.arrow_upward_rounded)),
						SizedBox(height: textHeight, child: Center(child: AutoSizeText("10", maxLines: 1, style: const TextStyle(fontSize: 1000)))),
						SizedBox(height: upDownHeight, width: buttonWidth, child: buttonWithIcon(() {}, Icons.arrow_downward_rounded)),
					])),
					Expanded( child: Column(spacing: -(height * 0.05), children:[
						SizedBox(height: upDownHeight, width: buttonWidth, child: buttonWithIcon(() {}, Icons.arrow_upward_rounded)),
						SizedBox(height: textHeight, child: Center(child: AutoSizeText("8", maxLines: 1, style: const TextStyle(fontSize: 1000)))),
						SizedBox(height: upDownHeight, width: buttonWidth, child: buttonWithIcon(() {}, Icons.arrow_downward_rounded)),
					])),
				])
			)
		);
	}

	Widget blockTime(double width, double height) {
		const double paddingHorizontal = 16;
		const double paddingVertical = 8;

		final upDownWidth = width * 0.05;
		final pauseResetHeight = height * 0.2;
		final textHeight = height - pauseResetHeight - paddingVertical * 2;
		final pauseResetWidth = width/2 - (upDownWidth * 4 + (paddingHorizontal/2 * 5));

		return SizedBox(
			width: width,
			height: height,
			child: Padding(padding: const EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: paddingVertical),
				child: Row(mainAxisAlignment: MainAxisAlignment.center, spacing: paddingHorizontal/2, children: [
					SizedBox(height: height, width: upDownWidth, child: buttonWithIcon(() {}, Icons.arrow_downward_rounded)),
					SizedBox(height: height, width: upDownWidth, child: buttonWithIcon(() {}, Icons.arrow_downward_rounded)),
					Column( children: [
						Row( spacing: paddingHorizontal/2, children: [
							SizedBox(height: pauseResetHeight, width: pauseResetWidth, child: buttonWithIcon(() {}, Icons.pause_rounded)),
							SizedBox(height: pauseResetHeight, width: pauseResetWidth, child: buttonWithIcon(() {}, Icons.autorenew))
						]),
						SizedBox(height: textHeight, width: pauseResetWidth, child: Center(child: AutoSizeText("7:00", maxLines: 1, style: const TextStyle(fontSize: 1000)))),
					]),
					SizedBox(height: height, width: upDownWidth, child: buttonWithIcon(() {}, Icons.arrow_downward_rounded)),
					SizedBox(height: height, width: upDownWidth, child: buttonWithIcon(() {}, Icons.arrow_downward_rounded))
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

		return Scaffold(
			appBar: AppBar(title: const Text('Input Window')),
			body: Column(
				children: [
					blockTeams(screenWidth, blockTeamsHeight),
					blockGoals(screenWidth, blockGoalsHeight),
					blockTime(screenWidth, blockTimeHeight)
				]
			)
		);
	}
}
