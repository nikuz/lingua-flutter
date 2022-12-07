import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/styles/styles.dart';

import './bloc/search_cubit.dart';
import './widgets/search_field.dart';
import './widgets/search_list/search_list.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'My Dictionary',
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
            children: const [
              SearchField(),
              Expanded(
                child: SearchList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
