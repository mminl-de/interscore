import "package:flutter/material.dart";

import "info_window.dart";
import "md.dart";
import "ws_client.dart";
import "MessageType.dart";

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

    ws = WSClient("ws://mminl.de:8081", mdl);
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


Future<void> main() async {
	runApp(const MyApp());
}
//
// class MyApp extends StatefulWidget {
// 	const MyApp({super.key});
//
// 	@override
// 	State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
// 	ThemeMode _themeMode = ThemeMode.dark;
// 	Matchday? md = null;
//
// 	@override
// 	Widget build(BuildContext context) {
//
// 		return MaterialApp(
// 			title: "Control Window – Interscore",
// 			darkTheme: ThemeData.dark(),
// 			themeMode: _themeMode,
// 			home: Builder(
// 				builder: (context) => Scaffold(
// 				body: Center(child: ElevatedButton(
// 					child: const Text('Info Screen'),
// 					onPressed: () async {
// 						// Create a default Matchday
// 						final md = Matchday(Meta(formats: []), [], [], []);
// 						ValueNotifier<Matchday> mdl = ValueNotifier(md);
// 						// TODO normally mminl.de!
// 						final ws = WSClient("ws://mminl.de:8081", mdl);
// 						await ws.connect();
// 						await Future.doWhile(() async {
// 							await Future.delayed(Duration(milliseconds: 10));
// 							return !ws.connected.value;
// 						});
//
// 						ws.sendSignal(MessageType.PLS_SEND_JSON);
//
// 						await Future.doWhile(() async {
// 							await Future.delayed(Duration(milliseconds: 10));
// 							return mdl.value == md;
// 						});
// 						Navigator.push(
// 							context,
// 							MaterialPageRoute<void>(
// 								builder: (context) => InfoWindow(mdl: mdl, ws: ws)
// 							)
// 						);
// 					},
// 				)))
// 			)
// 		);
// 	}
// }
