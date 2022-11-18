import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/translation_view_cubit.dart';
import '../bloc/translation_view_state.dart';

class TranslationViewAutoSpellingFix extends StatelessWidget {
  TranslationViewAutoSpellingFix({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationViewCubit, TranslationViewState>(
      builder: (context, state) {
        if (state.autoSpellingFix == null) {
          return Container();
        }

        return Container(
          padding: EdgeInsets.only(
            left: 10,
            top: 4,
            right: 10,
            bottom: 6,
          ),
          color: Colors.red,
          child: Wrap(
            direction: Axis.horizontal,
            children: <Widget>[
              Text('Original word ', style: TextStyle(color: Colors.white)),
              Text(
                '"${state.autoSpellingFix}"',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(' had a spelling mistake', style: TextStyle(color: Colors.white))
            ],
          ),
        );
      },
    );
  }
}
