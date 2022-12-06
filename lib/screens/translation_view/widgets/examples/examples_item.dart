import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:jmespath/jmespath.dart' as jmespath;

import '../../bloc/translation_view_cubit.dart';
import '../../bloc/translation_view_state.dart';

class ExamplesItem extends StatelessWidget {
  final List<dynamic> data;

  const ExamplesItem({
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

        String? text = jmespath.search(schema.translation.examples.text.value, data);

        if (text == null) {
          return Container();
        }

        return Container(
          margin: const EdgeInsets.only(top: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(
                Icons.format_quote,
                size: 20,
                color: Color.fromRGBO(119, 119, 119, 1),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: Html(
                    data: text,
                    style: {
                      "*": Style(fontSize: FontSize(16)),
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
