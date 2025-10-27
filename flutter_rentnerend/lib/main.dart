import "package:flutter/material.dart";
import "package:flutter_rentnerend/public_window.dart" as public_window;
import "package:flutter_rentnerend/input_window.dart";

void main() {
	runApp(const MyApp());
}

class MyApp extends StatelessWidget {
	const MyApp({super.key});

	// This widget is the root of your application.
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: "Control Window – Interscore",
			theme: ThemeData(
				colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
			),
			home: const LaunchWindow(title: "Flutter Demo Home Page"),
		);
	}
}

class LaunchWindow extends StatefulWidget {
	const LaunchWindow({super.key, required this.title});

	final String title;

	@override
	State<LaunchWindow> createState() => _LaunchWindowState();
}

class _LaunchWindowState extends State<LaunchWindow> {
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Center(
				child: Row (
					children: [
						ElevatedButton(
							child: const Text('Load Input Window'),
							onPressed: () {
								Navigator.push(
									context,
									MaterialPageRoute<void>(
										builder: (context) => const input_window(),
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
				)
			)
		);
	}
}
