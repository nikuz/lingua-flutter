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