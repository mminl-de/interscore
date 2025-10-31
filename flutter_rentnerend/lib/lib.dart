import 'package:flutter/material.dart';

Widget buttonWithIcon (void Function() onPressed, IconData icon){
	const double maxHeight = 10000; // This value should be an unreachable height

	return ElevatedButton(onPressed: onPressed,
		style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4)),
		child: FittedBox(fit: BoxFit.contain, child: Icon(icon, size: maxHeight))
	);
}

// hex format: "#123123"
Color colorFromHexString(String hex) {
	hex = hex.replaceFirst('#', '');
	if (hex.length == 6) hex = 'FF$hex'; // Add full opacity
	return Color(int.parse(hex, radix:16));
}
