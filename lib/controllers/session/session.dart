import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingua_flutter/controllers/request/request.dart' as request_controller;
import 'package:lingua_flutter/controllers/request/request.dart' show CancelToken, Options, ResponseType, DioError;
import 'package:lingua_flutter/controllers/cookie/cookie.dart' as cookie_controller;
import 'package:lingua_flutter/controllers/consent/consent.dart' as consent_controller;
import 'package:lingua_flutter/controllers/parsing_schema/parsing_schema.dart' as parsing_schema_controller;
import 'package:lingua_flutter/models/parsing_schema/stored_schema.dart';
import 'package:lingua_flutter/models/error/error.dart';
import 'package:lingua_flutter/utils/headers.dart';
import 'package:lingua_flutter/utils/crypto.dart';

import './constants.dart';

class Session {
  final List<Cookie> cookie;
  final String? cookieString;
  final String? signature;

  const Session({
    required this.cookie,
    required this.cookieString,
    this.signature,
  });
}

Future<Session?> get({
  String? word,
  CancelToken? cancelToken,
  bool followRedirects = true,
}) async {
  final bool isValid = await _isValid();
  final List<Cookie>? cookie = await cookie_controller.getList();
  final String? cookieString = await cookie_controller.getString();
  String? signature = await _signatureGet();

  if (isValid && cookie != null) {
    bool cookieIsExpired = false;
    for (var cookieItem in cookie) {
      if (cookieItem.expires is! DateTime || DateTime.now().compareTo(cookieItem.expires!) >= 0) {
        cookieIsExpired = true;
      }
    }
    if (!cookieIsExpired) {
      return Session(
        cookie: cookie,
        cookieString: cookieString,
        signature: signature,
      );
    }
  }

  // invalidate session if cookie expired
  await invalidate();
  StoredParsingSchema? storedParsingSchema = await parsing_schema_controller.get('current');
  if (storedParsingSchema == null) {
    return null;
  }
  ParsingSchema parsingSchema = storedParsingSchema.schema;
  final requestWord = word ?? SessionConstants.defaultWord;
  final url = parsingSchema.images.fields.url.replaceFirst('{word}', requestWord);
  const requestIconModifier = '&tbs=isz:i';

  try {
    final response = await request_controller.get(
      url: '$url$requestIconModifier',
      options: Options(
        contentType: 'application/x-www-form-urlencoded;charset=UTF-8',
        responseType: ResponseType.plain,
        headers: {
          'user-agent': parsingSchema.images.fields.userAgent,
          'accept-encoding': 'gzip, deflate',
          'cookie': cookieString,
        },
        followRedirects: false,
      ),
      cancelToken: cancelToken,
    );

    if (response.statusCode == 200) {
      await _setValid();
      await cookie_controller.set(response.headers['set-cookie']);

      final RegExp signatureReg = RegExp(parsingSchema.images.fields.safeSearchSignatureRegExp);
      Iterable<RegExpMatch> signatureParts = signatureReg.allMatches(response.data);

      for (var item in signatureParts) {
        final String? match = item.group(1);
        if (match != null) {
          signature = match;
          await _signatureSet(signature);
          break;
        }
      }
    }
  } on DioError catch (err) {
    final statusCode = err.response?.statusCode;
    if (statusCode != null && statusCode >= 300 && statusCode < 400) {
      await cookie_controller.set(err.response?.headers['set-cookie']);
      // try to acquire consent and request images again only for the first time
      if (followRedirects) {
        final location = getHeaderRedirectLocation(err.response?.headers);
        if (location != null) {
          await consent_controller.acquire(url: location, cancelToken: cancelToken);
          return get(word: word, cancelToken: cancelToken, followRedirects: false);
        }
      }
    } else if (!CancelToken.isCancel(err)) {
      throw CustomError(
        code: 500,
        message: 'Can\'t retrieve session',
        information: {
          'err': err,
          'requestWord': requestWord,
          'parsingSchema': parsingSchema,
        },
      );
    }
  }

  final List<Cookie>? newCookie = await cookie_controller.getList();
  final String? newCookieString = await cookie_controller.getString();

  if (newCookie != null) {
    return Session(
      cookie: newCookie,
      cookieString: newCookieString,
      signature: signature,
    );
  }

  return null;
}

Future<bool> _isValid() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(SessionConstants.validityPrefKey) == true;
}

Future<void> _setValid() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool(SessionConstants.validityPrefKey, true);
}

Future<void> invalidate() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool(SessionConstants.validityPrefKey, false);
}

Future<void> _signatureSet(String signature) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(SessionConstants.signaturePrefKey, encrypt(signature));
}

Future<String?> _signatureGet() async {
  final prefs = await SharedPreferences.getInstance();
  final signature = prefs.getString(SessionConstants.signaturePrefKey);

  return signature != null ? decrypt(signature) : null;
}

Future<void> signatureRemove() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove(SessionConstants.signaturePrefKey);
}