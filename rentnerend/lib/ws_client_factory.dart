import 'package:flutter/material.dart';
import 'md.dart';

import 'ws_client.dart';
import 'ws_client_io.dart'
	if (dart.library.io) 'ws_client_io.dart'
	if (dart.library.html) 'ws_client_web.dart';

WSClient createWSClient(String url, ValueNotifier<Matchday> mdl, bool allowReadFrom, bool allowWriteTo) {
	return createClient(url, mdl, allowReadFrom, allowWriteTo);
}
