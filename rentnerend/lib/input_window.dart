import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//import 'package:just_audio/just_audio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:flutter_rentnerend/MessageType.dart';
import 'package:flutter_rentnerend/lib.dart';
import 'package:flutter_rentnerend/md.dart';
import 'package:flutter_rentnerend/websocket.dart';

enum RecommendedAction {
	TIME_START,
	GAMEPART_NEXT,
	GAME_NEXT,
	NOTHING,
}

class InputWindow extends StatefulWidget {
	const InputWindow({super.key, required this.md});

	final Matchday md;

	@override
	State<InputWindow> createState() => _InputWindowState();
}

class _InputWindowState extends State<InputWindow> {
	final player = AudioPlayer();
	late ValueNotifier<Matchday> mdl;
	late InterscoreWS ws;
	Timer? ticker;
	RecommendedAction recAct = RecommendedAction.NOTHING;
	late FixedExtentScrollController _controller;
	Timer? _reconnectTimer;

	@override
	void initState() {
		super.initState();

		mdl = ValueNotifier(widget.md);

		mdl.addListener(() {
			inputJsonWriteState(mdl.value);
			ws.server?.sendSignal(MessageType.DATA_JSON);

			if (_controller.hasClients && _controller.selectedItem != mdl.value.meta.currentGamepart) {
				_controller.animateToItem(
					mdl.value.meta.currentGamepart,
					duration: const Duration(milliseconds: 300),
					curve: Curves.easeOutCubic,
				);
			}

			setState(() => recAct = calcRecommendedAction(mdl.value));
		});

		_controller = FixedExtentScrollController(initialItem: mdl.value.meta.currentGamepart);

		setState(() => recAct = calcRecommendedAction(mdl.value));
		startTimer();

		startWS();
	}

	RecommendedAction calcRecommendedAction(Matchday md) {
		RecommendedAction recAct = RecommendedAction.NOTHING;
		debugPrint("calcRecommend: paused: ${md.meta.paused}, time: ${md.meta.currentTime}, gamepart: ${md.meta.currentGamepart} (MAX: ${md.currentFormatUnwrapped!.gameparts.length - 1})");
		if(md.meta.paused && md.meta.currentTime == 0) {
			if(md.currentFormatUnwrapped!.gameparts.length - 1 == md.meta.currentGamepart ||
			  ((md.gamepartFromIndex(md.meta.currentGamepart+1)?.decider ?? false) && md.currentGame.winner != 0))
				recAct = RecommendedAction.GAME_NEXT;
			else
				recAct = RecommendedAction.GAMEPART_NEXT;
		} else if(md.meta.paused)
			recAct = RecommendedAction.TIME_START;

		debugPrint("Recommended: ${recAct.toString()}");
		return recAct;
	}

