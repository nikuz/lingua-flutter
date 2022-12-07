import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/search_cubit.dart';
import '../../bloc/search_state.dart';
import '../../search_constants.dart';

class SearchListBottomLoader extends StatelessWidget {
  const SearchListBottomLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        final int listLength = state.translations.length;
        if (listLength >= SearchConstants.itemsPerPage && listLength < state.totalAmount) {
          return const Padding(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
            child: Center(
              child: SizedBox(
                width: 33,
                height: 33,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
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
