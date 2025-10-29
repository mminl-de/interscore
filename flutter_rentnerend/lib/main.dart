import "package:flutter/material.dart";
import "package:flutter_rentnerend/public_window.dart" as public_window;
import "package:flutter_rentnerend/input_window.dart";

void main() {
	runApp(const MyApp());
}

class MyApp extends StatefulWidget {
	const MyApp({super.key});

	// This widget is the root of your application.
	@override
	State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
	ThemeMode _themeMode = ThemeMode.dark;

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
			//theme: ThemeData(
			//	colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
			//),
			home: LaunchWindow(title: "Flutter Demo Home Page", onToggleTheme: _toggleTheme),
		);
	}
}

class LaunchWindow extends StatefulWidget {
	const LaunchWindow({super.key, required this.title, required this.onToggleTheme});

	final String title;
	final VoidCallback onToggleTheme;

	@override
	State<LaunchWindow> createState() => _LaunchWindowState();
}

class _LaunchWindowState extends State<LaunchWindow> {
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Center(
				child: Column(
					children: [
						Row (
							children: [
								ElevatedButton(
									child: const Text('Load Input Window'),
									onPressed: () {
										Navigator.push(
											context,
											MaterialPageRoute<void>(
												builder: (context) => const InputWindow(),
											)
										);
									},
								), ElevatedButton(
									child: const Text('Load JSON Creator'),
									onPressed: () {

									},
								), ElevatedButton(
									child: const Text('Load from Cycleball.eu'),
									onPressed: () {

									},
								), ElevatedButton(
									child: const Text('Connect to existing livestream'),
									onPressed: () {

									},
								), ElevatedButton(
									child: const Text('Exit'),
									onPressed: () {

									},
								)
							]
						),
						ElevatedButton(onPressed: widget.onToggleTheme, child: const Text ("Night"))
					]
				)
			)
		);
	}
}
