import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lingua_flutter/utils/files.dart';
import 'package:lingua_flutter/utils/convert.dart';

final AudioContext audioContext = AudioContext(
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

class PronunciationWidget extends StatefulWidget {
  final String pronunciationUrl;
  final double? size;
  final Color? color;
  final bool? autoPlay;
  final bool? isLocal;

  const PronunciationWidget({
    Key? key,
    required this.pronunciationUrl,
    this.size,
    this.color,
    this.autoPlay,
    this.isLocal,
  }) : super(key: key);

  @override
  _PronunciationWidgetState createState() => _PronunciationWidgetState();
}

class _PronunciationWidgetState extends State<PronunciationWidget> {
  AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<PlayerState>? _audioPlayerStateSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerErrorSubscription;
  PlayerState _playerState = PlayerState.stopped;
  bool _isPlayerStopped(state) => (
      state == PlayerState.stopped || state == PlayerState.completed
  );

  Future<void> _playPronunciation() async {
    String pronunciationUrl = widget.pronunciationUrl;
    if (pronunciationUrl.indexOf('data:audio') != -1) {
      final String dir = await getTempPath();
      Uint8List fileBytes = getBytesFrom64String(pronunciationUrl);
      final String filePath = '$dir/pronunciation.mp3';
      final File file = File(filePath);
      await file.writeAsBytes(fileBytes);
      await _audioPlayer.play(DeviceFileSource(filePath));
    } else if (widget.isLocal!) {
      String dir = await getDocumentsPath();
      pronunciationUrl = '$dir${widget.pronunciationUrl}';
      await _audioPlayer.play(DeviceFileSource(pronunciationUrl));
    } else {
      await _audioPlayer.play(UrlSource(pronunciationUrl));
    }
    setState(() => this._playerState = PlayerState.playing);
  }

  Future<void> _stopPronunciation() async {
    await _audioPlayer.stop();
    setState(() => this._playerState = PlayerState.stopped);
  }

  void _onPlayerStateChange(PlayerState state) {
    setState(() => _playerState = state);
  }

  void _onPlayerStateChangeError(msg) {
    setState(() => _playerState = PlayerState.stopped);
  }

  @override
  void initState() {
    super.initState();
    AudioPlayer.global.setGlobalAudioContext(audioContext);
    _audioPlayerStateSubscription = _audioPlayer.onPlayerStateChanged.listen(
        _onPlayerStateChange,
        onError: _onPlayerStateChangeError
    );
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      setState(() => _playerState = PlayerState.completed);
    });
    if (widget.autoPlay == true) {
      _playPronunciation();
    }
  }

  @override
  void dispose() {
    _audioPlayerStateSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size ?? 36;
    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: Size(size + 20, size + 20),
        padding: EdgeInsets.zero,
        backgroundColor: Theme.of(context).cardColor,
        shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.all(
            Radius.circular(size),
          ),
        ),
      ),
      child: Icon(
        _isPlayerStopped(_playerState) ? Icons.volume_up : Icons.stop,
        color: widget.color != null ? widget.color : Colors.blueGrey,
        size: size,
      ),
      onPressed: () {
        if (_isPlayerStopped(_playerState)) {
          _playPronunciation();
        } else {
          _stopPronunciation();
        }
      },
    );
  }
}
