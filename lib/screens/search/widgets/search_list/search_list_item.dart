import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/widgets/prompt/prompt.dart';
import 'package:lingua_flutter/widgets/pronunciation/pronunciation.dart';
import 'package:lingua_flutter/widgets/image_preview/image_preview.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/screens/router.gr.dart';

import '../../bloc/search_cubit.dart';
import '../../bloc/search_state.dart';

class SearchListItem extends StatefulWidget {
  final Translation translationItem;
  final bool withBorder;

  const SearchListItem({
    Key? key,
    required this.translationItem,
    required this.withBorder,
  }) : super(key: key);

  @override
  State<SearchListItem> createState() => _SearchListItemState();
}

class _SearchListItemState extends State<SearchListItem> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        MyTheme theme = Styles.theme(context);
        Color borderColor = Colors.transparent;

        if (widget.withBorder) {
          borderColor = theme.colors.divider;
        }

        return Dismissible(
          key: Key(widget.translationItem.word),
          background: Container(
            color: Colors.red,
            child: const Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 80,
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          confirmDismiss: (DismissDirection direction) {
            final completer = Completer<bool>();

            Prompt(
              context: context,
              title: 'Delete "${widget.translationItem.word}" word?',
              acceptCallback: () {
                if (widget.translationItem.id != null) {
                  context.read<SearchCubit>().removeTranslation(widget.translationItem.id!);
                }
              },
            ).show().then((value) {
              completer.complete(value == true);
            });

            return completer.future;
          },
          direction: DismissDirection.endToStart,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: borderColor,
                ),
              ),
            ),
            child: Material(
              color: _isSelected ? theme.colors.secondaryPale : theme.colors.background,
              child: ListTile(
                leading: ImagePreview(
                  width: 50,
                  height: 50,
                  imageSource: widget.translationItem.image,
                  onTap: () {
                    setState(() {
                      _isSelected = true;
                    });
                  },
                  onPreviewClose: () {
                    setState(() {
                      _isSelected = false;
                    });
                  },
                ),
                title: Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    widget.translationItem.word,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                subtitle: Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    widget.translationItem.translation ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                // dense: true,
                trailing: PronunciationWidget(pronunciationSource: widget.translationItem.pronunciation),
                onTap: () async {
                  final searchCubit = context.read<SearchCubit>();
                  final result = await AutoRouter.of(context).push<Translation>(
                      TranslationViewRoute(word: widget.translationItem.word)
                  );
                  if (result != null) {
                    if (state.translations.any((item) => item.id == result.id)) {
                      searchCubit.updateTranslation(result);
                    }
                  }
                },
              ),
            ),
          ),
        );
      }
    );
  }
}