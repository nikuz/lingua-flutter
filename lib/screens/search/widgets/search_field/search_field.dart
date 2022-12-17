import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/widgets/text_field/text_field.dart';

import '../../bloc/search_cubit.dart';
import '../../bloc/search_state.dart';
import '../../search_state.dart';

class SearchField extends StatelessWidget {
  const SearchField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        final searchState = SearchInheritedState.of(context);
        return CustomTextField(
          controller: searchState?.textController,
          textInputAction: searchState?.hasInternetConnection == true
              ? TextInputAction.search
              : TextInputAction.done,
          hintText: 'Search...',
          onChanged: (text) {
            context.read<SearchCubit?>()?.fetchTranslations(searchText: text.isNotEmpty ? text : null);
          },
          onSubmitted: (_) {
            if (searchState?.hasInternetConnection == true) {
              searchState?.submitHandler(searchState.textController.text);
            }
          },
        );
      },
    );
  }
}