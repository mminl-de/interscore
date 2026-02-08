import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//import 'package:just_audio/just_audio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'MessageType.dart';
import 'lib.dart';
import 'md.dart';
import 'websocket.dart';
import 'input_end_window.dart';

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
	bool _showWidgets = true;
	final FocusNode _urlEditFocus = FocusNode();
	late final TextEditingController _urlEditController;

	@override
	void initState() {
		super.initState();

		mdl = ValueNotifier(widget.md);

		mdl.addListener(() {
			inputJsonWriteState(mdl.value);

			if (_controller.hasClients && _controller.selectedItem != mdl.value.meta.game.gamepart) {
				_controller.animateToItem(
					mdl.value.meta.game.gamepart,
					duration: const Duration(milliseconds: 300),
					curve: Curves.easeOutCubic,
				);
			}

			setState(() => recAct = calcRecommendedAction(mdl.value));
		});

		setState(() => recAct = calcRecommendedAction(mdl.value));

		startWS();
		startTimer();

		_controller = FixedExtentScrollController(initialItem: mdl.value.meta.game.gamepart);
		_urlEditController = TextEditingController(text: ws.client.url);
		_urlEditController.addListener(() {
			ws.client.url = _urlEditController.text;
		});
	}

	RecommendedAction calcRecommendedAction(Matchday md) {
		RecommendedAction recAct = RecommendedAction.NOTHING;
		// debugPrint("calcRecommend: paused: ${md.meta.time.paused}, time: ${md.meta.currentTime}, gamepart: ${md.meta.game.gamepart} (MAX: ${md.currentFormatUnwrapped!.gameparts.length - 1})");
		if(md.meta.time.paused && md.meta.time.remaining == 0) {
			if(md.currentFormatUnwrapped!.gameparts.length - 1 == md.meta.game.gamepart ||
			  ((md.gamepartFromIndex(md.meta.game.gamepart+1)?.decider ?? false) && md.currentGame!.winner != 0))
				recAct = RecommendedAction.GAME_NEXT;
			else
				recAct = RecommendedAction.GAMEPART_NEXT;
		} else if(md.meta.time.paused)
			recAct = RecommendedAction.TIME_START;

		debugPrint("Recommended: ${recAct.toString()}");
		return recAct;
	}

	Future<void> startWS() async {
		// TODO normally client connects to mminl.de!
		this.ws = InterscoreWS("ws://0.0.0.0:6464", "ws://localhost:8081", mdl);

		await connectWS();

		_reconnectTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
			if (!mounted) return;
			if(!ws.clientConnected) await connectWS();
		});
	}

	Future<void> connectWS() async {
		debugPrint("connectWS: connecting... now: ${ws.clientConnected}");
		ws.client.connect();
		await Future.doWhile(() async {
			await Future.delayed(Duration(milliseconds: 10));
			return !ws.client.connected.value;
		});
		debugPrint("connectWS: connected? ${ws.clientConnected}");
		if(!ws.clientConnected) return;

		ws.client.sendSignal(MessageType.DATA_JSON);
		while(mounted && !ws.client.boss.value) {
			ws.client.sendSignal(MessageType.IM_THE_BOSS);
			await Future.delayed(Duration(seconds: 10));
		}
	}

	@override
	void dispose() {
		_timer?.cancel();
		remainingTime.dispose();

		_reconnectTimer?.cancel();

		_urlEditFocus.dispose();
		_urlEditController.dispose();

		ws.close();

		mdl.dispose();
		_controller.dispose();

		super.dispose();
	}

	Future<int> dialog(final String title, final String description, final List<String> options, {final int def = 0}) async {
		return await showDialog<int>(
			context: context,
			builder: (context) => AlertDialog(
				title: Text(title),
				content: Text(description),
				actions: [
					for(int i=0; i < options.length; i++)
						TextButton(onPressed: () => Navigator.pop(context, i), child: Text(options[i])),
				],
			),
		) ?? def;
	}

	Future<void> gotoEndscreen() async {
		bool end = true;
		Matchday md = mdl.value;
		// TODO when can currentFormat fail and what to do about it
		if( md.meta.game.gamepart != md.currentFormat!.gameparts.length-1
		 || md.meta.time.paused == false
		 || md.meta.time.remaining != 0) {
			end = await dialog(
				"Spieltag beenden?",
				"Es sieht so aus, als würde das aktuelle Spiel noch laufen.\n"
				"Bist du sicher, dass du den Spieltag trotzdem beenden willst?\n"
				"Die Ergebnisse werden gespeichert und du kannst jederzeit zurückgehen, allerdings wird die Zeit gestoppt!",
				["Hier bleiben", "Trotzem beenden"]
			) == 1 ? true : false;
		}

		if(!end) return;
		else {
			mdl.value = mdl.value.setPause(true, send: ws.sendSignal);
			// Save the json
			inputJsonWrite(mdl.value);
			deleteMatchdayStateFile();

			mdl.value = mdl.value.setEnded(true, send: ws.sendSignal);
			Navigator.push(context, MaterialPageRoute<void>(builder: (context) => InputEndWindow(mdl: mdl, ws: ws)));
		}
	}

	// returns if the window should close
	Future<bool> onWindowClose() async {
		final result = await dialog(
			"Save?",
			"Do you want to save? This will overwrite the original",
			["Stay", "Don't Save", "Save"]
		);

		if (result == 2) {
			inputJsonWrite(mdl.value);
			deleteMatchdayStateFile();
		} else if (result == 1)
			deleteMatchdayStateFile();
		else if (result == 0)
			return false;

		return true;
	}

	void playSound() async {
	 	// TODO FINAL so far, on Linux, you need this for audio to work:
	 	//     gst-plugins-base
	 	//     gst-plugins-good
	 	//     gst-plugins-bad
	 	//     gst-plugins-ugly
	 	//     gst-plugins-libav
	 	// mb make it self-contained
		await player.play(AssetSource("sound_game_end_shorter.wav"));
	}

	void togglePause(Matchday md) {
		mdl.value = md.setPause(!md.meta.time.paused, send: ws.sendSignal);
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
					final isActive = md.meta.game.gamepart >= curInd && md.meta.game.gamepart <= curInd + subLen;
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
						hidden: md.meta.game.gamepart != curInd,
						inverted: md.meta.game.gamepart == curInd
					));
					curInd++;
				}
			);
		};
		return widgets;
	}

	final teamsTextGroup = AutoSizeGroup();
	Widget blockTeams(Matchday md, RecommendedAction recAct) {

		String t1name = md.currentGame!.team1.whenOrNull(
			byName: (name, _) => name,
			byQueryResolved: (name, __) => name,
		) ?? "[???]";

		String t2name = md.currentGame!.team2.whenOrNull(
			byName: (name, _) => name,
			byQueryResolved: (name, __) => name,
		) ?? "[???]";

		final String gameName = md.currentGame!.name;

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

		return Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
			child: Column( children: [
				Expanded(flex: 35, child: Stack(fit: StackFit.expand, children: [
					Align( alignment: Alignment.centerLeft, child:
						BackButton(onPressed: () => Navigator.of(context).maybePop())),
					Center(child: AutoSizeText(gameName, maxLines: 1, style: const TextStyle(fontSize: 1000)))
				])),
				Expanded(flex: 65, child: Row( children: [
					Expanded(
						flex: 5,
						// height: teamsHeight, // use max height
						child: SizedBox.expand(
							child: buttonWithIcon(context, () {
								mdl.value = md.setGameIndex(md.meta.game.index-1, send: ws.sendSignal);
							}, Icons.arrow_back_rounded)
						)
					),
					Expanded(
						flex: 40,
						//child: Center(child: AutoSizeText(md.games[md.meta.game.index].team1.name, maxLines: 1, group: teamsTextGroup, style: const TextStyle(fontSize: 1000)))
						child: Center(child: AutoSizeText(t1name, maxLines: 1, group: teamsTextGroup, style: const TextStyle(fontSize: 1000)))
					),
					Expanded(
						flex: 10,
						// height: teamsHeight, // use max height
						child: SizedBox.expand(
							child: buttonWithIcon(context, () {
								mdl.value = md.setSidesInverted(!md.meta.game.sidesInverted, send: ws.sendSignal);
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
								if(md.meta.game.index == md.games.length-1)
									gotoEndscreen();
								else
									mdl.value = md.setGameIndex(md.meta.game.index+1, send: ws.sendSignal);
							}, Icons.arrow_forward_rounded,
							highlighted: (recAct == RecommendedAction.GAME_NEXT))
						)
					),
					// TODO NEW NOW
					//Expanded(
					//	flex: 3,
					//	child: SizedBox.expand(
					//		child: buttonWithIcon(context, () {
					//			this.connectWS();
					//		}, Icons.arrow_circle_up,
					//		highlighted: (recAct == RecommendedAction.GAME_NEXT))
					//	)
					//),
				]))
			])
		);
	}

	Widget blockGoals(Matchday md, RecommendedAction recAct) {
		final int inverted = ((md.meta.game.sidesInverted ? 1 : 0) - (md.currentGamepart!.sidesInverted ? 1 : 0)).abs();
		int t1 = 1 + inverted;
		int t2 = 2 - inverted;

		final gameparts = md.currentFormatUnwrapped?.gameparts ?? [];

		return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
			child: Row( children: [
				//Expanded( child: Column(spacing: -(height * 0.05), children:[
				Expanded(flex: 40, child: Column(children:[
					Expanded(flex: 15, child: buttonWithIcon(context, () {
						mdl.value = md.goalAdd(t1, send: ws.sendSignal);
					}, Icons.arrow_upward_rounded)),
					Expanded(flex: 70, child: Center(child:
						AutoSizeText(md.currentGame!.teamGoals(t1).toString(),
						maxLines: 1, style: const TextStyle(fontSize: 1000)))),
					Expanded(flex: 15, child: buttonWithIcon(context, () {
						mdl.value = md.goalRemoveLast(t1, send: ws.sendSignal);
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
								if (index != md.meta.game.gamepart) {
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
									final isSelected = index == md.meta.game.gamepart;
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
							mdl.value = md.setCurrentGamepart(md.meta.game.gamepart - 1, send: ws.sendSignal);
							},
							Icons.arrow_upward_rounded
						)),
						Expanded(child: buttonWithIcon(context, () {
							mdl.value = md.setCurrentGamepart(md.meta.game.gamepart + 1, send: ws.sendSignal);
							},
							Icons.arrow_downward_rounded,
							highlighted: recAct == RecommendedAction.GAMEPART_NEXT
						)),
					]))],
          ),
        ),//Expanded( child: Column(spacing: -(height * 0.05), children:[
				Expanded(flex: 40, child: Column(children:[
					Expanded(flex: 15, child: buttonWithIcon(context, () {
						mdl.value = md.goalAdd(t2, send: ws.sendSignal);
					}, Icons.arrow_upward_rounded)),
					Expanded(flex: 70, child: Center(child: AutoSizeText(md.currentGame!.teamGoals(t2).toString(), maxLines: 1, style: const TextStyle(fontSize: 1000)))),
					Expanded(flex: 15, child: buttonWithIcon(context, () {
						mdl.value = md.goalRemoveLast(t2, send: ws.sendSignal);
					}, Icons.arrow_downward_rounded)),
				])),
			])
		);
	}

	final remainingTime = ValueNotifier<int>(0);
	Timer? _timer;

	void startTimer() {
		_timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
			final curTime = mdl.value.currentTime();
			if(curTime <= 0 && !mdl.value.meta.time.paused) {
				togglePause(mdl.value);
				playSound();
			}
			if(remainingTime.value != curTime)
				remainingTime.value = curTime;
		});
	}

	Widget blockTime(Matchday md, RecommendedAction recAct) {

		final defTime = md.currentGamepart?.whenOrNull(timed: (_, len, _, _, _) => len);

		return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
			child: Row(mainAxisAlignment: MainAxisAlignment.center, spacing: 8, children: [
				Expanded(flex: 5, child: SizedBox.expand(
					child: buttonWithIcon(context, () {
						mdl.value = md.timeChange(-20, send: ws.sendSignal);
					}, Icons.arrow_downward_rounded)),
				),
				Expanded(flex: 5, child: SizedBox.expand(
					child: buttonWithIcon(context, () {
						mdl.value = md.timeChange(-1, send: ws.sendSignal);
					}, Icons.arrow_downward_rounded)),
				),
				Expanded(flex: 80, child: Column( children: [
					Expanded(flex: 20, child: Row(spacing: 5, children: [
						Expanded(flex: 50, child: SizedBox.expand(child: buttonWithIcon(
							context, () => togglePause(md),
							md.meta.time.paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
							inverted: !md.meta.time.paused,
							highlighted: recAct == RecommendedAction.TIME_START
						))),
						Expanded(flex: 50, child: SizedBox.expand(child: buttonWithIcon(
							context,
							md.currentTime() == defTime
								? null
								: () {
									mdl.value = md.timeReset(send: ws.sendSignal);
								},
							Icons.autorenew,
							inverted: md.currentTime() == defTime && md.meta.time.paused // TODO approve this UI. Its lazy but look ok imo
						)))
					])),

					Expanded(flex: 80, child:
						ValueListenableBuilder<int>(
							valueListenable: remainingTime,
							builder: (_, time, __) {
								final String curTimeMin = (time ~/ 60).toString().padLeft(2, '0');
								final String curTimeSec = (time % 60).toString().padLeft(2, '0');
								final curTimeString = "${curTimeMin}:${curTimeSec}";
								return Center(child: AutoSizeText(curTimeString, maxLines: 1, style: const TextStyle(fontSize: 1000)));
							}
						)
					)
				])),
				Expanded(flex: 5, child: SizedBox.expand(
					child: buttonWithIcon(context, () {
						mdl.value = md.timeChange(1, send: ws.sendSignal);
					}, Icons.arrow_upward_rounded)),
				),
				Expanded(flex: 5, child: SizedBox.expand(
					child: buttonWithIcon(context, () {
						mdl.value = md.timeChange(20, send: ws.sendSignal);
					}, Icons.arrow_upward_rounded))
				)
			])

		);
	}

	Widget blockWidgets(Matchday md, RecommendedAction recAct) {

	return Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 15), child: LayoutBuilder(builder: (context, constraints) {
		const double borderThickness = 1.5;
		final double totalBorderWidth = borderThickness * (7 + 1);
		final double itemWidth = (constraints.maxWidth - totalBorderWidth) / 7;
		return ToggleButtons(
				constraints: BoxConstraints.expand(width: itemWidth),
				renderBorder: true,
				// borderColor: Theme.of(context).scaffoldBackgroundColor,
				// color: Theme.of(context).buttonTheme.colorScheme?.secondary,
				borderWidth: 1.5,
				borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
				isSelected: [
					md.meta.widgets.scoreboard,
					md.meta.widgets.gameplan,
					md.meta.widgets.liveplan,
					md.meta.widgets.gamestart,
					md.meta.widgets.ad,
					md.meta.obs.streamStarted ?? false,
					md.meta.obs.replayStarted ?? false,
				],
				onPressed: (index) {
					// Handle your logic based on index 0-6
					setState(() {
						if (index == 0)
							mdl.value = md.copyWith(meta: md.meta.copyWith(widgets: md.meta.widgets.copyWith(scoreboard: !md.meta.widgets.scoreboard)));
						if (index == 1)
							mdl.value = md.copyWith(meta: md.meta.copyWith(widgets: md.meta.widgets.copyWith(gameplan: !md.meta.widgets.gameplan)));
						if (index == 2)
							mdl.value = md.copyWith(meta: md.meta.copyWith(widgets: md.meta.widgets.copyWith(liveplan: !md.meta.widgets.liveplan)));
						if (index == 3)
							mdl.value = md.copyWith(meta: md.meta.copyWith(widgets: md.meta.widgets.copyWith(gamestart: !md.meta.widgets.gamestart)));
						if (index == 4)
							mdl.value = md.copyWith(meta: md.meta.copyWith(widgets: md.meta.widgets.copyWith(ad: !md.meta.widgets.ad)));
						if (index == 5)
							mdl.value = md.copyWith(meta: md.meta.copyWith(obs: md.meta.obs.copyWith(streamStarted: !(md.meta.obs.streamStarted ?? false))));
						if (index == 6)
							mdl.value = md.copyWith(meta: md.meta.copyWith(obs: md.meta.obs.copyWith(replayStarted: !(md.meta.obs.replayStarted ?? false))));
						ws.sendSignal(MessageType.DATA_META_WIDGETS);
					});
				},
				children: const [
					Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.scoreboard_rounded), Text("Scoreboard")]),
					Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.table_rows_rounded), Text("Gameplan")]),
					Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.leaderboard), Text("Liveplan")]),
					Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.card_membership_rounded), Text("Gamestart")]),
					Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.campaign_rounded), Text("Ad")]),
					Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.podcasts_rounded), Text("Stream Started")]),
					Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.replay_rounded), Text("Replay Started")]),
				],
			);
		}));
	}

	Widget blockWSStatus(Matchday md) {
		String? error;
		Color c = Colors.green;
		Function? f;
		if(!ws.client.connected.value) {
			error = "NOT CONNECTED TO BACKEND";
			c = Colors.red;
			f = () => connectWS();
		} else if (!ws.client.boss.value) {
			error = "CONNECTED BUT NOT BOSS";
			c = Colors.orange;
			f = () => ws.client.sendSignal(MessageType.IM_THE_BOSS);
		} else if (ws.server.clientsConnected.value == 0) {
			error = "NO PUBLIC WINDOW CONNECTED";
			c = Colors.orange;
		}

		final size = error == null ? 1 : 5;
		return Expanded(flex: size, child:
			Material(color: c, child: InkWell(
      			onTap: f as void Function()?, child:
				Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), child:
					Stack(fit: StackFit.expand, alignment: Alignment.center, children: [
						Center(child: Text(error ?? "",
            		      textAlign: TextAlign.center,
            		      style: const TextStyle( fontWeight: FontWeight.bold, fontSize: 18,),
            		    )),
					]),
				),
			))
		);
	}

	Map<ShortcutActivator, void Function()> shortcuts() {
		if(FocusManager.instance.primaryFocus == _urlEditFocus) return {};
		return {
			LogicalKeySet(LogicalKeyboardKey.space): () => togglePause(mdl.value),
			LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.keyR): () => mdl.value = mdl.value.timeReset(send: ws.sendSignal),
			LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.keyW): () => this.connectWS(),
			LogicalKeySet(LogicalKeyboardKey.keyH): () => mdl.value = mdl.value.setGameIndex(mdl.value.meta.game.index - 1, send: ws.sendSignal),
			LogicalKeySet(LogicalKeyboardKey.arrowLeft): () => mdl.value = mdl.value.setGameIndex(mdl.value.meta.game.index - 1, send: ws.sendSignal),
			LogicalKeySet(LogicalKeyboardKey.keyL): () {
				if(mdl.value.meta.game.index == mdl.value.games.length-1)
					gotoEndscreen();
				else
					mdl.value = mdl.value.setGameIndex(mdl.value.meta.game.index + 1, send: ws.sendSignal);
			},
			LogicalKeySet(LogicalKeyboardKey.arrowRight): () {
				if(mdl.value.meta.game.index == mdl.value.games.length-1)
					gotoEndscreen();
				else
					mdl.value = mdl.value.setGameIndex(mdl.value.meta.game.index + 1, send: ws.sendSignal);
			},
			LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.keyH): () => mdl.value = mdl.value.setGameIndex(0, send: ws.sendSignal),
			LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.arrowLeft): () => mdl.value = mdl.value.setGameIndex(0, send: ws.sendSignal),
			LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.keyL): () {
				// We need to do this, because if we go to the last game, we may cant resolve it
				Matchday next, old = mdl.value;
				while(old.meta.game.index < old.games.length-1 && (next = old.setGameIndex(old.meta.game.index + 1)) != old)
					old = next;
				mdl.value = old;
				ws.sendSignal(MessageType.DATA_META_GAME, md: old);
			},
			LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.arrowRight): () {
				// We need to do this, because if we go to the last game, we may cant resolve it
				Matchday next, old = mdl.value;
				while(old.meta.game.index < old.games.length-1 && (next = old.setGameIndex(old.meta.game.index + 1)) != old)
					old = next;
				mdl.value = old;
				ws.sendSignal(MessageType.DATA_META_GAME, md: old);
			},
			LogicalKeySet(LogicalKeyboardKey.keyJ): () => mdl.value = mdl.value.timeChange(-1, send: ws.sendSignal),
			LogicalKeySet(LogicalKeyboardKey.arrowDown): () => mdl.value = mdl.value.timeChange(-1, send: ws.sendSignal),
			LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.keyJ): () => mdl.value = mdl.value.timeChange(-20, send: ws.sendSignal),
			LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.arrowDown): () => mdl.value = mdl.value.timeChange(-20, send: ws.sendSignal),
			LogicalKeySet(LogicalKeyboardKey.keyK): () => mdl.value = mdl.value.timeChange(1, send: ws.sendSignal),
			LogicalKeySet(LogicalKeyboardKey.arrowUp): () => mdl.value = mdl.value.timeChange(1, send: ws.sendSignal),
			LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.keyK): () => mdl.value = mdl.value.timeChange(20, send: ws.sendSignal),
			LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.arrowUp): () => mdl.value = mdl.value.timeChange(20, send: ws.sendSignal),
			LogicalKeySet(LogicalKeyboardKey.digit1): () => mdl.value = mdl.value.goalRemoveLast(mdl.value.meta.game.sidesInverted ? 2 : 1, send: ws.sendSignal),
			LogicalKeySet(LogicalKeyboardKey.digit2): () => mdl.value = mdl.value.goalAdd(mdl.value.meta.game.sidesInverted ? 2 : 1, send: ws.sendSignal),
			LogicalKeySet(LogicalKeyboardKey.digit3): () => mdl.value = mdl.value.goalRemoveLast(mdl.value.meta.game.sidesInverted ? 1 : 2, send: ws.sendSignal),
			LogicalKeySet(LogicalKeyboardKey.digit4): () => mdl.value = mdl.value.goalAdd(mdl.value.meta.game.sidesInverted ? 1 : 2, send: ws.sendSignal),
			LogicalKeySet(LogicalKeyboardKey.keyS): () => mdl.value = mdl.value.setSidesInverted(!mdl.value.meta.game.sidesInverted, send: ws.sendSignal),
			LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.keyP): () => mdl.value = mdl.value.setCurrentGamepart(0, send: ws.sendSignal),
			LogicalKeySet(LogicalKeyboardKey.keyP): () => mdl.value = mdl.value.setCurrentGamepart(mdl.value.meta.game.gamepart-1, send: ws.sendSignal),
			LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.keyN): () => mdl.value = mdl.value.setCurrentGamepart((mdl.value.currentFormatUnwrapped?.gameparts.length ?? 1) - 1, send: ws.sendSignal),
			LogicalKeySet(LogicalKeyboardKey.keyN): () => mdl.value = mdl.value.setCurrentGamepart(mdl.value.meta.game.gamepart+1, send: ws.sendSignal),
			LogicalKeySet(LogicalKeyboardKey.enter): () {
				switch (recAct) {
					case RecommendedAction.TIME_START:
						togglePause(mdl.value);
						break;
					case RecommendedAction.GAMEPART_NEXT:
						mdl.value = mdl.value.setCurrentGamepart(mdl.value.meta.game.gamepart+1, send: ws.sendSignal);
						break;
					case RecommendedAction.GAME_NEXT:
						if(mdl.value.meta.game.index == mdl.value.games.length-1)
							gotoEndscreen();
						else
							mdl.value = mdl.value.setGameIndex(mdl.value.meta.game.index+1, send: ws.sendSignal);
						break;
					case RecommendedAction.NOTHING:
						break;
				}
			}
		};
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
				bindings: shortcuts(),
				child: Focus(
					autofocus: true,
					child: Scaffold(
						body: ValueListenableBuilder<Matchday>(
							valueListenable: mdl,
							builder: (context, md, _) {
								if(md.meta.game.ended) return Column();
								return Column(
									children: [
										AnimatedBuilder(
											animation: Listenable.merge([ws.connection, ws.client.boss, ws.server.clientsConnected]),
											builder: (conext, _) { return blockWSStatus(md); }),
										Expanded(flex: 18, child: blockTeams(md, recAct)),
										Expanded(flex: 25, child: blockGoals(md, recAct)),
										Expanded(flex: 35, child: blockTime(md, recAct)),
										Expanded(flex: 5, child: TextButton(
											style: TextButton.styleFrom(
												padding: EdgeInsets.zero,
												tapTargetSize: MaterialTapTargetSize.shrinkWrap,
											),
        									onPressed: () => setState(() => _showWidgets = !_showWidgets),
        									child: LayoutBuilder(builder: (context, constraints) {
      											return
													Icon(
														_showWidgets
														? Icons.keyboard_arrow_down
														: Icons.keyboard_arrow_up,
													size: constraints.biggest.shortestSide);}
        								))),
										if (_showWidgets)
        								  Expanded(flex: 10, child: blockWidgets(md, recAct)),
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
