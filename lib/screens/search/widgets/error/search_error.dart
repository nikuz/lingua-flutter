import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/widgets/typography/typography.dart';
import 'package:lingua_flutter/widgets/link/link.dart';
import 'package:lingua_flutter/app_config.dart' as config;
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
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
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
                  text: 'Cannot retrieve data from local database. We are probably already aware of the issue, however do not hesitate contacting us using an email below.',
                  variant: TypographyVariant.h6,
                  align: TextAlign.center,
                ),

                Link(
                  text: config.privacyEmail,
                  href: Uri(
                    scheme: 'mailto',
                    path: config.privacyEmail,
                  ),
                )
              ],
            ),
          );
        }

        return Center(
          child: Text(state.error!.message),
        );
      }
    );
  }
}