import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/styles/styles.dart';

import '../../bloc/search_cubit.dart';
import '../../bloc/search_state.dart';
import '../../search_constants.dart';

class SearchListBottomLoader extends StatelessWidget {
  const SearchListBottomLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);

    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        final int listLength = state.translations.length;
        if (listLength >= SearchConstants.itemsPerPage && listLength < state.totalAmount) {
          return Padding(
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
            child: Center(
              child: SizedBox(
                width: 33,
                height: 33,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: theme.colors.focus,
                ),
              ),
            ),
          );
        }

        return Container();
      }
    );
  }
}
