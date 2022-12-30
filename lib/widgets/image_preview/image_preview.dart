import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lingua_flutter/utils/convert.dart';
import 'package:lingua_flutter/utils/files.dart';
import 'package:lingua_flutter/utils/media_source.dart';
import 'package:lingua_flutter/styles/styles.dart';

import './image_preview_modal.dart';

enum ImagePreviewShape {
  rectangular,
  oval,
}

class ImagePreview extends StatefulWidget {
  final double? width;
  final double? height;
  final String? imageSource;
  final Color? errorIconColor;
  final bool withPreviewOverlay;
  final ImagePreviewShape shape;
  final Function? onTap;
  final Function? onPreviewClose;

  const ImagePreview({
    Key? key,
    this.width,
    this.height,
    this.imageSource,
    this.errorIconColor,
    this.withPreviewOverlay = true,
    this.shape = ImagePreviewShape.rectangular,
    this.onTap,
    this.onPreviewClose,
  }) : super(key: key);

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  MediaSourceType? _sourceType;
  String? _imageLocalPath;
  Uint8List? _sourceBytes;

  @override
  void initState() {
    super.initState();
    if (widget.imageSource != null) {
      _sourceType = MediaSource.getType(widget.imageSource!);
    }
    if (_sourceType == MediaSourceType.local) {
      _getLocalPath();
    }
  }

  @override
  void didUpdateWidget(ImagePreview oldWidget) {
    if (oldWidget.imageSource != widget.imageSource && widget.imageSource != null) {
      _sourceType = MediaSource.getType(widget.imageSource!);
      if (_sourceType == MediaSourceType.local) {
        _getLocalPath();
      }
      if (_sourceBytes != null) {
        _sourceBytes = getBytesFrom64String(widget.imageSource!);
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  void _getLocalPath() async {
    String imageLocalPath = await getDocumentsPath();
    setState(() {
      _imageLocalPath = imageLocalPath;
    });
  }

  Widget _buildImage() {
    final MyTheme theme = Styles.theme(context);
    Widget image = Container();

    if (widget.imageSource != null) {
      switch (_sourceType) {
        case MediaSourceType.base64:
          _sourceBytes ??= getBytesFrom64String(widget.imageSource!);
          image = Image.memory(
            _sourceBytes!,
            fit: BoxFit.contain,
          );
          break;
        case MediaSourceType.local:
          if (_imageLocalPath != null) {
            image = Image.file(
              File('$_imageLocalPath${widget.imageSource}'),
              fit: BoxFit.contain,
            );
          }
          break;
        case MediaSourceType.network:
          image = Image.network(widget.imageSource!);
          break;
        default:
      }
    } else {
      image = Icon(
        Icons.broken_image,
        color: widget.errorIconColor ?? theme.colors.grey,
        size: widget.width != null ? widget.width! / 1.5 : 20,
      );
    }

    return image;
  }

  @override
  Widget build(BuildContext context) {
    Widget image = _buildImage();

    if (widget.shape == ImagePreviewShape.oval) {
      image = ClipOval(
        child: image,
      );
    }

    return Container(
      height: widget.height,
      constraints: BoxConstraints(
        minWidth: widget.width ?? 0,
      ),
      child: GestureDetector(
        onTap: () {
          if (widget.withPreviewOverlay == true && widget.imageSource != null) {
            ImagePreviewModal(
              context: context,
              isFramed: false,
              child: _buildImage(),
            ).show().then((dynamic) {
              if (widget.onPreviewClose is Function) {
                widget.onPreviewClose!();
              }
            });
          }
          if (widget.onTap is Function) {
            widget.onTap!();
          }
        },
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: image,
        ),
      ),
    );
  }
}
