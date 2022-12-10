import 'package:audioplayers/audioplayers.dart';

final AudioContext _audioContext = AudioContext(
  iOS: AudioContextIOS(
    defaultToSpeaker: false,
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
    audioFocus: AndroidAudioFocus.none,
  ),
);

void setGlobalAudioContext() {
  AudioPlayer.global.setGlobalAudioContext(_audioContext);
}