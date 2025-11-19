import 'package:flutter/material.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';

Widget buttonWithIcon (BuildContext c, void Function()? onPressed, IconData icon, {bool inverted = false}){
	const double maxHeight = 10000; // This value should be an unreachable height

	final cs = Theme.of(c).colorScheme;

	final style = ButtonStyle(
		backgroundColor: WidgetStateProperty.resolveWith(
			(states) { return inverted ? cs.primary.withValues(alpha: 0.7) : null; }),
		foregroundColor: WidgetStateProperty.resolveWith(
			(states) { return inverted ? cs.onPrimary : null; }),
		padding: const WidgetStatePropertyAll(
			EdgeInsets.symmetric(horizontal: 4, vertical: 4),
		),
	);

	return ElevatedButton(onPressed: onPressed,
		style: style,
		child: FittedBox(fit: BoxFit.contain, child: Icon(icon, size: maxHeight))
	);
}

// hex format: "#123123"
Color colorFromHexString(String hex) {
	hex = hex.replaceFirst('#', '');
	if (hex.length == 6) hex = 'FF$hex'; // Add full opacity
	return Color(int.parse(hex, radix:16));
}

Future<String?> loadInputJson() async {
	final dir = await getApplicationDocumentsDirectory();
	debugPrint('Documents Path: ${dir.path}');
	createDir('${dir.path}/interscore/');
	final file = File('${dir.path}/interscore/input.json');

	if (!file.existsSync()) return null;

	return file.readAsString();
}

Future<bool> createDir(String path) async {
	final dir = Directory(path);

	if (!await dir.exists()) {
		try {
			await dir.create(recursive: true);
		} catch(_) {
			return false; // recursive creates parent folders if needed
		}
	}

	return await dir.exists();
}

T require<T>(Map<String, dynamic> json, String key) {
  debugPrint('REQUIRE: $key');
  final value = json[key];
  if (value is! T) {
    debugPrint("JSON error: '$key' missing or wrong type (expected $T)");
    throw Exception("JSON error: '$key' missing or wrong type (expected $T)");
  }
  return value;
}
