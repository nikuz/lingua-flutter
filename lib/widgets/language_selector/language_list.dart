import 'package:flutter/material.dart';
import 'package:lingua_flutter/models/language/language.dart';
import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/widgets/bottom_drawer/bottom_drawer.dart';
import 'package:lingua_flutter/widgets/text_field/text_field.dart';
import 'package:lingua_flutter/widgets/button/button.dart';

class LanguageList extends StatefulWidget {
  final String title;
  final Language? language;
  final ScrollController scrollController;
  final Map<String, String>? languages;
  final Function(Language) onSelected;

  const LanguageList({
    super.key,
    required this.title,
    this.language,
    required this.scrollController,
    required this.languages,
    required this.onSelected,
  });

  @override
  State<LanguageList> createState() => _LanguageListState();
}

class _LanguageListState extends State<LanguageList> {
  BottomDrawerInheritedState? bottomDrawerState;
  late Map<String, String>? _filteredLanguages;
  late FocusNode _focusNode;
  bool fullyVisible = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.requestFocus();
    _filteredLanguages = widget.languages;
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bottomDrawerState = BottomDrawerInheritedState.of(context);
    bottomDrawerState?.subscribeToDrag('language_selector_list', _onDragScroll);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    bottomDrawerState?.unsubscribeFromDrag('language_selector_list');
    super.dispose();
  }

  void _onDragScroll(DraggableScrollableNotification notification) {
    if (notification.extent == notification.maxExtent) {
      if (_focusNode.hasFocus) {
        _focusNode.unfocus();
      }
      if (!fullyVisible) {
        fullyVisible = true;
      }
    }
  }

  void _onScroll() {
    if (fullyVisible && _focusNode.hasFocus) {
      _focusNode.unfocus();
    }
  }

  void _filterLanguages(String value) {
    if (widget.languages != null) {
      final Map<String, String> filteredLanguages = {};
      for (var id in widget.languages!.keys) {
        final itemValue = widget.languages![id];
        if (itemValue != null && itemValue.toLowerCase().contains(value.toLowerCase())) {
          filteredLanguages[id] = itemValue;
        }
      }
      setState(() {
        _filteredLanguages = filteredLanguages;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);

    return Material(
      color: theme.colors.background,
      child: CustomScrollView(
        controller: widget.scrollController,
        slivers: [
          if (widget.title != '')
            SliverAppBar(
              automaticallyImplyLeading: false,
              elevation: 1,
              forceElevated: true,
              pinned: true,
              backgroundColor: theme.colors.cardBackground,
              titleTextStyle: TextStyle(
                color: theme.colors.primary,
                fontSize: 20,
              ),
              titleSpacing: 0,
              title: Container(
                padding: const EdgeInsets.only(left: 10, right: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.title),

                    Button(
                      width: 40,
                      height: 40,
                      outlined: false,
                      shape: ButtonShape.oval,
                      icon: Icons.close,
                      onPressed: () {
                        BottomDrawer.dismiss(context);
                      },
                    ),
                  ],
                ),
              ),
            ),

          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                CustomTextField(
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.search,
                  hintText: 'Search language',
                  prefixIcon: Icons.search,
                  border: Border(
                    bottom: BorderSide(color: theme.colors.divider),
                  ),
                  maxLength: 50,
                  onChanged: (value) {
                    _filterLanguages(value);
                  },
                ),

                if (_filteredLanguages?.isEmpty == true)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Text(
                      'No language found',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Styles.colors.grey,
                      ),
                    ),
                  ),

                if (_filteredLanguages?.isNotEmpty == true)
                  for (var id in _filteredLanguages!.keys)
                    ListTile(
                      title: Text(_filteredLanguages![id] ?? ''),
                      trailing: id == widget.language?.id ? const Icon(Icons.check) : null,
                      onTap: () {
                        String? value = _filteredLanguages![id];
                        if (value != null) {
                          widget.onSelected(Language(id: id, value: value));
                        }
                      },
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}