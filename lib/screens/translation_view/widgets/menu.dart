import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/widgets/prompts.dart';
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
  final _translationViewCubit = context.read<TranslationViewCubit>();
  final state = _translationViewCubit.state;
  final word = state.word;
  final imageSearchWord = state.imageSearchWord;
  final translationId = state.translation?.id;

  return [
    PopupMenuButton<Menu>(
      icon: Icon(Icons.more_vert),
      enabled: !isDisabled,
      onSelected: (Menu item) async {
        if (item.id == 'remove') {
          final bool removeAccepted = await wordRemovePrompt(context, word, () {
            if (translationId != null) {
              context.read<SearchCubit>().removeTranslation(translationId);
            }
          });
          if (removeAccepted) {
            AutoRouter.of(context).pop();
          }
        }
        if (item.id == 'image' && imageSearchWord != null) {
          AutoRouter.of(context).push(TranslationViewImagePickerRoute(word: imageSearchWord));
        }
        if (item.id == 'translation' && word != null) {
          AutoRouter.of(context).push(TranslationViewOwnTranslationRoute(word: word));
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