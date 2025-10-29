import 'package:flutter/material.dart';

Widget buttonWithIcon (void Function() onPressed, IconData icon){
	const double maxHeight = 10000; // This value should be an unreachable height

	return ElevatedButton(onPressed: onPressed,
		style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4)),
		child: FittedBox(fit: BoxFit.contain, child: Icon(icon, size: maxHeight))
	);
}
