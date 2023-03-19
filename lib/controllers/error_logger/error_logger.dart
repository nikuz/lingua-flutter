import 'package:flutter/foundation.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void initiateErrorLogger() {
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };
}

void recordError(
  Object err,
  StackTrace stack,
  { Iterable<Object>? information }
) {
  if (kDebugMode) {
    print('--------- error logger ----------');
    print(err);
    print(stack);
    print(information);
    print('---------  ----------');
  } else {
    // FirebaseCrashlytics.instance.recordError(
    //   err,
    //   stack,
    //   information: information ?? [],
    // );
  }
}

void recordFatalError(
  Object err,
  StackTrace stack,
  { Iterable<Object>? information }
) {
  if (kDebugMode) {
    print('--------- error logger ----------');
    print(err);
    print(stack);
    print(information);
    print('---------  ----------');
  } else {
    // FirebaseCrashlytics.instance.recordError(
    //   err,
    //   stack,
    //   fatal: true,
    //   information: information ?? [],
    // );
  }
}