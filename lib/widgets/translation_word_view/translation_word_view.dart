import 'package:flutter/material.dart';
import 'package:lingua_flutter/models/translation_container/translation_container.dart';

class TranslationWordView extends StatelessWidget {
  final TranslationContainer translation;
  final TextStyle? textStyle;

  const TranslationWordView({
    Key? key,
    required this.translation,
    this.textStyle,
  }) : super(key: key);

  Widget _buildSentence(TranslationSentence sentence, bool isLast) {
    return Text(
      '${sentence.word}${isLast ? '' : ' '}',
      overflow: TextOverflow.ellipsis,
      maxLines: 5,
      style: textStyle,
    );
  }

  Widget _buildTranslationItem(Translation item) {
    return Wrap(
      children: [
        if (item.word != null)
          Text(
            item.word!,
            style: textStyle,
          ),

        if (item.gender != null)
          Text(
            item.gender!,
            style: textStyle,
          ),

        if (item.sentences != null)
          for (var i = 0, l = item.sentences!.length; i < l; i++)
            _buildSentence(item.sentences![i], i == l - 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (translation.translations != null)
          for (var item in translation.translations!)
            _buildTranslationItem(item),
      ],
    );
  }
}
