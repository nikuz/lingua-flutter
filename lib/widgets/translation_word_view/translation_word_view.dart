import 'package:flutter/material.dart';
import 'package:lingua_flutter/models/translation.dart';

class TranslationWordView extends StatelessWidget {
  final TranslationContainer translation;
  final TextStyle? textStyle;

  const TranslationWordView({
    Key? key,
    required this.translation,
    this.textStyle,
  }) : super(key: key);

  Widget _buildSentence(TranslationSentence sentence) {
    return Text(
      '${sentence.word} ',
      overflow: TextOverflow.ellipsis,
      maxLines: 5,
      style: textStyle,
    );
  }

  Widget _buildTranslationItem(Translation item) {
    return Wrap(
      children: [
        if (item.word != null)
          Text(item.word!),

        if (item.gender != null)
          Text(item.gender!),

        if (item.sentences != null)
          for (var sentence in item.sentences!)
            _buildSentence(sentence),
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
