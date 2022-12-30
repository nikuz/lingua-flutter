import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/widgets/prompt/prompt.dart';
import 'package:lingua_flutter/screens/search/bloc/search_cubit.dart';
import 'package:lingua_flutter/screens/router.gr.dart';

import '../../bloc/translation_view_cubit.dart';
import '../change_translation/change_translation.dart';

class Menu {
  final String? id;
  final String? title;

  const Menu({this.id, this.title});
}

List<Widget> translationViewMenuConstructor({
  required BuildContext context,
  required bool isNewWord,
  required bool isDisabled,
  required bool hasInternetConnection,
}) {
  final translationViewCubit = context.read<TranslationViewCubit>();

  return [
    PopupMenuButton<Menu>(
      enabled: !isDisabled,
      icon: const Icon(Icons.more_vert),
      onSelected: (Menu item) async {
        final state = translationViewCubit.state;
        final word = state.word;
        final imageSearchWord = state.imageSearchWord;
        final translationId = state.translation?.id;

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

        if (item.id == 'translation' && state.translation?.translation != null) {
          TranslationViewChangeTranslationModal(
            context: context,
            word: state.translation!.translation,
          ).show();
        }
      },

      itemBuilder: (BuildContext context) {
        List<Menu> menuList = <Menu>[
          const Menu(id: 'translation', title: 'Change Translation'),
        ];

        if (hasInternetConnection) {
          menuList.insert(0, const Menu(id: 'image', title: 'Change Image'));
        }

        if (!isNewWord) {
          menuList.add(const Menu(id: 'remove', title: 'Remove'));
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