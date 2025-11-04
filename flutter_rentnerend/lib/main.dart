import "package:flutter/material.dart";

import "package:flutter_rentnerend/public_window.dart" as public_window;
import "package:flutter_rentnerend/input_window.dart";
import "package:flutter_rentnerend/matchday.dart";
import "package:flutter_rentnerend/lib.dart";

void main() {
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

	Matchday? matchday_from_json(String json) {
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
											final json = await loadInputJson();
											if(json == null) {debugPrint("json does not exist"); return;}
											try { this.md = Matchday(json);
											} catch (_){ debugPrint("JSON parsing Error"); return;}
											Navigator.push(
												context,
												MaterialPageRoute<void>(
													builder: (context) => InputWindow(md: matchday_from_json(json)),
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
