import "dart:convert";

import "package:flutter/material.dart";

import "public_window.dart";
import "input_window.dart";
import "info_window.dart";
import "controller_window.dart";
import "md.dart";
import "lib.dart";
import "ws_client.dart";
import "MessageType.dart";

Future<void> main() async {
	runApp(const MyApp());
}

class MyApp extends StatefulWidget {
	const MyApp({super.key});

	@override
	State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
	ThemeMode _themeMode = ThemeMode.dark;
	Matchday? md = null;

	void _toggleTheme() {
		setState(() {
			_themeMode = (_themeMode == ThemeMode.dark) ? ThemeMode.light : ThemeMode.dark;
		});
	}

	@override
	Widget build(BuildContext context) {

		return MaterialApp(
			title: "Control Window – Interscore",
			darkTheme: ThemeData.dark(),
			themeMode: _themeMode,
			home: Builder(
				builder: (context) => Scaffold(
				body: Center(
					child: Column(
						children: [
							Row (
								children: [
									ElevatedButton(
										child: const Text('Load Input Window'),
										onPressed: () async {
											final json = await inputJsonLoad(context);
											if(json == null) {debugPrint("json does not exist"); return;}
											try { this.md = Matchday.fromJson(jsonDecode(json));
											} catch (e, st){ debugPrint("JSON parsing Error: $e\nStack:\n$st"); return;}

											Navigator.push(
												context,
												MaterialPageRoute<void>(
													builder: (context) => InputWindow(md: md!),
												)
											);
										},
									), ElevatedButton(
										child: const Text('Public Window'),
										onPressed: () async {
											// Create a default Matchday
											final md = Matchday(Meta(formats: []), [], [], []);
											ValueNotifier<Matchday> mdl = ValueNotifier(md);
											final ws = WSClient("ws://localhost:6464", mdl);
											await ws.connect();
											await Future.doWhile(() async {
												await Future.delayed(Duration(milliseconds: 10));
												return !ws.connected.value;
											});

											ws.sendSignal(MessageType.PLS_SEND_JSON);

											await Future.doWhile(() async {
												await Future.delayed(Duration(milliseconds: 10));
												return mdl.value == md;
											});
											Navigator.push(
												context,
												MaterialPageRoute<void>(
													builder: (context) => PublicWindow(mdl: mdl, ws: ws)
												)
											);
										},
									), ElevatedButton(
										child: const Text('Controller'),
										onPressed: () async {
											// Create a default Matchday
											final md = Matchday(Meta(formats: []), [], [], []);
											ValueNotifier<Matchday> mdl = ValueNotifier(md);
											// TODO normally mminl.de!
											final ws = WSClient("ws://mminl.de:8081", mdl);
											await ws.connect();
											await Future.doWhile(() async {
												await Future.delayed(Duration(milliseconds: 10));
												return !ws.connected.value;
											});

											ws.sendSignal(MessageType.PLS_SEND_JSON);

											await Future.doWhile(() async {
												await Future.delayed(Duration(milliseconds: 10));
												return mdl.value == md;
											});
											Navigator.push(
												context,
												MaterialPageRoute<void>(
													builder: (context) => ControllerWindow(mdl: mdl, ws: ws)
												)
											);
										},
									), ElevatedButton(
										child: const Text('Info Screen'),
										onPressed: () async {
											// Create a default Matchday
											final md = Matchday(Meta(formats: []), [], [], []);
											ValueNotifier<Matchday> mdl = ValueNotifier(md);
											final ws = WSClient("ws://mminl.de:8081", mdl);
											await ws.connect();
											await Future.doWhile(() async {
												await Future.delayed(Duration(milliseconds: 10));
												return !ws.connected.value;
											});

											ws.sendSignal(MessageType.PLS_SEND_JSON);

											await Future.doWhile(() async {
												await Future.delayed(Duration(milliseconds: 10));
												return mdl.value == md;
											});
											Navigator.push(
												context,
												MaterialPageRoute<void>(
													builder: (context) => InfoWindow(mdl: mdl, ws: ws)
												)
											);
										},
									), ElevatedButton(
										child: const Text('Load JSON Creator'),
										onPressed: () {},
									), ElevatedButton(
										child: const Text('Load from Cycleball.eu'),
										onPressed: () {},
									), ElevatedButton(
										child: const Text('Exit'),
										onPressed: () {},
									)
								]
							),
							ElevatedButton(onPressed: _toggleTheme, child: const Text ("Night"))
						]
					)
				)
			))
		);
	}
}
