import 'dart:async';
import 'package:connectivity/connectivity.dart';

Future<bool> isInternetConnected() async {
  var connectivityResult = await Connectivity().checkConnectivity();

  return (
    connectivityResult == ConnectivityResult.mobile
    || connectivityResult == ConnectivityResult.wifi
  );
}

StreamSubscription<ConnectivityResult> subscribeToNetworkChange(Function callback) {
  return Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    callback(
        result == ConnectivityResult.mobile
        || result == ConnectivityResult.wifi
    );
  });
}
