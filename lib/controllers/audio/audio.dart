import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

final AudioPlayer audioPlayer = AudioPlayer();

Future<void> audioPlay(Source source) async {
  if (!_audioPlayerSourceChangeStreamController.isClosed) {
    _audioPlayerSourceChangeStreamController.add(source);
  }
  await audioPlayer.stop();
  return audioPlayer.play(source);
}

Future<void> audioStop() {
  return audioPlayer.stop();
}

final StreamController<Source> _audioPlayerSourceChangeStreamController = StreamController<Source>.broadcast();

final Stream<Source> onAudioPlayerSourceChanged = _audioPlayerSourceChangeStreamController.stream;

const AudioContext _audioContext = AudioContext(
  iOS: AudioContextIOS(
    category: AVAudioSessionCategory.playback,
    options: [
      AVAudioSessionOptions.defaultToSpeaker,
      AVAudioSessionOptions.mixWithOthers,
      AVAudioSessionOptions.allowAirPlay,
      AVAudioSessionOptions.allowBluetooth,
      AVAudioSessionOptions.allowBluetoothA2DP,
    ],
  ),
  android: AudioContextAndroid(
    isSpeakerphoneOn: true,
    stayAwake: true,
    contentType: AndroidContentType.sonification,
    usageType: AndroidUsageType.assistanceSonification,
    audioFocus: AndroidAudioFocus.gain,
  ),
);

void setGlobalAudioContext() {
  AudioPlayer.global.setAudioContext(_audioContext);
}