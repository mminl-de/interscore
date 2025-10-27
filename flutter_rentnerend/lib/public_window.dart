import "dart:convert";
import "package:flutter/material.dart";
import "package:desktop_multi_window/desktop_multi_window.dart";

class PublicWindowInfo {
	final int id;
	final String name;
	final WindowController controller;

	PublicWindowInfo({
		required this.id,
		required this.name,
		required this.controller
	});
}

Future<void> create() async {
	try {
		final String name = "Public Window";
		final windowConfig = { "name": name };

		final windowController = await DesktopMultiWindow.createWindow(
			jsonEncode(windowConfig)
		);

		windowController
			..setFrame(const Offset(100, 100) & const Size(800, 600))
			..setTitle(name)
			..show();
	} catch (_) {}
}
