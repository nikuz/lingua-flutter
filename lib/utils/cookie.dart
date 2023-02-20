import 'dart:io';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './crypto.dart';

const _prefsKey = 'cookie';
List<Cookie>? _cookieCache;

void setCookie(String newCookie) async {
  final prefs = await SharedPreferences.getInstance();
  final newCookieList = newCookie.split('\n').map((item) => Cookie.fromSetCookieValue(item)).toList();
  List<Cookie>? savedCookie = await getCookie();

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
}

Future<List<Cookie>?> getCookie() async {
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

void clearCookie() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove(_prefsKey);
  _cookieCache = null;
}