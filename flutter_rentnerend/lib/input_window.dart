import 'package:flutter/material.dart';
//import 'package:auto_size_text/auto_size_text.dart';
//import 'package:flutter_rentnerend/main.dart';

class input_window extends StatelessWidget {
	const input_window({super.key});

	@override
	Widget build(BuildContext context) {
		final screenHeight = MediaQuery.of(context).size.height;
		final screenWidth = MediaQuery.of(context).size.width;

		return Scaffold(
			appBar: AppBar(title: const Text('Input Window')),
			body: SizedBox(
				height: screenHeight * 0.15,
				width: screenWidth,
				child: Row(
					children: [
						Expanded(
							child: FittedBox(
								fit: BoxFit.fitWidth,
								child: Text("NORDSHAUSEN 1")
							)
						),
						Expanded(
							child: FittedBox(
								fit: BoxFit.fitWidth,
								child: ElevatedButton(onPressed: () {}, child: Text("Switch Side"))
							)
						),
						Expanded(
							child: FittedBox(
								fit: BoxFit.fitWidth,
								child: Text("GIFHORN II")
							)
						),
					]
				)
			)
		);
	}
}
