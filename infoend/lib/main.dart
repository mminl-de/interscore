import "package:flutter/material.dart";

import "info_window.dart";
import "md.dart";
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
	late final ValueNotifier<Matchday> mdl;
	WSClient? ws;
	bool ready = false;

	@override
	void initState() {
		super.initState();
		_connect();
	}

	Future<void> _connect() async {
		final md = Matchday(Meta(formats: []), [], [], []);
		mdl = ValueNotifier(md);

		ws = WSClient("wss://mminl.de/ws/", mdl);
		await ws!.connect();

		while (!ws!.connected.value) {
			await Future.delayed(const Duration(milliseconds: 10));
		}

		ws!.sendSignal(MessageType.PLS_SEND_JSON);

		while (mdl.value == md) {
			await Future.delayed(const Duration(milliseconds: 10));
		}

		setState(() => ready = true);
	}

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			darkTheme: ThemeData.dark(),
			themeMode: ThemeMode.dark,
			home: Scaffold(
				body: Center(
					child: ready
						? InfoWindow(mdl: mdl, ws: ws!)
						: const CircularProgressIndicator(),
				),
			),
		);
	}
}

