String getElapsedTime(DateTime eventTime) {
  const minute = 60;
  const hour = minute * 60;
  const day = hour * 24;
  final now = DateTime.now().millisecondsSinceEpoch;
  final difference = (now - eventTime.millisecondsSinceEpoch) / 1000;
  double? value;
  String? entity;

  if (difference < minute) {
    return 'Just now';
  } else if (difference >= minute && difference < hour) {
    value = difference / minute;
    entity = 'minute';
  } else if (difference >= hour && difference < day) {
    value = difference / hour;
    entity = 'hour';
  } else if (difference >= day) {
    value = difference / day;
    entity = 'day';
  }

  if (value == null) {
    return '';
  }

  final valueInt = value.toInt();

  return '$valueInt $entity${valueInt > 1 ? 's' : ''} ago';
}