	Future<void> startWS() async {
		this.ws = InterscoreWS(mdl);
		ws.initServer("ws://0.0.0.0:6464");

		await connectWS();

		_reconnectTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
			if (!mounted) return;

			if(ws.client == null || !ws.clientConnected) {
				await connectWS();
			}
		});
	}

	Future<void> connectWS() async {
		// TODO NOW
		await ws.initClient("ws://localhost:8081");
		if(!ws.clientConnected) return;
		//await ws.initClient("ws://localhost:8081");
		ws.client!.sendSignal(MessageType.DATA_JSON);
		while(mounted && !ws.client!.boss) {
			ws.client!.sendSignal(MessageType.IM_THE_BOSS);
			await Future.delayed(Duration(seconds: 10));
		}
	}

	@override
	void dispose() {
		stopTimer();
		_reconnectTimer?.cancel();

		ws.close();

		mdl.dispose();
		_controller.dispose();

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
				TextButton(onPressed: () => Navigator.pop(context, 1), child: const Text("Don't Save")),
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
		debugPrint("STARTING TIMER BROOOOOOOOOO");
		ticker ??= Timer.periodic(const Duration(seconds: 1), (_) async {
			final Matchday md = mdl.value;
			if (!md.meta.paused) {
				if (md.meta.currentTime != 0) {
					mdl.value = md.copyWith(meta: md.meta.copyWith(currentTime: md.meta.currentTime-1));
					ws.sendSignal(MessageType.DATA_TIME);
				}
				if (mdl.value.meta.currentTime == 0) {
					debugPrint("NOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO BROOOOOOOOOOOOOOOOOOO");
					mdl.value = mdl.value.copyWith(meta: mdl.value.meta.copyWith(paused: true));
					ws.sendSignal(MessageType.DATA_PAUSE_ON);

					// TODO FINAL so far, on Linux, you need this for audio to work:
					//     gst-plugins-base
					//     gst-plugins-good
					//     gst-plugins-bad
					//     gst-plugins-ugly
					//     gst-plugins-libav
					// mb make it self-contained
					await player.play(AssetSource("sound_game_end_shorter.wav"));
					//player.setUrl("file://../assets/sound_game_end_shorter.wav");
					//await player.play();
				}

				//if (md.meta.currentTime == 0) {
				//	debugPrint("NOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO BROOOOOOOOOOOOOOOOOOO");
				//	mdl.value = md.copyWith(meta: md.meta.copyWith(paused: true));
				//	ws.sendSignal(MessageType.DATA_PAUSE_ON);

				//	//player.setUrl("asset://../assets/sound_game_end_shorter.wav");
				//	await player.play(UrlSource("https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3"));
				//} else {
				//	mdl.value = md.copyWith(meta: md.meta.copyWith(currentTime: md.meta.currentTime-1));
				//	ws.sendSignal(MessageType.DATA_TIME);

				//	if(mdl.value.meta.currentTime == 0) {
				//		mdl.value = mdl.value.copyWith(meta: mdl.value.meta.copyWith(paused: true));
				//		ws.sendSignal(MessageType.DATA_PAUSE_ON);
				//	}
				//}
			}
		});
	}

	void stopTimer() {
		ticker?.cancel();
		ticker = null;
	}

	void togglePause(Matchday md) {
		// We need to reset the timer because otherwise we could disable pause
		// and then 50ms after the Timer activates and sets timer - 1 950ms before it should
		stopTimer();
		mdl.value = md.setPause(!md.meta.paused);
		ws.sendSignal(MessageType.DATA_PAUSE_ON);
		startTimer();
	}

	// startGaepartIndex is the index of the first gamepart in the format. This is needed for nested formats
	// because we need to set the currentGamepart in md to the correct global number, not a local Format one.
	List<Widget> formatMenu(Matchday md, Format format, int startGamepartIndex) {
		int curInd = startGamepartIndex;
		final widgets = <Widget>[];
		for(final gp in format.gameparts) {
			late IconData icon;
			late String name;
			gp.map(
				timed: (p) { icon = Icons.timer; name = p.name;},
				format: (p) { icon = Icons.list; name = p.format;},
				penalty: (p) { icon = Icons.sports; name = p.name;},
			);
			gp.maybeWhen(
				format: (_, _, _, _) {
					final Format subFormat = md.formatFromName(name)!;
					final int subLen = md.formatUnwrap(subFormat)!.gameparts.length;
					final isActive = md.meta.currentGamepart >= curInd && md.meta.currentGamepart <= curInd + subLen;
					widgets.add(
						ExpandableButton(
							child: Row(mainAxisAlignment: MainAxisAlignment.start, spacing: 6, children: [
								Icon(icon),
								Expanded(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis))
							]),
							children: formatMenu(md, subFormat, curInd),
							inverted: isActive,
							hidden: !isActive,
						)
					);
					curInd += subLen;
				},
				orElse: () {
					final int index = curInd;
					widgets.add(buttonWithChild(
						context,
						() => mdl.value = md.setCurrentGamepart(index),
						Row(mainAxisAlignment: MainAxisAlignment.start, spacing: 6, children: [
							Icon(icon),
							Expanded(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis))
						]),
						hidden: md.meta.currentGamepart != curInd,
						inverted: md.meta.currentGamepart == curInd
					));
					curInd++;
				}
			);
		};
		return widgets;
	}

	Widget blockTeams(Matchday md, RecommendedAction recAct) {
		final teamsTextGroup = AutoSizeGroup();

		String t1name = md.currentGame.team1.whenOrNull(
			byName: (name, _) => name,
			byQueryResolved: (name, __) => name,
		) ?? "[???]";

		String t2name = md.currentGame.team2.whenOrNull(
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

		return Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
			child: Column( children: [
				Expanded(flex: 35, child: Center(child: AutoSizeText(gameName, maxLines: 1, style: const TextStyle(fontSize: 1000)))),
				Expanded(flex: 65, child: Row( children: [
					Expanded(
						flex: 5,
						// height: teamsHeight, // use max height
						child: SizedBox.expand(
							child: buttonWithIcon(context, () {
								mdl.value = md.setGameIndex(md.meta.gameIndex-1);
								ws.sendSignal(MessageType.DATA_GAMEINDEX);
							}, Icons.arrow_back_rounded)
						)
					),
					Expanded(
						flex: 40,
						//child: Center(child: AutoSizeText(md.games[md.meta.gameIndex].team1.name, maxLines: 1, group: teamsTextGroup, style: const TextStyle(fontSize: 1000)))
						child: Center(child: AutoSizeText(t1name, maxLines: 1, group: teamsTextGroup, style: const TextStyle(fontSize: 1000)))
					),
					Expanded(
						flex: 10,
						// height: teamsHeight, // use max height
						child: SizedBox.expand(
							child: buttonWithIcon(context, () {
								mdl.value = md.setSidesInverted(!md.meta.sidesInverted);
								ws.sendSignal(MessageType.DATA_SIDES_SWITCHED);
							}, Icons.compare_arrows_rounded)
						)
					),
					Expanded(
						flex: 40,
						child: Center(child: AutoSizeText(t2name, maxLines: 1, group: teamsTextGroup, style: const TextStyle(fontSize: 1000)))
					),
					Expanded(
						flex: 5,
						// height: teamsHeight, // use max height
						child: SizedBox.expand(
							child: buttonWithIcon(context, () {
								mdl.value = md.setGameIndex(md.meta.gameIndex+1);
								ws.sendSignal(MessageType.DATA_GAMEINDEX);
							}, Icons.arrow_forward_rounded,
							highlighted: (recAct == RecommendedAction.GAME_NEXT))
						)
					)
				]))
			])
		);
	}

	Widget blockGoals(Matchday md, RecommendedAction recAct) {
		final int inverted = ((md.meta.sidesInverted ? 1 : 0) - (md.currentGamepart!.sidesInverted ? 1 : 0)).abs();
		int t1 = 1 + inverted;
		int t2 = 2 - inverted;

		final gameparts = md.currentFormatUnwrapped?.gameparts ?? [];

		return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
			child: Row( children: [
				//Expanded( child: Column(spacing: -(height * 0.05), children:[
				Expanded(flex: 40, child: Column(children:[
					Expanded(flex: 15, child: buttonWithIcon(context, () {
						mdl.value = md.goalAdd(t1);
						ws.sendSignal(MessageType.DATA_JSON); // TODO implement game action sending
					}, Icons.arrow_upward_rounded)),
					Expanded(flex: 70, child: Center(child:
						AutoSizeText(md.currentGame.teamGoals(t1).toString(),
						maxLines: 1, style: const TextStyle(fontSize: 1000)))),
					Expanded(flex: 15, child: buttonWithIcon(context, () {
						mdl.value = md.goalRemoveLast(t1);
						ws.sendSignal(MessageType.DATA_JSON); // TODO implement game action sending
					}, Icons.arrow_downward_rounded)),
				])),
				Expanded(flex: 20, child: Column( children: [
					Expanded(flex: 80, child: LayoutBuilder(builder: (context, constraints) {
						final double height = constraints.maxHeight;
						final double itemHeight = height / 3 > 0 ? height / 3 : 50.0;

						return ListWheelScrollView.useDelegate(
							controller: _controller,
							itemExtent: itemHeight,
							physics: const FixedExtentScrollPhysics(),
							// Visual tweaks
							perspective: 0.005,
							diameterRatio: 2.0,
							useMagnifier: true,
							magnification: 1.2,
							overAndUnderCenterOpacity: 0.5, // Fades the non-selected items
							onSelectedItemChanged: (index) {
								// Only update state if it's a user scroll (prevent loops)
								if (index != md.meta.currentGamepart) {
									mdl.value = md.setCurrentGamepart(index);
								}
							},
							childDelegate: ListWheelChildBuilderDelegate(
								childCount: gameparts.length,
								builder: (context, index) {
									final gp = gameparts[index];
									String label = "";
									gp.map(
										timed: (p) => label = p.name,
										format: (p) => label = p.format,
										penalty: (p) => label = p.name,
									);
									final isSelected = index == md.meta.currentGamepart;
									return Center(
									 	child: Text(
									 		label,
									 		maxLines: 1,
									 		overflow: TextOverflow.ellipsis,
									 		style: TextStyle(
									 			fontSize: isSelected ? 18 : 14,
									 			color: isSelected ? Colors.white : Colors.grey,
									 			fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
									 		),
									 	),
									);
								},
							),
						);
					})),
					Expanded(flex: 20, child: Row(children: [
						Expanded(child: buttonWithIcon(context, () {
							mdl.value = md.setCurrentGamepart(md.meta.currentGamepart - 1);
							ws.sendSignal(MessageType.DATA_JSON);
							},
							Icons.arrow_upward_rounded
						)),
						Expanded(child: buttonWithIcon(context, () {
							mdl.value = md.setCurrentGamepart(md.meta.currentGamepart + 1);
							ws.sendSignal(MessageType.DATA_JSON);
							},
							Icons.arrow_downward_rounded,
							highlighted: recAct == RecommendedAction.GAMEPART_NEXT
						)),
					]))],
          ),
        ),//Expanded( child: Column(spacing: -(height * 0.05), children:[
				Expanded(flex: 40, child: Column(children:[
					Expanded(flex: 15, child: buttonWithIcon(context, () {
						mdl.value = md.goalAdd(t2);
						ws.sendSignal(MessageType.DATA_JSON);
					}, Icons.arrow_upward_rounded)),
					Expanded(flex: 70, child: Center(child: AutoSizeText(md.currentGame.teamGoals(t2).toString(), maxLines: 1, style: const TextStyle(fontSize: 1000)))),
					Expanded(flex: 15, child: buttonWithIcon(context, () {
						mdl.value = md.goalRemoveLast(t2);
						ws.sendSignal(MessageType.DATA_JSON);
					}, Icons.arrow_downward_rounded)),
				])),
			])
		);
	}

	Widget blockTime(Matchday md, RecommendedAction recAct) {
		final String curTimeMin = (md.meta.currentTime ~/ 60).toString().padLeft(2, '0');
		final String curTimeSec = (md.meta.currentTime % 60).toString().padLeft(2, '0');
		final curTimeString = "${curTimeMin}:${curTimeSec}";

		final defTime = md.currentGamepart?.whenOrNull(timed: (_, len, _, _, _) => len);

		return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
			child: Row(mainAxisAlignment: MainAxisAlignment.center, spacing: 8, children: [
				Expanded(flex: 5, child: SizedBox.expand(
					child: buttonWithIcon(context, () {
						mdl.value = md.timeChange(-20);
						ws.sendSignal(MessageType.DATA_TIME);
					}, Icons.arrow_downward_rounded)),
				),
				Expanded(flex: 5, child: SizedBox.expand(
					child: buttonWithIcon(context, () {
						mdl.value = md.timeChange(-1);
						ws.sendSignal(MessageType.DATA_TIME);
					}, Icons.arrow_downward_rounded)),
				),
				Expanded(flex: 80, child: Column( children: [
					Expanded(flex: 20, child: Row(spacing: 5, children: [
						Expanded(flex: 50, child: SizedBox.expand(child: buttonWithIcon(
							context, () => togglePause(md),
							md.meta.paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
							inverted: !md.meta.paused,
							highlighted: recAct == RecommendedAction.TIME_START
						))),
						Expanded(flex: 50, child: SizedBox.expand(child: buttonWithIcon(
							context,
							md.meta.currentTime == defTime
								? null
								: () {
									mdl.value = md.timeReset();
									ws.sendSignal(MessageType.DATA_TIME);
								},
							Icons.autorenew,
							inverted: md.meta.currentTime == defTime
						)))
					])),
					Expanded(flex: 80, child: Center(child: AutoSizeText(curTimeString, maxLines: 1, style: const TextStyle(fontSize: 1000)))),
				])),
				Expanded(flex: 5, child: SizedBox.expand(
					child: buttonWithIcon(context, () {
						mdl.value = md.timeChange(1);
						ws.sendSignal(MessageType.DATA_TIME);
					}, Icons.arrow_upward_rounded)),
				),
				Expanded(flex: 5, child: SizedBox.expand(
					child: buttonWithIcon(context, () {
						mdl.value = md.timeChange(20);
						ws.sendSignal(MessageType.DATA_TIME);
					}, Icons.arrow_upward_rounded))
				)
			])

		);
	}

	Widget blockWidgets(Matchday md, RecommendedAction recAct) {
		return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
			Expanded(child: buttonWithIcon(context, () {
				mdl.value = md.copyWith(meta: md.meta.copyWith(widgetScoreboard: !md.meta.widgetScoreboard));
				ws.sendSignal(MessageType.DATA_WIDGET_SCOREBOARD_ON);
			}, Icons.arrow_downward_rounded, inverted: md.meta.widgetScoreboard)),
			Expanded(child: buttonWithIcon(context, () {
				mdl.value = md.copyWith(meta: md.meta.copyWith(widgetGameplan: !md.meta.widgetGameplan));
				ws.sendSignal(MessageType.DATA_WIDGET_GAMEPLAN_ON);
			}, Icons.arrow_downward_rounded, inverted: md.meta.widgetGameplan)),
			Expanded(child: buttonWithIcon(context, () {
				mdl.value = md.copyWith(meta: md.meta.copyWith(widgetLiveplan: !md.meta.widgetLiveplan));
				ws.sendSignal(MessageType.DATA_WIDGET_LIVETABLE_ON);
			}, Icons.arrow_upward_rounded, inverted: md.meta.widgetLiveplan)),
			Expanded(child: buttonWithIcon(context, () {
				mdl.value = md.copyWith(meta: md.meta.copyWith(widgetGamestart: !md.meta.widgetGamestart));
				ws.sendSignal(MessageType.DATA_WIDGET_GAMESTART_ON);
			}, Icons.arrow_upward_rounded, inverted: md.meta.widgetGamestart)),
			Expanded(child: buttonWithIcon(context, () {
				mdl.value = md.copyWith(meta: md.meta.copyWith(widgetAd: !md.meta.widgetAd));
				ws.sendSignal(MessageType.DATA_WIDGET_AD_ON);
			}, Icons.arrow_upward_rounded, inverted: md.meta.widgetAd)),
			Expanded(child: buttonWithIcon(context, () {
				mdl.value = md.copyWith(meta: md.meta.copyWith(streamStarted: !md.meta.streamStarted));
				ws.sendSignal(MessageType.DATA_OBS_STREAM_ON);
			}, Icons.arrow_upward_rounded, inverted: md.meta.streamStarted)),
			Expanded(child: buttonWithIcon(context, () {
				mdl.value = md.copyWith(meta: md.meta.copyWith(replayStarted: !md.meta.replayStarted));
				ws.sendSignal(MessageType.DATA_OBS_REPLAY_ON);
			}, Icons.arrow_upward_rounded, inverted: md.meta.replayStarted))
			])
		;
	}

	@override
	Widget build(BuildContext context) {
		// debugPrint("Matchday: ${mdl.value}\n\n");
		// debugPrint("Matchday Generated: ${JsonEncoder.withIndent('  ').convert(mdl.value.toJson())}");
		return PopScope(
			canPop: false,
			onPopInvokedWithResult: (didPop, _) async {
				if(didPop) return;
				final bool shouldClose = await onWindowClose();
				if(shouldClose == true) Navigator.of(context).pop();
			},
			child: CallbackShortcuts(
				bindings: {
					LogicalKeySet(LogicalKeyboardKey.space): () => togglePause(mdl.value),
					LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.keyR): () => mdl.value = mdl.value.timeReset(),
					LogicalKeySet(LogicalKeyboardKey.keyH): () => mdl.value = mdl.value.setGameIndex(mdl.value.meta.gameIndex - 1),
					LogicalKeySet(LogicalKeyboardKey.arrowLeft): () => mdl.value = mdl.value.setGameIndex(mdl.value.meta.gameIndex - 1),
					LogicalKeySet(LogicalKeyboardKey.keyL): () => mdl.value = mdl.value.setGameIndex(mdl.value.meta.gameIndex + 1),
					LogicalKeySet(LogicalKeyboardKey.arrowRight): () => mdl.value = mdl.value.setGameIndex(mdl.value.meta.gameIndex + 1),
					LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.keyH): () => mdl.value = mdl.value.setGameIndex(0),
					LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.arrowLeft): () => mdl.value = mdl.value.setGameIndex(0),
					LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.keyL): () {
						Matchday next, old = mdl.value;
						while((next = old.setGameIndex(old.meta.gameIndex + 1)) != old)
							old = next;
						mdl.value = old;
					},
					LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.arrowRight): () {
						Matchday next, old = mdl.value;
						while((next = old.setGameIndex(old.meta.gameIndex + 1)) != old)
							old = next;
						mdl.value = old;
					},
					LogicalKeySet(LogicalKeyboardKey.keyJ): () => mdl.value = mdl.value.timeChange(-1),
					LogicalKeySet(LogicalKeyboardKey.arrowDown): () => mdl.value = mdl.value.timeChange(-1),
					LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.keyJ): () => mdl.value = mdl.value.timeChange(-20),
					LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.arrowDown): () => mdl.value = mdl.value.timeChange(-20),
					LogicalKeySet(LogicalKeyboardKey.keyK): () => mdl.value = mdl.value.timeChange(1),
					LogicalKeySet(LogicalKeyboardKey.arrowUp): () => mdl.value = mdl.value.timeChange(1),
					LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.keyK): () => mdl.value = mdl.value.timeChange(20),
					LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.arrowUp): () => mdl.value = mdl.value.timeChange(20),
					LogicalKeySet(LogicalKeyboardKey.digit1): () => mdl.value = mdl.value.goalRemoveLast(1),
					LogicalKeySet(LogicalKeyboardKey.digit2): () => mdl.value = mdl.value.goalAdd(1),
					LogicalKeySet(LogicalKeyboardKey.digit3): () => mdl.value = mdl.value.goalRemoveLast(2),
					LogicalKeySet(LogicalKeyboardKey.digit4): () => mdl.value = mdl.value.goalAdd(2),
					LogicalKeySet(LogicalKeyboardKey.keyS): () => mdl.value = mdl.value.setSidesInverted(!mdl.value.meta.sidesInverted),
					LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.keyP): () => mdl.value = mdl.value.setCurrentGamepart(0),
					LogicalKeySet(LogicalKeyboardKey.keyP): () => mdl.value = mdl.value.setCurrentGamepart(mdl.value.meta.currentGamepart-1),
					LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.keyN): () => mdl.value = mdl.value.setCurrentGamepart((mdl.value.currentFormatUnwrapped?.gameparts.length ?? 1) - 1),
					LogicalKeySet(LogicalKeyboardKey.keyN): () => mdl.value = mdl.value.setCurrentGamepart(mdl.value.meta.currentGamepart+1),
					LogicalKeySet(LogicalKeyboardKey.enter): () {
						switch (recAct) {
							case RecommendedAction.TIME_START:
								togglePause(mdl.value);
								break;
							case RecommendedAction.GAMEPART_NEXT:
								mdl.value = mdl.value.setCurrentGamepart(mdl.value.meta.currentGamepart+1);
								break;
							case RecommendedAction.GAME_NEXT:
								mdl.value = mdl.value.setGameIndex(mdl.value.meta.gameIndex+1);
								break;
							case RecommendedAction.NOTHING:
								break;
						}
					}

				},
				child: Focus(
					autofocus: true,
					child: Scaffold(
						appBar: AppBar(title: const Text('Input Window')),
						body: ValueListenableBuilder<Matchday>(
							valueListenable: mdl,
							builder: (context, md, _) {
								return Column(
									children: [
										Expanded(flex: 18, child: blockTeams(md, recAct)),
										Expanded(flex: 25, child: blockGoals(md, recAct)),
										Expanded(flex: 35, child: blockTime(md, recAct)),
										Expanded(flex: 22, child: blockWidgets(md, recAct))
										//Expanded(flex: 25, child: blockTeams(md, recAct)),
										//Expanded(flex: 33, child: blockGoals(md, recAct)),
										//Expanded(flex: 42, child: blockTime(md, recAct)),
									]
								);
							}
						)
					)
				)
			)
		);
	}
}
