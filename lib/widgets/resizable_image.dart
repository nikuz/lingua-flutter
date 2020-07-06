import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lingua_flutter/helpers/api.dart';
import 'package:lingua_flutter/helpers/db.dart';
import 'package:lingua_flutter/utils/convert.dart';
import 'package:lingua_flutter/utils/files.dart';

class ResizableImage extends StatefulWidget {
  final double width;
  final double height;
  final String imageSource;
  final String updatedAt;
  final bool isLocal;

  ResizableImage({
    @required this.width,
    @required this.height,
    @required this.imageSource,
    @required this.updatedAt,
    this.isLocal,
  });

  @override
  _ResizableImageState createState() => _ResizableImageState();
}

class _ResizableImageState extends State<ResizableImage> {
  String imageBaseUrl;
  bool isBase64Image = false;

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

    return Container(
      width: widget.width,
      height: widget.height,
      child: image,
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
}
