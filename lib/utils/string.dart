
bool isCyrillicWord(String word) {
  final reg = RegExp(r'[а-яА-Я]');
  return word.indexOf(reg) != -1;
}
