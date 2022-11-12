import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/widgets/prompts.dart';
import 'package:lingua_flutter/screens/search/bloc/search_cubit.dart';
import 'package:lingua_flutter/screens/router.gr.dart';

class Menu {
  final String? id;
  final String? title;

  const Menu({this.id, this.title});
}

List<Widget> translationViewMenuConstructor({
  required BuildContext context,
  required String word,
  required int? wordId,
  required bool disabled,
  required bool hasInternetConnection,
  required String? imageSearchWord,
}) {
  return [
    PopupMenuButton<Menu>(
      icon: Icon(Icons.more_vert),
      enabled: !disabled,
      onSelected: (Menu item) async {
        if (item.id == 'remove') {
          final bool removeAccepted = await wordRemovePrompt(context, word, () {
            if (wordId != null) {
              context.read<SearchCubit>().removeTranslation(wordId);
            }
          });
          if (removeAccepted) {
            Navigator.pop(context, false);
          }
        }
        if (item.id == 'image') {
          AutoRouter.of(context).push(TranslationViewImagePickerRoute(word: imageSearchWord));
        }
        if (item.id == 'translation') {
          AutoRouter.of(context).push(TranslationViewOwnTranslationRoute(word: word));
        }
      },
      itemBuilder: (BuildContext context) {
        if (disabled) {
          return [];
        }

        List<Menu> menuList = <Menu>[
          const Menu(id: 'translation', title: 'Change Translation'),
          const Menu(id: 'remove', title: 'Remove'),
        ];

        if (hasInternetConnection) {
          menuList.insert(0, const Menu(id: 'image', title: 'Change Image'));
        }

        return menuList.map((Menu item) {
          return PopupMenuItem<Menu>(
            value: item,
            child: Text(item.title!),
          );
        }).toList();
      },
    ),
  ];
}