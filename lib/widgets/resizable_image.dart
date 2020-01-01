import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lingua_flutter/helpers/api.dart';
import 'package:lingua_flutter/utils/images.dart';

class ResizableImage extends StatelessWidget {
  final double width;
  final double height;
  final String imageSource;

  ResizableImage({
    @required this.width,
    @required this.height,
    @required this.imageSource,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = Container();

    if (imageSource.indexOf('data:image') == 0) {
      image = Image.memory(getImageBytesFrom64String(imageSource));
    } else {
      image = CachedNetworkImage(
        imageUrl: '${getApiUri()}$imageSource',
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      );
    }

    return Container(
      width: width,
      height: height,
      child: image,
    );
  }
}
