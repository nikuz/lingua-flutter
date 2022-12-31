import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/widgets/prompt/prompt.dart';
import 'package:lingua_flutter/widgets/pronunciation/pronunciation.dart';
import 'package:lingua_flutter/widgets/image_preview/image_preview.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/screens/settings/bloc/settings_cubit.dart';
import 'package:lingua_flutter/screens/settings/bloc/settings_state.dart';

import '../../bloc/search_cubit.dart';
import '../../bloc/search_state.dart';
import '../../search_state.dart';

class SearchListItem extends StatefulWidget {
  final TranslationContainer translationItem;
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
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        return BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            final MyTheme theme = Styles.theme(context);
            Color borderColor = Colors.transparent;
            final showLanguageSource = settingsState.showLanguageSource;
            final searchState = SearchInheritedState.of(context);
            String? pronunciationSource;

            if (settingsState.pronunciation == 'from') {
              pronunciationSource = widget.translationItem.pronunciationFrom;
            } else if (settingsState.pronunciation == 'to') {
              pronunciationSource = widget.translationItem.pronunciationTo;
            }

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
                  color: _isSelected ? Styles.colors.grey.withOpacity(0.3) : theme.colors.background,
                  child: InkWell(
                    onTap: () {
                      searchState?.submitHandler(
                        widget.translationItem.word,
                        translateFrom: widget.translationItem.translateFrom,
                        translateTo: widget.translationItem.translateTo,
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: showLanguageSource ? 10 : 5,
                        horizontal: 15,
                      ),
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: ImagePreview(
                              width: 50,
                              height: 50,
                              imageSource: widget.translationItem.image,
                              shape: ImagePreviewShape.oval,
                              onTap: () {
                                if (widget.translationItem.image != null) {
                                  setState(() {
                                    _isSelected = true;
                                  });
                                }
                              },
                              onPreviewClose: () {
                                if (widget.translationItem.image != null) {
                                  setState(() {
                                    _isSelected = false;
                                  });
                                }
                              },
                            ),
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    widget.translationItem.word,
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),

                                Container(
                                  margin: const EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    widget.translationItem.translation,
                                    maxLines: showLanguageSource ? 1 : 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: theme.colors.primary.withOpacity(0.5),
                                    ),
                                  ),
                                ),

                                if (showLanguageSource)
                                  Text(
                                    '${widget.translationItem.translateFrom.value} - ${widget.translationItem.translateTo.value}',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: PronunciationWidget(
                              pronunciationSource: pronunciationSource,
                              size: 50,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}