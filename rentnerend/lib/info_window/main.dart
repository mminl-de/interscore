import 'package:flutter/material.dart';

import 'info_window.dart';

void main() => runApp(const InfoMainWindow());

class InfoMainWindow extends StatelessWidget {
	const InfoMainWindow({super.key});

	@override
	Widget build(BuildContext context) {
		return const MaterialApp(
			home: TabBarInfo(),
		);
	}
}

class TabBarInfo extends StatelessWidget {
	const TabBarInfo({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			darkTheme: ThemeData.dark(),
			themeMode: ThemeMode.dark,
			home: DefaultTabController(
					length: 2, // two tabs
					child: Scaffold(
						backgroundColor: Colors.black,
						body: const TabBarView(
							children: [
								// TODO normally mminl.de!
								InfoWindow(url: "ws://mminl.de:8081"),
								InfoWindow(url: "ws://mminl.de:8082"),
							],
						),
						bottomNavigationBar: Container(
							color: Colors.black, // Background color for the bottom bar
							child: const TabBar(
								tabs: [
									Tab(text: 'Fläche 1', icon: Icon(Icons.looks_one)),
									Tab(text: 'Fläche 2', icon: Icon(Icons.looks_two)),
								],
								// Optional styling for dark theme
								indicatorColor: Colors.white,
								labelColor: Colors.white,
								unselectedLabelColor: Colors.grey,
							),
						),
					),
				)
		);
	}
}
