import 'dart:async';
import 'package:flutter/material.dart';
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
    return Container(
      width: width,
      height: height,
      child: FutureBuilder<Widget>(
        future: _getBuilder(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data;
          } else {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
            );
          }
        },
      ),
    );
  }

  Future<Widget> _getBuilder() async {
      final Completer<Widget> completer = Completer();

      NetworkImage networkImage = NetworkImage('${getApiUri()}$imageSource');
      NetworkImage networkImageConfig = await networkImage.obtainKey(const ImageConfiguration());

      ImageStreamCompleter load;

      MemoryImage memoryImage;
      MemoryImage memoryImageConfig;
      if (imageSource.indexOf('data:image') == 0) {
        memoryImage = MemoryImage(getImageBytesFrom64String(imageSource));
        memoryImageConfig = await memoryImage.obtainKey(const ImageConfiguration());
        load = memoryImage.load(memoryImageConfig);
      } else {
        load = networkImage.load(networkImageConfig);
      }

      final listener = new ImageStreamListener((ImageInfo info, isSync) {
        completer.complete(Container(child: Image(image: memoryImage ?? networkImage)));
      });

      load.addListener(listener);

      return completer.future;
  }
}
