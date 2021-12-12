import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:lingua_flutter/utils/sizes.dart';
import 'package:lingua_flutter/utils/files.dart';

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
  StreamSubscription<PlayerState> _audioPlayerStateSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  PlayerState _playerState = PlayerState.STOPPED;
  bool _isPlayerStopped(state) => (
      state == PlayerState.STOPPED || state == PlayerState.COMPLETED
  );

  Future<void> _playPronunciation() async {
    String pronunciationUrl = widget.pronunciationUrl;
    if (pronunciationUrl.indexOf('data:audio') != -1) {
      await _audioPlayer.play(pronunciationUrl);
    } else if (widget.isLocal) {
      String dir = await getDocumentsPath();
      pronunciationUrl = '$dir${widget.pronunciationUrl}';
      await _audioPlayer.play(pronunciationUrl, isLocal:true);
    } else {
      await _audioPlayer.play(pronunciationUrl);
    }
    setState(() => this._playerState = PlayerState.PLAYING);
  }

  Future<void> _stopPronunciation() async {
    await _audioPlayer.stop();
    setState(() => this._playerState = PlayerState.STOPPED);
  }

  void _onPlayerStateChange(PlayerState state) {
    setState(() => _playerState = state);
  }

  void _onPlayerStateChangeError(msg) {
    setState(() => _playerState = PlayerState.STOPPED);
  }

  @override
  void initState() {
    super.initState();
    _audioPlayerStateSubscription = _audioPlayer.onPlayerStateChanged.listen(
        _onPlayerStateChange,
        onError: _onPlayerStateChangeError
    );
    _playerCompleteSubscription = _audioPlayer.onPlayerCompletion.listen((event) {
      setState(() => _playerState = PlayerState.COMPLETED);
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
    final double size = widget.size ?? SizeUtil.vmax(36);
    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: Size(size + SizeUtil.vmax(20), size + SizeUtil.vmax(20)),
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
