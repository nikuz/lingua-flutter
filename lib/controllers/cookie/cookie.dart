import 'dart:io';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingua_flutter/utils/crypto.dart';

import './constants.dart';

List<Cookie>? _cookieCache;

Future<List<Cookie>?> set(List<String>? newCookie) async {
  if (newCookie == null) {
    return null;
  }
  final prefs = await SharedPreferences.getInstance();
  final newCookieList = newCookie.map((item) => Cookie.fromSetCookieValue(item)).toList();
  List<Cookie>? savedCookie = await getList();

  if (savedCookie != null) {
    // merge saved cookie with new cookie
    for (var savedCookieItem in savedCookie) {
      // add all saved cookie to newCookieList if they not overwritten in the newCookieList
      if (newCookieList.firstWhereOrNull((newCookieItem) => newCookieItem.name == savedCookieItem.name) == null) {
        newCookieList.add(savedCookieItem);
      }
    }
  }

  await prefs.setString(CookieConstants.prefKey, encrypt(newCookieList.join('\n')));
  _cookieCache = newCookieList;
  return _cookieCache;
}

Future<List<Cookie>?> getList() async {
  if (_cookieCache != null) {
    return _cookieCache;
  }

  final prefs = await SharedPreferences.getInstance();
  final String? cookie = prefs.getString(CookieConstants.prefKey);

  if (cookie != null) {
     final decryptedCookie = decrypt(cookie);
     _cookieCache = decryptedCookie.split('\n').map((item) => Cookie.fromSetCookieValue(item)).toList();
     return _cookieCache;
  }

  return null;
}

Future<String?> getString() async {
  final List<Cookie>? cookie = await getList();

  if (cookie != null) {
    return cookie.map((item) => '${item.name}=${item.value}').join('; ');
  }

  return null;
}

void clear() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(CookieConstants.prefKey);
  _cookieCache = null;
}