import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:lingua_flutter/helpers/api.dart';

class PronunciationWidget extends StatefulWidget {
  final String pronunciationUrl;
  final double size;
  final Color color;
  final bool autoPlay;

  const PronunciationWidget({
    Key key,
    @required this.pronunciationUrl,
    this.size,
    this.color,
    this.autoPlay,
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
    final pronunciationUrl = '${getApiUri()}${widget.pronunciationUrl}';
    await _audioPlayer.play(pronunciationUrl);
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
    final double size = widget.size ?? 36.0;
    return ButtonTheme(
      minWidth: size + 20,
      height: size + 20,
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
