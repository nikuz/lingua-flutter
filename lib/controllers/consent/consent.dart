import 'dart:developer' as developer;
import 'package:lingua_flutter/controllers/request/request.dart' as request_controller;
import 'package:lingua_flutter/controllers/request/request.dart' show Response, Options, CancelToken, ResponseType, DioError;
import 'package:lingua_flutter/controllers/parsing_schema/parsing_schema.dart' as parsing_schema_controller;
import 'package:lingua_flutter/controllers/cookie/cookie.dart' as cookie_controller;
import 'package:lingua_flutter/models/parsing_schema/stored_schema.dart';
import 'package:lingua_flutter/models/error/error.dart';
import 'package:lingua_flutter/utils/regexp.dart';

Future<void> acquire({
  required String url,
  CancelToken? cancelToken,
}) async {
  String? cookieString = await cookie_controller.getString();

  if (cookieString == null) {
    throw const CustomError(
      code: 0,
      message: 'Cookie should be acquired prior saving the consent',
    );
  }

  Response<dynamic> consentPageResponse = await request_controller.get(
    url: url,
    options: Options(
      contentType: 'application/x-www-form-urlencoded;charset=UTF-8',
      responseType: ResponseType.plain,
      headers: {
        'accept-encoding': 'gzip, deflate',
        'origin': Uri
            .parse(url)
            .origin,
        'cookie': cookieString,
      },
    ),
    cancelToken: cancelToken,
  );

  // if consent page sets new cookie, save them and proceed with new cookie list
  if (consentPageResponse.headers['set-cookie'] != null) {
    await cookie_controller.set(consentPageResponse.headers['set-cookie']);
    cookieString = await cookie_controller.getString();
  }

  StoredParsingSchema? storedParsingSchema = await parsing_schema_controller.get('current');
  if (storedParsingSchema == null) {
    return;
  }
  ParsingSchema parsingSchema = storedParsingSchema.schema;

  // retrieve form data from consent page response
  final formReg = RegExp(parsingSchema.cookieConsent.fields.formRegExp);
  final inputReg = RegExp(parsingSchema.cookieConsent.fields.inputRegExp);
  final form = formReg.firstMatch(consentPageResponse.data.toString());

  if (form == null) {
    throw const CustomError(
      code: 404,
      message: 'Consent page has no HTML forms',
    );
  }

  final formString = form.group(0);
  Iterable<RegExpMatch>? inputs;
  String? action;
  final Map<String, String> queryParameters = {};

  if (formString != null) {
    inputs = inputReg.allMatches(formString);
    action = htmlTagActionReg.firstMatch(formString)?.group(1);
  }

  if (inputs != null) {
    for (var input in inputs) {
      final inputString = input.group(0);
      if (inputString != null) {
        final name = htmlTagNameReg.firstMatch(inputString)?.group(1);
        final value = htmlTagValueReg.firstMatch(inputString)?.group(1);

        if (name != null && value != null) {
          queryParameters[name] = value;
        }
      }
    }
  }

  // save cookie consent and update local cookie
  if (action != null) {
    try {
      final consentSaveResponse = await request_controller.post(
        url: action,
        options: Options(
          contentType: 'application/x-www-form-urlencoded;charset=UTF-8',
          responseType: ResponseType.plain,
          headers: {
            'accept-encoding': 'gzip, deflate',
            'origin': Uri.parse(url).origin,
            'cookie': cookieString,
          },
          followRedirects: false,
        ),
        data: queryParameters,
        cancelToken: cancelToken,
      );

      final statusCode = consentSaveResponse.statusCode;
      if (statusCode != null && ((statusCode >= 300 && statusCode < 400) || statusCode == 204)) {
        await cookie_controller.set(consentSaveResponse.headers['set-cookie']);
      } else {
        developer.log('-------- Error: Cookie consent saving returned unexpected status code: $statusCode');
      }
    } on DioError catch (err) {
      final statusCode = err.response?.statusCode;
      // successful consent save request should return redirect
      if (statusCode != null && statusCode >= 300 && statusCode < 400) {
        await cookie_controller.set(err.response?.headers['set-cookie']);
      } else if (!CancelToken.isCancel(err)) {
        throw CustomError(
          code: 500,
          message: 'Can\'t acquire cookie consent',
          information: [
            err,
            url,
            parsingSchema,
          ],
        );
      }
    }
  } else {
    throw CustomError(
      code: 500,
      message: 'Can\'t acquire cookie consent',
      information: [
        url,
        parsingSchema,
        cookieString ?? '',
      ],
    );
  }
}