import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/styles/styles.dart';

import 'bloc/search_cubit.dart';
import 'widgets/search_field.dart';
import 'widgets/search_translations_list.dart';

class Search extends StatefulWidget {
  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  void initState() {
    super.initState();
    context.read<SearchCubit>().fetchTranslations();
  }

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: theme.colors.background,
          ),
          child: Column(
            children: <Widget>[
              SearchField(),
              Expanded(
                child: SearchTranslationsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
