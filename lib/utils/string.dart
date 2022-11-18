extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${this.substring(1)}';
  }

  bool isCyrillic() {
    final reg = RegExp(r'[а-яА-Я]');
    return this.indexOf(reg) != -1;
  }
}