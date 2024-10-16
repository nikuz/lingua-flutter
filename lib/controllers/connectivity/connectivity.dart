import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

Map<String, Function> _listeners = {};

Future<bool> isInternetConnected() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  return _isConnected(connectivityResult);
}

StreamSubscription<List<ConnectivityResult>> initiateNetworkChangeSubscription() {
  return Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
    bool isConnected = _isConnected(result);
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

bool _isConnected(List<ConnectivityResult> result) => result.contains(ConnectivityResult.none);