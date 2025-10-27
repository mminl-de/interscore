import 'package:flutter/material.dart';
import 'package:flutter_rentnerend/main.dart';

class input_window extends StatelessWidget {
	const input_window({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Input Window')),
			body: Center(
				child: ElevatedButton(
					onPressed: () {
						Navigator.pop(
							context,
							MaterialPageRoute<void>(
								builder: (context) => const LaunchWindow(title: "Home Page (returning)")
							)
						);
					},
					child: const Text('Go back!'),
				),
			),
		);
	}
}
