import 'package:flutter/material.dart';
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/widgets/text_field/text_field.dart';

class LanguageList extends StatefulWidget {
  final Language? language;
  final ScrollController scrollController;
  final Map<String, String>? languages;
  final Function(Language) onSelected;

  const LanguageList({
    Key? key,
    this.language,
    required this.scrollController,
    required this.languages,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<LanguageList> createState() => _LanguageListState();
}

class _LanguageListState extends State<LanguageList> {
  late Map<String, String>? _filteredLanguages;

  @override
  void initState() {
    super.initState();
    _filteredLanguages = widget.languages;
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
    return Material(
      child: ListView(
        controller: widget.scrollController,
        children: [
          CustomTextField(
            textInputAction: TextInputAction.search,
            hintText: 'Search language',
            autofocus: true,
            underLined: true,
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
    );
  }
}