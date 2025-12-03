import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

import 'md.dart';

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

Future<String?> inputJsonLoad() async {
	final dir = await getApplicationDocumentsDirectory();
	debugPrint('Documents Path: ${dir.path}');
	createDir('${dir.path}/interscore/');
	File file;
	// if we have a state file, we load it instead of the original input file
	// State files get removed when closing the program normally
	file = File('${dir.path}/interscore/matchday_state.json');
	if(!file.existsSync())
		file = File('${dir.path}/interscore/input.json');

	if (!file.existsSync()) return null;

	return file.readAsString();
}

// This function has an internal 200ms buffer, where we wait for more changes
// If we dont buffer like this, we might try to overwrite this file while still writing
// For immediate saves, e.g. when closing there is inputJsonWriteStateImmediately
Timer? _inputJsonWriteStateTimer;
Future<void> inputJsonWriteState(Matchday md) async {
	// cancel previous timer if still active
	_inputJsonWriteStateTimer?.cancel();

	// schedule a save after 200ms (debounce)
	_inputJsonWriteStateTimer = Timer(const Duration(milliseconds: 200), () async {
		try {
			final json = jsonEncode(md.toJson());
			final dir = await getApplicationCacheDirectory();
			debugPrint("Application Cache Dir: ${dir}");
			createDir('${dir.path}/interscore/');
			await File("${dir.path}/interscore/matchday_state.json").writeAsString(json);
			debugPrint("INFO: Matchday State saved successfully!");
		} catch (e) {
			print("WARN: Matchday State couldnt be saved: $e");
		}
	});
}

Future<void> inputJsonWriteStateImmediately(Matchday md) async {
	_inputJsonWriteStateTimer?.cancel(); // cancel any pending debounced save
	try {
		final dir = await getApplicationCacheDirectory();
		final file = File('${dir.path}/interscore/matchday_state.json');
		await file.create(recursive: true);
		await file.writeAsString(jsonEncode(md.toJson()));
		debugPrint("INFO: Matchday state saved immediately!");
	} catch (e) {
		debugPrint("WARN: Could not save Matchday state: $e");
	}
}

// This function has an internal 200ms buffer, where we wait for more changes
// If we dont buffer like this, we might try to overwrite this file while still writing
Timer? _inputJsonWriteTimer;
Future<void> inputJsonWrite(Matchday md) async {
	// cancel previous timer if still active
	_inputJsonWriteTimer?.cancel();

	// schedule a save after 200ms (debounce)
	_inputJsonWriteTimer = Timer(const Duration(milliseconds: 200), () async {
		try {
			final json = JsonEncoder.withIndent('  ').convert(md.toJson());
			final dir = await getApplicationDocumentsDirectory();
			debugPrint("Application Doc Dir: ${dir.path}");
			await File("${dir.path}/interscore/input.json").writeAsString(json);
			debugPrint("INFO: Matchday saved successfully!");
		} catch (e) {
			print("WARN: Matchday could not be saved: $e");
		}
	});
}

Future<void> deleteMatchdayStateFile() async {
	try {
		final dir = await getApplicationCacheDirectory();
		final file = File("${dir.path}/interscore/matchday_state.json");

		if (await file.exists()) {
			await file.delete();
			debugPrint("INFO: Matchday state file deleted successfully!");
		} else {
			debugPrint("INFO: Matchday state file does not exist. Skipping deletion");
		}
	} catch (e) {
		debugPrint("WARN: Matchday state file could not be deleted: $e");
	}
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

int u16FromBytes(List<int> bytes, int offset, {bool littleEndian = false}) {
  return littleEndian
      ? (bytes[offset] | (bytes[offset + 1] << 8))
      : ((bytes[offset] << 8) | bytes[offset + 1]);
}

List<int> u16ToBytes(int value, {bool littleEndian = false}) {
  final high = (value >> 8) & 0xFF;
  final low  = value & 0xFF;

  return littleEndian
      ? [low, high]
      : [high, low];
}

// Returns if b == wanted, else null
// Why you ask? Its needed in md.dart in @JsonKey(toJson: boolOrNull) to omit default keys when writing to json
// Why not a lambda function you ask? Guess what: fuck you, it doesnt work because comptime
bool? boolOrNullFalse(bool b) => b == false ? false : null;
bool? boolOrNullTrue(bool b) => b == true ? true : null;
int? intOrNull0(int b) => b == 0 ? 0 : null;
int? intOrNullNot0(int b) => b != 0 ? b : null;

