import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lingua_flutter/utils/convert.dart';
import 'package:lingua_flutter/utils/files.dart';
import 'package:lingua_flutter/utils/media_source.dart';

class ImagePreview extends StatefulWidget {
  final double width;
  final double height;
  final String imageSource;
  final bool withPreviewOverlay;
  final Function? onTap;
  final Function? onPreviewClose;

  const ImagePreview({
    Key? key,
    required this.width,
    required this.height,
    required this.imageSource,
    this.withPreviewOverlay = true,
    this.onTap,
    this.onPreviewClose,
  }) : super(key: key);

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  late MediaSourceType _sourceType;
  String? _imageLocalPath;
  OverlayEntry? _overlayEntry;
  Uint8List? _sourceBytes;

  @override
  void initState() {
    super.initState();
    _sourceType = MediaSource.getType(widget.imageSource);
    if (_sourceType == MediaSourceType.local) {
      _getLocalPath();
    }
  }

  @override
  void didUpdateWidget(ImagePreview oldWidget) {
    if (oldWidget.imageSource != widget.imageSource) {
      _sourceType = MediaSource.getType(widget.imageSource);
      if (_sourceType == MediaSourceType.local) {
        _getLocalPath();
      }
      if (_sourceBytes != null) {
        _sourceBytes = getBytesFrom64String(widget.imageSource);
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  void _getLocalPath() async {
    String imageLocalPath = await getDocumentsPath();
    setState(() {
      _imageLocalPath = imageLocalPath;
    });
  }

  Widget _buildImage() {
    Widget image = Container();

    switch (_sourceType) {
      case MediaSourceType.base64:
        _sourceBytes ??= getBytesFrom64String(widget.imageSource);
        image = Image.memory(_sourceBytes!);
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
        image = Image.network(widget.imageSource);
        break;
      default:
    }

    return image;
  }

  OverlayEntry _buildOverlayEntry() {
    final Widget imageContainer = SizedBox(
      width: 300,
      height: 300,
      child: _buildImage(),
    );

    return OverlayEntry(
      builder: (context) => Material(
        color: const Color.fromRGBO(255, 255, 255, 0.6),
        elevation: 4.0,
        child: TextButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Draggable(
                maxSimultaneousDrags: 1,
                axis: Axis.vertical,
                feedback: imageContainer,
                childWhenDragging: Container(),
                onDragEnd: (drag) {
                  if (drag.offset.dy > 300 || drag.offset.dy < -10) {
                    _overlayEntry?.remove();
                    if (widget.onPreviewClose is Function) {
                      widget.onPreviewClose!();
                    }
                  }
                },
                child: imageContainer,
              )
            ],
          ),
          onPressed: () {
            _overlayEntry?.remove();
            if (widget.onPreviewClose is Function) {
              widget.onPreviewClose!();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      constraints: BoxConstraints(
        minWidth: widget.width,
      ),
      child: GestureDetector(
        onTap: () {
          if (widget.withPreviewOverlay == true) {
            _overlayEntry = _buildOverlayEntry();
            final contextOverlay = Overlay.of(context);
            if (contextOverlay != null && _overlayEntry != null) {
              contextOverlay.insert(_overlayEntry!);
            }
          }
          if (widget.onTap is Function) {
            widget.onTap!();
          }
        },
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: _buildImage(),
        ),
      ),
    );
  }
}
