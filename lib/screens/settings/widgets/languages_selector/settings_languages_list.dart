import 'package:flutter/material.dart';
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/widgets/text_field/text_field.dart';

class SettingsLanguagesList extends StatefulWidget {
  final String language;
  final ScrollController scrollController;
  final List<Language>? languages;
  final Function(String) onSelected;

  const SettingsLanguagesList({
    Key? key,
    required this.language,
    required this.scrollController,
    required this.languages,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<SettingsLanguagesList> createState() => _SettingsLanguagesListState();
}

class _SettingsLanguagesListState extends State<SettingsLanguagesList> {
  late List<Language>? _filteredLanguages;

  @override
  void initState() {
    super.initState();
    _filteredLanguages = widget.languages;
  }

  void _filterLanguages(String value) {
    setState(() {
      _filteredLanguages = widget.languages?.where((item) => (
          item.value.toLowerCase().contains(value.toLowerCase())
      )).toList();
    });
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
            onChanged: (value) {
              _filterLanguages(value);
            },
          ),

          if (_filteredLanguages != null)
            for (var item in _filteredLanguages!)
              ListTile(
                title: Text(item.value),
                trailing: item.id == widget.language
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  widget.onSelected(item.id);
                },
              ),
        ],
      ),
    );
  }
}