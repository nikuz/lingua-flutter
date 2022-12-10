import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/screens/settings/bloc/settings_cubit.dart';

import '../../bloc/search_cubit.dart';
import '../../bloc/search_state.dart';
import './constants.dart';

class QuickSearch extends StatefulWidget {
  final String searchText;

  const QuickSearch({
    Key? key,
    required this.searchText,
  }) : super(key: key);

  @override
  State<QuickSearch> createState() => _QuickSearchState();
}

class _QuickSearchState extends State<QuickSearch> {
  late SearchCubit _searchCubit;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchCubit = context.read<SearchCubit>();
    _debounceRequest();
  }

  @override
  void didUpdateWidget(covariant QuickSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchText != widget.searchText) {
      _debounceRequest();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCubit.clearQuickTranslate();
    super.dispose();
  }

  void _debounceRequest() {
    if (_debounce?.isActive == true) {
      _debounce!.cancel();
    }
    _debounce = Timer(QuickSearchConstants.debouncePeriod, () {
      final settingsState = context.read<SettingsCubit>().state;
      _searchCubit.quickTranslate(
        word: widget.searchText,
        translateFrom: settingsState.translateFrom,
        translateTo: settingsState.translateTo,
      );
    });
  }

  Widget _buildContentBody(SearchState state) {
    if (state.quickTranslationError?.message != null) {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Text(state.quickTranslationError!.message),
        ),
      );
    }

    if (state.quickTranslation?.translation != null) {
      return ListTile(
        title: Text(
          state.quickTranslation!.translation!,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        trailing: ElevatedButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(56, 56),
            padding: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(36),
              ),
            ),
          ),
          child: const Icon(Icons.arrow_forward),
          onPressed: () {

          },
        ),
      );
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                constraints: const BoxConstraints(
                  minHeight: 75,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildContentBody(state),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
