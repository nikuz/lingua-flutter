import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/widgets/prompt/prompt.dart';
import 'package:lingua_flutter/widgets/sharing/sharing.dart';
import 'package:lingua_flutter/screens/search/bloc/search_cubit.dart';
import 'package:lingua_flutter/screens/router.gr.dart';

import '../../bloc/translation_view_cubit.dart';
import '../change_translation/change_translation.dart';

class Menu {
  final String id;
  final String title;
  final IconData? icon;

  const Menu({
    required this.id,
    required this.title,
    this.icon,
  });
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

        switch (item.id) {
          case 'remove':
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
            break;

          case 'image':
            if (imageSearchWord != null) {
              AutoRouter.of(context).push(TranslationViewImagePickerRoute(word: imageSearchWord));
            }
            break;

          case 'translation':
            if (state.translation?.translation != null) {
              TranslationViewChangeTranslationModal(
                context: context,
                word: state.translation!.translation,
              ).show();
            }
            break;

          case 'share':
            if (state.translation != null) {
              Sharing(
                context: context,
                translation: state.translation!,
              ).share();
            }
            break;
        }
      },

      itemBuilder: (BuildContext context) {
        List<Menu> menuList = <Menu>[
          const Menu(
            id: 'translation',
            icon: Icons.translate,
            title: 'Change Translation',
          ),
        ];

        if (hasInternetConnection) {
          menuList.insert(0, const Menu(
            id: 'image',
            title: 'Change Image',
            icon: Icons.image,
          ));
        }

        menuList.add(const Menu(
          id: 'share',
          title: 'Share',
          icon: Icons.ios_share,
        ));

        if (!isNewWord) {
          menuList.add(const Menu(
            id: 'remove',
            title: 'Remove',
            icon: Icons.delete_forever,
          ));
        }

        return menuList.map((Menu item) => (
          PopupMenuItem<Menu>(
            value: item,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              minLeadingWidth: 20,
              leading: Icon(item.icon),
              title: Text(item.title),
            ),
          )
        )).toList();
      },
    ),
  ];
}