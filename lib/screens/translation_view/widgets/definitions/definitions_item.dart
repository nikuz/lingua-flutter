import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jmespath/jmespath.dart' as jmespath;

import '../../bloc/translation_view_cubit.dart';
import '../../bloc/translation_view_state.dart';
import './definitions_item_synonyms.dart';

class DefinitionsItem extends StatelessWidget {
  final List<dynamic> data;
  final int index;

  const DefinitionsItem({
    Key? key,
    required this.data,
    required this.index,
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

        String? text = jmespath.search(schema.translation.definitions.items.text.value, data);
        String? example = jmespath.search(schema.translation.definitions.items.example.value, data);
        List<dynamic>? synonyms = jmespath.search(schema.translation.definitions.items.synonyms.value, data);

        return Container(
          margin: const EdgeInsets.only(
            top: 5,
            bottom: 5,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(
                  top: 3,
                  right: 20,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).textTheme.headline2!.color!,
                      width: 1,
                      style: BorderStyle.solid
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                child: Center(
                  child: Text(
                    index.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (text != null)
                      Text(
                        text,
                        style: const TextStyle(fontSize: 17),
                      ),

                    if (example != null)
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        child: Text(
                          example,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.headline1!.color,
                            fontSize: 15,
                          ),
                        ),
                      ),

                    if (synonyms != null)
                      Container(
                        margin: const EdgeInsets.only(
                          top: 15,
                          bottom: 10,
                        ),
                        child: Text(
                          'Synonyms',
                          style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontSize: 15,
                          ),
                        ),
                      ),

                    if (synonyms != null)
                      for (var item in synonyms)
                        DefinitionsItemSynonyms(data: item),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
