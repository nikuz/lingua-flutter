import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/widgets/button/button.dart';
import 'package:lingua_flutter/widgets/typography/typography.dart';
import 'package:lingua_flutter/styles/styles.dart';

import '../../bloc/search_cubit.dart';
import '../../bloc/search_state.dart';

class SearchError extends StatelessWidget {
  const SearchError({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        final error = state.error;
        if (error == null) {
          return Container();
        }

        if (error.message.contains('DatabaseException')) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (MediaQuery.of(context).size.height > 500)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Icon(
                    Icons.error_outline,
                    size: 100,
                    color: Styles.colors.grey,
                  ),
                ),

              const TypographyText(
                'Local database is corrupted',
                variant: TypographyVariant.h6,
              ),
              Button(
                text: 'Clear local database',
                size: ButtonSize.large,
                margin: const EdgeInsets.only(top: 10),
                onPressed: () {
                  context.read<SearchCubit>().clearDatabase();
                },
              ),
            ],
          );
        }

        return Center(
          child: Text(state.error!.message),
        );
      }
    );
  }
}