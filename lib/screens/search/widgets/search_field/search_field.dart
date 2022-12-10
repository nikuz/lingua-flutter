import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/widgets/text_field/text_field.dart';
import 'package:lingua_flutter/screens/router.gr.dart';

import '../../bloc/search_cubit.dart';
import '../../bloc/search_state.dart';

class SearchField extends StatefulWidget {
  final bool hasInternetConnection;

  const SearchField({
    Key? key,
    required this.hasInternetConnection,
  }) : super(key: key);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController _textController;
  late SearchCubit _searchCubit;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _searchCubit = context.read<SearchCubit>();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitHandler(String text, SearchState state) async {
    if (widget.hasInternetConnection && text != '') {
      final result = await AutoRouter.of(context).push<Translation>(TranslationViewRoute(word: text));
      if (result != null) {
        if (state.translations.any((item) => item.id == result.id)) {
          _searchCubit.updateTranslation(result);
        } else {
          _textController.clear();
          _searchCubit.fetchTranslations(searchText: null);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        return CustomTextField(
          controller: _textController,
          textInputAction: widget.hasInternetConnection ? TextInputAction.search : TextInputAction.done,
          hintText: 'Search...',
          onChanged: (text) {
            _searchCubit.fetchTranslations(searchText: text.isNotEmpty ? text : null);
          },
          onSubmitted: (String text) {
            _submitHandler(text, state);
          },
        );
      },
    );
  }
}
