import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/models/translation_container/translation_container.dart';
import 'package:lingua_flutter/widgets/image_preview/image_preview.dart';
import 'package:lingua_flutter/utils/files.dart';

class Sharing {
  final BuildContext context;
  final TranslationContainer translation;

  const Sharing({
    required this.context,
    required this.translation,
  });

  static dismiss(BuildContext context) {
    Navigator.of(context, rootNavigator: true).maybePop();
  }

  Future share() {
    return showGeneralDialog(
      context: context,
      barrierLabel: '',
      barrierColor: const Color(0x80000000),
      transitionDuration: const Duration(milliseconds: 100),
      pageBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation) {
        return SharingImageView(
          translation: translation,
        );
      },
    );
  }
}

class SharingImageView extends StatefulWidget {
  final TranslationContainer translation;

  const SharingImageView({
    super.key,
    required this.translation,
  });

  @override
  State<SharingImageView> createState() => _SharingImageViewState();
}

class _SharingImageViewState extends State<SharingImageView> {
  GlobalKey containerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (mounted) {
        try {
          final filePath = await _captureWidgetSnapshot();
          if (mounted) {
            Sharing.dismiss(context);
          }
          if (filePath != null) {
            _share(filePath);
          }
        } catch(err) {
          if (mounted) {
            Sharing.dismiss(context);
          }
          rethrow;
        }
      }
    });
  }

  Future<String?> _captureWidgetSnapshot() async {
    RenderRepaintBoundary? boundary = containerKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    if (boundary == null) {
      return null;
    }

    final dir = await getDocumentsPath();
    final image = await boundary.toImage();
    final imageBytesData = await image.toByteData(
      format: ImageByteFormat.png,
    );

    if (imageBytesData == null) {
      return null;
    }

    final imageBytes = imageBytesData.buffer.asUint8List();

    String filePath = '$dir/Wisual-sharing.png';
    File screenshotFile = File(filePath);
    screenshotFile = await screenshotFile.create(recursive: true);
    await screenshotFile.writeAsBytes(imageBytes);

    return filePath;
  }

  void _share(String filePath) async {
    Share.shareXFiles([XFile(filePath)]);
  }

  Widget _buildTextWithStroke(String text) {
    return Stack(
      children: <Widget>[
        // Stroked text as border.
        Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = Colors.black,
          ),
        ),
        // Solid text as fill.
        Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);
    final translation = widget.translation;
    final double? size = translation.image == null ? 300 : null;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Center(
            child: CircularProgressIndicator(
              color: theme.colors.focus,
            ),
          ),

          Positioned(
            left: -1000,
            top: -1000,
            child: Opacity(
              opacity: 0.01,
              child: RepaintBoundary(
                key: containerKey,
                child: Stack(
                  children: [
                    ImagePreview(
                      imageSource: translation.image,
                      width: size,
                      height: size,
                    ),

                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: _buildTextWithStroke(translation.word),
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: _buildTextWithStroke(translation.translation),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
