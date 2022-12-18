import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lingua_flutter/models/translation.dart';

import '../../bloc/translation_view_cubit.dart';
import '../../bloc/translation_view_state.dart';

class ExamplesItem extends StatelessWidget {
  final TranslationExample item;

  const ExamplesItem({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationViewCubit, TranslationViewState>(
      builder: (context, state) {
        final translation = state.translation;

        if (translation == null) {
          return Container();
        }

        return Padding(
          padding: const EdgeInsets.only(
            top: 15,
            right: 10,
            left: 10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 5),
                child: const Icon(
                  Icons.format_quote,
                  size: 20,
                  color: Color.fromRGBO(119, 119, 119, 1),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 15),
                  child: Html(
                    data: item.text,
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
