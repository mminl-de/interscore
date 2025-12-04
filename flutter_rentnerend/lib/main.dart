import "dart:convert";

import "package:flutter/material.dart";

import "public_window.dart";
import "input_window.dart";
import "md.dart";
import "lib.dart";
import "websocket.dart";
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
											final json = await inputJsonLoad();
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
										onPressed: () {
											// Create a default Matchday
											final md = Matchday(Meta(formats: []), [], [], []);
											ValueNotifier<Matchday> mdl = ValueNotifier(md);
											final ws = InterscoreWS(clientUrl: "ws://0.0.0.0:6464", mdl: mdl, server: false);

											ws.sendSignal(MessageType.PLS_SEND_JSON);
											while(mdl.value == md);
											Navigator.push(
												context,
												MaterialPageRoute<void>(
													builder: (context) => PublicWindow(mdl: mdl, ws: ws)
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
										child: const Text('Connect to existing livestream'),
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
