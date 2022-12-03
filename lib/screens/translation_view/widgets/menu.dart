import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

import 'package:lingua_flutter/widgets/prompt/prompt.dart';
import 'package:lingua_flutter/widgets/text_field/text_field.dart';
import 'package:lingua_flutter/screens/search/bloc/search_cubit.dart';
import 'package:lingua_flutter/screens/router.gr.dart';

import '../bloc/translation_view_cubit.dart';

class Menu {
  final String? id;
  final String? title;

  const Menu({this.id, this.title});
}

List<Widget> translationViewMenuConstructor({
  required BuildContext context,
  required bool isDisabled,
  required bool hasInternetConnection,
}) {
  final translationViewCubit = context.read<TranslationViewCubit>();
  final state = translationViewCubit.state;
  final word = state.word;
  final imageSearchWord = state.imageSearchWord;
  final translationId = state.translation?.id;
  String? newTranslation = word;

  return [
    PopupMenuButton<Menu>(
      icon: Icon(Icons.more_vert),
      enabled: !isDisabled,

      onSelected: (Menu item) async {
        if (item.id == 'remove') {
          Prompt(
            context: context,
            title: 'Delete "$word" word?',
            acceptCallback: () {
              if (translationId != null) {
                context.read<SearchCubit>().removeTranslation(translationId);
              }
              AutoRouter.of(context).pop();
            },
          ).show();
        }

        if (item.id == 'image' && imageSearchWord != null) {
          AutoRouter.of(context).push(TranslationViewImagePickerRoute(word: imageSearchWord));
        }

        if (item.id == 'translation' && word != null) {
          Prompt(
            context: context,
            title: 'Custom translation for "$word"',
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: CustomTextField(
                defaultValue: word,
                autofocus: true,
                textInputAction: TextInputAction.done,
                framed: true,
                onChanged: (String value) {
                  newTranslation = value;
                },
                onSubmitted: (String value) {
                  if (newTranslation != null) {
                    translationViewCubit.setOwnTranslation(newTranslation!);
                  }
                },
              ),
            ),
            acceptCallback: () {
              if (newTranslation != null) {
                translationViewCubit.setOwnTranslation(newTranslation!);
              }
            },
          ).show();
        }
      },

      itemBuilder: (BuildContext context) {
        if (isDisabled) {
          return [];
        }

        List<Menu> menuList = <Menu>[
          const Menu(id: 'translation', title: 'Change Translation'),
          const Menu(id: 'remove', title: 'Remove'),
        ];

        if (hasInternetConnection) {
          menuList.insert(0, const Menu(id: 'image', title: 'Change Image'));
        }

        return menuList.map((Menu item) => (
          PopupMenuItem<Menu>(
            value: item,
            child: Text(item.title!),
          )
        )).toList();
      },
    ),
  ];
}