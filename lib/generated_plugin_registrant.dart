//
// Generated file. Do not edit.
//

// ignore: unused_import
import 'dart:ui';

import 'package:audioplayers/audioplayers_web.dart';
import 'package:shared_preferences_web/shared_preferences_web.dart';
import 'package:connectivity_for_web/connectivity_for_web.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// ignore: public_member_api_docs
void registerPlugins(PluginRegistry registry) {
  AudioplayersPlugin.registerWith(registry.registrarFor(AudioplayersPlugin));
  SharedPreferencesPlugin.registerWith(registry.registrarFor(SharedPreferencesPlugin));
  ConnectivityPlugin.registerWith(registry.registrarFor(ConnectivityPlugin));
  registry.registerMessageHandler();
}
