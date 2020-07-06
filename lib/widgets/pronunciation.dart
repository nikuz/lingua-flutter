import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:lingua_flutter/app_config.dart' as appConfig;
import 'package:lingua_flutter/helpers/api.dart';
import 'package:lingua_flutter/helpers/db.dart';
import 'package:lingua_flutter/utils/sizes.dart';
import 'package:lingua_flutter/utils/convert.dart';
import 'package:lingua_flutter/utils/files.dart';

void monitorNotificationStateChanges(AudioPlayerState value) {
  print('state => $value');
}

class PronunciationWidget extends StatefulWidget {
  final String pronunciationUrl;
  final double size;
  final Color color;
  final bool autoPlay;
  final bool isLocal;

  const PronunciationWidget({
    Key key,
    @required this.pronunciationUrl,
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
  StreamSubscription<AudioPlayerState> _audioPlayerStateSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  AudioPlayerState _playerState = AudioPlayerState.STOPPED;
  bool _isPlayerStopped(state) => (
      state == AudioPlayerState.STOPPED || state == AudioPlayerState.COMPLETED
  );

  Future<void> _playPronunciation() async {
    String pronunciationUrl = widget.pronunciationUrl;
    if (pronunciationUrl.indexOf('data:audio') != -1) {
      final String dir = await getTempPath();
      Uint8List fileBytes = getBytesFrom64String(pronunciationUrl);
      final String filePath = '$dir/pronunciation.mp3';
      final File file = File(filePath);
      await file.writeAsBytes(fileBytes);
      await _audioPlayer.play(filePath, isLocal:true);
    } else if (widget.isLocal && db != null) {
      String dir = await getDocumentsPath();
      pronunciationUrl = '$dir${widget.pronunciationUrl}';
      await _audioPlayer.play(pronunciationUrl, isLocal:true);
    } else if (!widget.isLocal && !widget.pronunciationUrl.contains('http')) {
      pronunciationUrl = '${getApiUri()}${widget.pronunciationUrl}';
      await _audioPlayer.play(pronunciationUrl);
    } else {
      await _audioPlayer.play(pronunciationUrl);
    }
    setState(() => this._playerState = AudioPlayerState.PLAYING);
  }

  Future<void> _stopPronunciation() async {
    await _audioPlayer.stop();
    setState(() => this._playerState = AudioPlayerState.STOPPED);
  }

  void _onPlayerStateChange(AudioPlayerState state) {
    setState(() => _playerState = state);
  }

  void _onPlayerStateChangeError(msg) {
    setState(() => _playerState = AudioPlayerState.STOPPED);
  }

  @override
  void initState() {
    super.initState();
    _audioPlayerStateSubscription = _audioPlayer.onPlayerStateChanged.listen(
        _onPlayerStateChange,
        onError: _onPlayerStateChangeError
    );
    _playerCompleteSubscription = _audioPlayer.onPlayerCompletion.listen((event) {
      setState(() => _playerState = AudioPlayerState.COMPLETED);
    });
    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
    });
    if (!appConfig.kIsWeb && Platform.isIOS) {
      _audioPlayer.monitorNotificationStateChanges(monitorNotificationStateChanges);
    }
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
    final double size = widget.size ?? SizeUtil.vmax(36);
    return ButtonTheme(
      minWidth: size + SizeUtil.vmax(20),
      height: size + SizeUtil.vmax(20),
      padding: EdgeInsets.all(0),
      child: FlatButton(
        color: Colors.white,
        shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.all(
            Radius.circular(size),
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
      ),
    );
  }
}
