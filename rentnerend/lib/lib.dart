import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

import 'MessageType.dart';
import 'md.dart';

class ExpandableButton extends StatefulWidget {
	final Widget child;
	final List<Widget> children;
	final bool inverted;
	final bool hidden;

	const ExpandableButton({
		required this.child,
		required this.children,
		this.inverted = false,
		this.hidden = false,
		super.key,
	});

	@override
	State<ExpandableButton> createState() => _ExpandableButtonState();
}

class _ExpandableButtonState extends State<ExpandableButton> {
	bool open = false;

	@override
	Widget build(BuildContext context) {
		return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
			buttonWithChild(
				context,
				() => setState(() => open = !open),
				Row(children: [
					Expanded(child: widget.child),
					Icon(open ? Icons.expand_less : Icons.expand_more, size: 16)
				]),
				inverted: widget.inverted,
				hidden: widget.hidden,
			),
			AnimatedSize(
				duration: const Duration(milliseconds: 200),
				curve: Curves.easeInOut,
				child: open
				? Column(children: widget.children)
				: const SizedBox.shrink(),
			),
		]);
	}
}

Widget buttonWithIcon (BuildContext c, void Function()? onPressed, IconData icon, {bool inverted = false, bool highlighted = false}){
	const double maxHeight = 10000; // This value should be an unreachable height

	return buttonWithChild(c, onPressed, FittedBox(fit: BoxFit.contain, child: Icon(icon, size: maxHeight)), inverted: inverted, highlighted: highlighted);
}

Widget buttonWithChild (BuildContext c, void Function()? onPressed, Widget child, {bool inverted = false, bool highlighted = false, bool hidden = false}){
	final cs = Theme.of(c).colorScheme;

	final style = ButtonStyle(
		backgroundColor: WidgetStateProperty.resolveWith((states) {
			var c = inverted ? cs.primary.withValues(alpha: 0.7) : null;
			if(!hidden) return c;
			if(states.contains(WidgetState.hovered)) {
				return null;
			}
			return Colors.transparent;
		}),
		foregroundColor: WidgetStateProperty.resolveWith(
			(states) { return inverted ? cs.onPrimary : null; }),
		padding: const WidgetStatePropertyAll(
			EdgeInsets.symmetric(horizontal: 4, vertical: 4),	),
		side: WidgetStateProperty.resolveWith(
			(states) => highlighted
				? const BorderSide(color: Colors.red, width: 2)
				: BorderSide.none,
		)
	);

	if(hidden)
		return TextButton(onPressed: onPressed,
		style: style,
		child: child
	);
	return ElevatedButton(onPressed: onPressed,
		style: style,
		child: child
	);
}

// hex format: "#123123"
Color colorFromHexString(String hex) {
	hex = hex.replaceFirst('#', '');
	if (hex.length == 6) hex = 'FF$hex'; // Add full opacity
	return Color(int.parse(hex, radix:16));
}

Future<bool?> askUseStateFile(BuildContext context) {
	return showDialog<bool>(
		context: context,
		builder: (_) => AlertDialog(
			title: const Text('Load Autosave?'),
			content: const Text(
				'An autosave file was found. This indicates the program did not close correctly last time.\nDo you want to load it or delete and load input.json?'
			),
			actions: [
				TextButton(
					onPressed: () => Navigator.pop(context, true),
					child: const Text('Load Autosave'),
				),
				ElevatedButton(
					onPressed: () => Navigator.pop(context, false),
					child: const Text('Load input.json'),
				),
			],
		),
	);
}

