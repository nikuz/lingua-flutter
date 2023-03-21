import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:lingua_flutter/app_config.secret.dart';

Future<void> initiateErrorLogger() {
  return SentryFlutter.init((options) {
      options.dsn = sentryDNS;
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
    }
  );
}

void recordError(
  Object err,
  StackTrace stack,
  { Map<String, Object>? information }
) {
  if (kDebugMode) {
    print('--------- error logger ----------');
    print(err);
    print(stack);
    print(information);
    print('---------  ----------');
  } else {
    Sentry.captureException(
      err,
      stackTrace: stack,
      hint: information != null ? Hint.withMap(information) : null,
    );
  }
}