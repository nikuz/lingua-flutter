import 'dart:io';
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

  ImagePreview({
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
  String? _imageLocalPath;
  OverlayEntry? _overlayEntry;
  late MediaSourceType _sourceType;

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
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    this._overlayEntry?.remove();
    super.dispose();
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
            this._overlayEntry = this._buildOverlayEntry();
            final contextOverlay = Overlay.of(context);
            if (contextOverlay != null && this._overlayEntry != null) {
              contextOverlay.insert(this._overlayEntry!);
            }
          }
          if (widget.onTap is Function) {
            widget.onTap!();
          }
        },
        child: Container(
          width: widget.width,
          height: widget.height,
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    Widget image = Container();

    switch (_sourceType) {
      case MediaSourceType.base64:
        image = Image.memory(getBytesFrom64String(widget.imageSource));
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
    final Widget imageContainer = Container(
      width: 300,
      height: 300,
      child: _buildImage(),
    );

    return OverlayEntry(
      builder: (context) => Material(
        color: Color.fromRGBO(255, 255, 255, 0.6),
        elevation: 4.0,
        child: TextButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Draggable(
                maxSimultaneousDrags: 1,
                axis: Axis.vertical,
                child: imageContainer,
                feedback: imageContainer,
                childWhenDragging: Container(),
                onDragEnd: (drag) {
                  if (drag.offset.dy > 300 || drag.offset.dy < -10) {
                    this._overlayEntry?.remove();
                    if (widget.onPreviewClose is Function) {
                      widget.onPreviewClose!();
                    }
                  }
                },
              )
            ],
          ),
          onPressed: () {
            this._overlayEntry?.remove();
            if (widget.onPreviewClose is Function) {
              widget.onPreviewClose!();
            }
          },
        ),
      ),
    );
  }

  void _getLocalPath() async {
    String imageLocalPath = await getDocumentsPath();
    setState(() {
      _imageLocalPath = imageLocalPath;
    });
  }
}
