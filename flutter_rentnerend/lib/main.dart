import "package:flutter/material.dart";
import "package:flutter_rentnerend/public_window.dart" as public_window;

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
			appBar: AppBar(
				backgroundColor: Theme.of(context).colorScheme.inversePrimary,
				title: Text(widget.title),
			),
			body: Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: <Widget>[
						const Text("You have pushed the button this many times:"),
					],
				),
			),
			floatingActionButton: FloatingActionButton(
				onPressed: public_window.create,
				tooltip: "Increment",
				child: const Icon(Icons.add),
			),
		);
	}
}
