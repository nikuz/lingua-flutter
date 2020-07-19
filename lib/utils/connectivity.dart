import 'dart:async';
import 'package:connectivity/connectivity.dart';

Map<String, Function> _listeners = {};

Future<bool> isInternetConnected() async {
  var connectivityResult = await Connectivity().checkConnectivity();

  return (
    connectivityResult == ConnectivityResult.mobile
    || connectivityResult == ConnectivityResult.wifi
  );
}

StreamSubscription<ConnectivityResult> initiateNetworkChangeSubscription() {
  return Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    bool isConnected = (
        result == ConnectivityResult.mobile
        || result == ConnectivityResult.wifi
    );
    _listeners.forEach((String key, Function listener) {
      listener(isConnected);
    });
  });
}

void subscribeToNetworkChange(String name, Function callback) {
  _listeners[name] = callback;
}

void unsubscribeFromNetworkChange(String name) {
  _listeners.remove(name);
}
