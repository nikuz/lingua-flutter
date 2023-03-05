import 'dart:io';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingua_flutter/utils/crypto.dart';

const _prefsKey = 'cookie';
List<Cookie>? _cookieCache;

Future<List<Cookie>?> set(List<String>? newCookie) async {
  if (newCookie == null) {
    return null;
  }
  final prefs = await SharedPreferences.getInstance();
  final newCookieList = newCookie.map((item) => Cookie.fromSetCookieValue(item)).toList();
  List<Cookie>? savedCookie = await get();

  if (savedCookie != null) {
    // merge saved cookie with new cookie
    for (var savedCookieItem in savedCookie) {
      // add all saved cookie to newCookieList if they not overwritten in the newCookieList
      if (newCookieList.firstWhereOrNull((newCookieItem) => newCookieItem.name == savedCookieItem.name) == null) {
        newCookieList.add(savedCookieItem);
      }
    }
  }

  prefs.setString(_prefsKey, encrypt(newCookieList.join('\n')));
  _cookieCache = newCookieList;
  return _cookieCache;
}

Future<List<Cookie>?> get() async {
  if (_cookieCache != null) {
    return _cookieCache;
  }

  final prefs = await SharedPreferences.getInstance();
  final String? cookie = prefs.getString(_prefsKey);

  if (cookie != null) {
     final decryptedCookie = decrypt(cookie);
     _cookieCache = decryptedCookie.split('\n').map((item) => Cookie.fromSetCookieValue(item)).toList();
     return _cookieCache;
  }

  return null;
}

void clear() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove(_prefsKey);
  _cookieCache = null;
}