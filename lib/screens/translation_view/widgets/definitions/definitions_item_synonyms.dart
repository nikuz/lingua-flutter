import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jmespath/jmespath.dart' as jmespath;

import '../../bloc/translation_view_cubit.dart';
import '../../bloc/translation_view_state.dart';

class DefinitionsItemSynonyms extends StatelessWidget {
  final List<dynamic> data;

  DefinitionsItemSynonyms({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationViewCubit, TranslationViewState>(
      builder: (context, state) {
        final translation = state.translation;
        final schema = translation?.schema;

        if (translation == null || schema == null) {
          return Container();
        }

        String? type = jmespath.search(schema.translation.definitions.items.synonyms.type.value, data);
        List<dynamic>? items = jmespath.search(schema.translation.definitions.items.synonyms.items.value, data);

        if (items == null) {
          return Container();
        }

        return Wrap(
          direction: Axis.horizontal,
          spacing: 7,
          runSpacing: 7,
          children: items.map((item) {
            String? text = jmespath.search(schema.translation.definitions.items.synonyms.items.text.value, item);

            return Container(
              padding: EdgeInsets.only(
                top: 3,
                right: 8,
                bottom: 5,
                left: 8,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  style: BorderStyle.solid,
                  color: Color.fromRGBO(218, 220, 224, 1),
                ),
                borderRadius: BorderRadius.all(Radius.circular(7)),
              ),
              child: Text(
                text ?? '',
                style: TextStyle(fontSize: 15),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
