import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lingua_flutter/helpers/api.dart';
import 'package:lingua_flutter/helpers/db.dart';
import 'package:lingua_flutter/utils/convert.dart';
import 'package:lingua_flutter/utils/files.dart';
import 'package:lingua_flutter/utils/sizes.dart';

class ResizableImage extends StatefulWidget {
  final double width;
  final double height;
  final String imageSource;
  final String updatedAt;
  final bool isLocal;
  final bool withPreviewOverlay;
  final Function onTap;
  final Function onPreviewClose;

  ResizableImage({
    @required this.width,
    @required this.height,
    @required this.imageSource,
    @required this.updatedAt,
    this.isLocal,
    this.withPreviewOverlay,
    this.onTap,
    this.onPreviewClose,
  });

  @override
  _ResizableImageState createState() => _ResizableImageState();
}

class _ResizableImageState extends State<ResizableImage> {
  String imageBaseUrl;
  bool isBase64Image = false;
  OverlayEntry _overlayEntry;

  @override
  void initState() {
    super.initState();
    _isBase64Image();
    _getImageBaseUrl();
  }

  @override
  void didUpdateWidget(ResizableImage oldWidget) {
    _isBase64Image();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    Widget image = Container();

    if (isBase64Image) {
      image = Image.memory(getBytesFrom64String(widget.imageSource));
    } else {
      if (widget.isLocal && db != null && imageBaseUrl != null) {
        image = Image.file(
          File('$imageBaseUrl${widget.imageSource}'),
          fit: BoxFit.contain,
        );
      } else if (!widget.isLocal) {
        image = CachedNetworkImage(
          imageUrl: '${getApiUri()}${widget.imageSource}?${widget.updatedAt}',
          errorWidget: (context, url, error) => Icon(Icons.error),
        );
      }
    }

    image = Container(
      width: SizeUtil.vmax(widget.width),
      height: SizeUtil.vmax(widget.height),
      child: image,
    );

    return ButtonTheme(
      minWidth: SizeUtil.vmax(widget.width),
      height: SizeUtil.vmax(widget.height),
      padding: EdgeInsets.all(0),
      child: FlatButton(
        child: image,
        onPressed: () {
          if (widget.withPreviewOverlay) {
            this._overlayEntry = this._createOverlayEntry();
            Overlay.of(context).insert(this._overlayEntry);
          }
          if (widget.onTap is Function) {
            widget.onTap();
          }
        },
      ),
    );
  }

  void _isBase64Image() {
    if (widget.imageSource != null) {
      isBase64Image = widget.imageSource.indexOf('data:image') == 0;
    }
  }

  void _getImageBaseUrl() async {
    if (!isBase64Image && widget.isLocal && db != null) {
      String newImageBaseUrl = await getDocumentsPath();
      setState(() {
        imageBaseUrl = newImageBaseUrl;
      });
    }
  }

  OverlayEntry _createOverlayEntry() {
    ResizableImage image = ResizableImage(
      width: 300,
      height: 300,
      imageSource: widget.imageSource,
      updatedAt: widget.updatedAt,
      isLocal: widget.isLocal,
    );

    return OverlayEntry(
        builder: (context) => Material(
          color: Color.fromRGBO(255, 255, 255, 0.6),
          elevation: 4.0,
          child: FlatButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Draggable(
                  maxSimultaneousDrags: 1,
                  axis: Axis.vertical,
                  child: image,
                  feedback: image,
                  childWhenDragging: Container(),
                  onDragEnd: (drag) {
                    if (drag.offset.dy > 300 || drag.offset.dy < -10) {
                      this._overlayEntry.remove();
                      if (widget.onPreviewClose is Function) {
                        widget.onPreviewClose();
                      }
                    }
                  },
                )
              ],
            ),
            onPressed: () {
              this._overlayEntry.remove();
              if (widget.onPreviewClose is Function) {
                widget.onPreviewClose();
              }
            },
          ),
        ),
    );
  }
}
