import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lingua_flutter/utils/files.dart';
import 'package:lingua_flutter/utils/convert.dart';
import 'package:lingua_flutter/utils/media_source.dart';
import 'package:lingua_flutter/widgets/button/button.dart';

class PronunciationWidget extends StatefulWidget {
  final String? pronunciationSource;
  final double? size;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool? autoPlay;
  final Color? highlightColor;
  final Color? splashColor;

  const PronunciationWidget({
    Key? key,
    this.pronunciationSource,
    this.size,
    this.iconColor,
    this.backgroundColor,
    this.autoPlay,
    this.highlightColor,
    this.splashColor,
  }) : super(key: key);

  @override
  State<PronunciationWidget> createState() => _PronunciationWidgetState();
}

class _PronunciationWidgetState extends State<PronunciationWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  late StreamSubscription<PlayerState> _audioPlayerStateSubscription;
  late StreamSubscription  _playerCompleteSubscription;
  MediaSourceType? _sourceType;

  @override
  void initState() {
    super.initState();
    if (widget.pronunciationSource != null) {
      _sourceType = MediaSource.getType(widget.pronunciationSource!);
    }
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
  void didUpdateWidget(covariant PronunciationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pronunciationSource != oldWidget.pronunciationSource && widget.pronunciationSource != null) {
      _sourceType = MediaSource.getType(widget.pronunciationSource!);
      if (widget.autoPlay == true) {
        _playPronunciation();
      }
    }
  }

  @override
  void dispose() {
    _audioPlayerStateSubscription.cancel();
    _playerCompleteSubscription.cancel();
    super.dispose();
  }

  bool _isPlayerStopped(state) => (
      state == PlayerState.stopped || state == PlayerState.completed
  );

  Future<void> _playPronunciation() async {
    if (widget.pronunciationSource != null) {
      switch (_sourceType) {
        case MediaSourceType.base64:
          final String dir = await getTempPath();
          Uint8List fileBytes = getBytesFrom64String(widget.pronunciationSource!);
          final String filePath = '$dir/pronunciation.mp3';
          final File file = File(filePath);
          await file.writeAsBytes(fileBytes);
          await _audioPlayer.play(DeviceFileSource(filePath));
          break;

        case MediaSourceType.local:
          String dir = await getDocumentsPath();
          await _audioPlayer.play(DeviceFileSource('$dir${widget.pronunciationSource}'));
          break;

        case MediaSourceType.network:
          await _audioPlayer.play(UrlSource(widget.pronunciationSource!));
          break;

        default:
      }
      setState(() => _playerState = PlayerState.playing);
    }
  }

  Future<void> _stopPronunciation() async {
    await _audioPlayer.stop();
    setState(() => _playerState = PlayerState.stopped);
  }

  void _onPlayerStateChange(PlayerState state) {
    setState(() => _playerState = state);
  }

  void _onPlayerStateChangeError(msg) {
    setState(() => _playerState = PlayerState.stopped);
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size ?? 36;
    IconData icon = _isPlayerStopped(_playerState) ? Icons.volume_up : Icons.stop;
    Color iconColor = widget.iconColor ?? Colors.blueGrey;
    Color backgroundColor = widget.backgroundColor ?? Theme.of(context).cardColor;

    if (widget.pronunciationSource == null) {
      icon = Icons.volume_off;
      iconColor = iconColor.withOpacity(0.2);
    }

    return Button(
      icon: icon,
      iconSize: size - 15,
      textColor: iconColor,
      backgroundColor: backgroundColor,
      width: size,
      height: size,
      shape: ButtonShape.circular,
      outlined: false,
      highlightColor: widget.highlightColor,
      splashColor: widget.splashColor,
      onPressed: () {
        if (widget.pronunciationSource != null) {
          if (_isPlayerStopped(_playerState)) {
            _playPronunciation();
          } else {
            _stopPronunciation();
          }
        }
      },
    );
  }
}