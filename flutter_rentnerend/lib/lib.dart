import 'package:flutter/material.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
