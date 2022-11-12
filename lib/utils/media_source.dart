enum MediaSourceType {
  none,
  base64,
  local,
  network,
}

class MediaSource {
  static MediaSourceType getType(String source) {
    MediaSourceType sourceType = MediaSourceType.none;

    if (source.indexOf('data:image') == 0) {
      sourceType = MediaSourceType.base64;
    } else if (source.startsWith('http')) {
      sourceType = MediaSourceType.network;
    } else if (source != '') {
      sourceType = MediaSourceType.local;
    }

    return sourceType;
  }
}