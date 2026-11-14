import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'announcement_feed.dart';

Future<Map<String, dynamic>?> fetchAnnouncementFeed() async {
  try {
    final response = await web.window
        .fetch(
          announcementFeedPath(Uri.base).toJS,
          web.RequestInit(cache: 'no-cache'),
        )
        .toDart
        .timeout(const Duration(seconds: 6));
    if (!response.ok) return null;
    final text = (await response.text().toDart).toDart;
    final decoded = jsonDecode(text);
    return decoded is Map<String, dynamic> ? decoded : null;
  } catch (_) {
    return null;
  }
}