Future<String?> inputJsonLoad(BuildContext context) async {
	final cacheDir = await getApplicationCacheDirectory();
	final docDir = await getApplicationDocumentsDirectory();
	// if we have a state file, we load it instead of the original input file
	// State files get removed when closing the program normally
	debugPrint("cache path: ${cacheDir.path}/interscore/matchday_state.json");
	debugPrint("doc path: ${docDir.path}/interscore/input.json");

	final File stateFile = File('${cacheDir.path}/interscore/matchday_state.json');
	final File inputFile = File('${docDir.path}/interscore/input.json');
	File file;

	if (stateFile.existsSync()) {
		final useState = await askUseStateFile(context);
		if (useState == null) return null; // dialog dismissed
		file = useState ? stateFile : inputFile;
	} else
		file = inputFile;

	// if(!file.existsSync()) {
	// 	createDir('${docDir.path}/interscore/');
	// 	file = File('${docDir.path}/interscore/input.json');
	// }

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

List<int> i64ToBytes(int value, {bool littleEndian = false}) {
  final bytes = List<int>.filled(8, 0);

  for (int i = 0; i < 8; i++) {
    final shift = littleEndian ? i * 8 : (7 - i) * 8;
    bytes[i] = (value >> shift) & 0xFF;
  }

  return bytes;
}

int i64FromBytes(List<int> bytes, int offset, {bool littleEndian = false}) {
  int value = 0;

  for (int i = 0; i < 8; i++) {
    final shift = littleEndian ? i * 8 : (7 - i) * 8;
    value |= (bytes[offset + i] & 0xFF) << shift;
  }

  // Sign extend if the top bit is set
  if ((value & (1 << 63)) != 0) {
    value = value - (1 << 64);
  }

  return value;
}

List<int>? signalToMsg(MessageType msg, Matchday md, {int? additionalInfo, int? additionalInfo2}) {
	debugPrint("signalToMsg: ${msg}");
	if(msg == MessageType.DATA_META) {
		return [msg.value, ... utf8.encode(jsonEncode(md.meta.toJson()))];
	} else if(msg == MessageType.DATA_META_GAME) {
		return [msg.value, ... utf8.encode(jsonEncode(md.meta.game.toJson()))];
	} else if(msg == MessageType.DATA_META_TIME) {
		return [msg.value, ... utf8.encode(jsonEncode(md.meta.time.toJson()))];
	} else if(msg == MessageType.DATA_META_OBS) {
		return [msg.value, ... utf8.encode(jsonEncode(md.meta.obs.toJson()))];
	} else if(msg == MessageType.DATA_META_WIDGETS) {
		return [msg.value, ... utf8.encode(jsonEncode(md.meta.widgets.toJson()))];
	} else if(msg == MessageType.DATA_GAMES) {
		return [msg.value, ... utf8.encode(jsonEncode(md.games.map((g) => g.toJson()).toList()))];
	} else if(msg == MessageType.DATA_GAME) {
		if((additionalInfo ?? md.games.length) >= md.games.length) return null;
		return [msg.value, ... utf8.encode(jsonEncode(md.games[additionalInfo!].toJson()))];
	} else if(msg == MessageType.DATA_GAMEACTIONS) {
		if((additionalInfo ?? md.games.length) >= md.games.length) return null;
		return [msg.value, additionalInfo!, ... utf8.encode(jsonEncode(md.games[additionalInfo].actions?.map((g) => g.toJson()).toList()))];
	} else if(msg == MessageType.DATA_GAMEACTION) {
		if((additionalInfo ?? md.games.length) >= md.games.length) return null;
		if(md.games[additionalInfo!].actions == null) return null;
		final List<GameAction> actions = md.games[additionalInfo].actions!;
		if((additionalInfo2 ?? actions.length) >= actions.length) return null;
		return [msg.value, additionalInfo, ... utf8.encode(jsonEncode(actions[additionalInfo2!]))];
	} else if(msg == MessageType.DATA_FORMATS) {
		return [msg.value, ... utf8.encode(jsonEncode(md.formats.map((g) => g.toJson()).toList()))];
	} else if(msg == MessageType.DATA_FORMAT) {
		if((additionalInfo ?? md.formats.length) >= md.formats.length) return null;
		return [msg.value, ... utf8.encode(jsonEncode(md.formats[additionalInfo!]))];
	} else if(msg == MessageType.DATA_TEAMS) {
		return [msg.value, ... utf8.encode(jsonEncode(md.teams.map((g) => g.toJson()).toList()))];
	} else if(msg == MessageType.DATA_TEAM) {
		if((additionalInfo ?? md.teams.length) >= md.teams.length) return null;
		return [msg.value, ... utf8.encode(jsonEncode(md.teams[additionalInfo!]))];
	} else if(msg == MessageType.DATA_GROUPS) {
		return [msg.value, ... utf8.encode(jsonEncode(md.groups.map((g) => g.toJson()).toList()))];
	} else if(msg == MessageType.DATA_GROUP) {
		if((additionalInfo ?? md.groups.length) >= md.groups.length) return null;
		return [msg.value, ... utf8.encode(jsonEncode(md.groups[additionalInfo!]))];
	} else if(msg == MessageType.DATA_JSON) {
	  return [msg.value, ... utf8.encode(jsonEncode(md.toJson()))];
	} else if(msg == MessageType.DATA_TIMESTAMP) {
		return [msg.value, ... i64ToBytes(DateTime.now().millisecondsSinceEpoch ~/ 1000)];
	} else if(msg == MessageType.IM_THE_BOSS) {
		return [msg.value, 1];
	} else {
		return [msg.value];
	}
	// DATA_IM_BOSS should not be send by us because we are not a server!
}

// Returns if b == wanted, else null
// Why you ask? Its needed in md.dart in @JsonKey(toJson: boolOrNull) to omit default keys when writing to json
// Why not a lambda function you ask? Guess what: fuck you, it doesnt work because comptime
bool? boolOrNullFalse(bool b) => b == false ? false : null;
bool? boolOrNullTrue(bool b) => b == true ? true : null;
int? intOrNull0(int b) => b == 0 ? 0 : null;
int? intOrNullNot0(int b) => b != 0 ? b : null;

