import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/app_config.dart';
import 'package:lingua_flutter/widgets/prompts.dart';
import 'package:lingua_flutter/utils/sizes.dart';

import 'bloc/bloc.dart';
import 'bloc/state.dart';
import 'bloc/events.dart';

class SettingsHomePage extends StatefulWidget {
  @override
  _SettingsHomePageState createState() => _SettingsHomePageState();
}

class _SettingsHomePageState extends State<SettingsHomePage> {
  SettingsBloc _settingsBloc;

  @override
  void initState() {
    super.initState();
    _settingsBloc = BlocProvider.of<SettingsBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Settings'),
      ),
      body: SafeArea(
        child: BlocListener<SettingsBloc, SettingsState>(
          listener: (context, state) async {
            if (state is SettingsLoaded) {
              if (state.settings['offlineDictionaryUpdateError']) {
                await prompt(
                  context: context,
                  title: 'Error',
                  text: 'Some error occurred during dictionary download. Please try again later.',
                  callback: () {
                    _settingsBloc.add(SettingsDownloadDictionaryHideError());
                  },
                );
              }
              if (state.settings['offlineDictionaryPreUpdateSize'] != null) {
                String size = _getParsedFileSize(
                    int.parse(state.settings['offlineDictionaryPreUpdateSize'])
                );
                await prompt(
                  context: context,
                  title: 'Dictionary size',
                  text: 'Offline dictionary file size is $size. Download?',
                  withCancel: true,
                  callback: () {
                    _settingsBloc.add(SettingsDownloadDictionary());
                  },
                );
              }
            }
          },
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              if (state is SettingsLoaded) {
                Widget dictionaryUpdateRow = Container();
                Widget dictionaryClearRow = Container();

                if (!kIsWeb) {
                  final int offlineDictionaryUpdateTime = state.settings['offlineDictionaryUpdateTime'];
                  final int offlineDictionaryUpdateSize = state.settings['offlineDictionaryUpdateSize'];
                  String dictionaryUpdateTime = '';

                  if (offlineDictionaryUpdateTime != null) {
                    final DateTime lastUpdateDate = new DateTime.fromMillisecondsSinceEpoch(
                      offlineDictionaryUpdateTime
                    );
                    dictionaryUpdateTime = new DateFormat.yMMMd().add_jm().format(lastUpdateDate);
                  }

                  if (offlineDictionaryUpdateSize != null) {
                    String size = _getParsedFileSize(offlineDictionaryUpdateSize);
                    dictionaryUpdateTime = '$dictionaryUpdateTime, $size';
                  }

                  dictionaryUpdateRow = SettingsButton(
                    title: 'Update offline dictionary',
                    subtitle: dictionaryUpdateTime,
                    icon: Icons.file_download,
                    loading: state.settings['offlineDictionaryUpdateLoading'] == true,
                    action: () {
                      _settingsBloc.add(SettingsDownloadDictionaryInfo());
                    },
                  );

                  dictionaryClearRow = SettingsButton(
                    title: 'Clear offline dictionary',
                    icon: Icons.delete_forever,
                    iconColor: Colors.red,
                    loading: state.settings['offlineDictionaryClearLoading'] == true,
                    action: () {
                      _settingsBloc.add(SettingsClearDictionary());
                    },
                    disabled: state.settings['offlineDictionaryUpdateLoading'] == true,
                  );
                }

                return Column(
                  children: <Widget>[
                    SettingsCheckbox(
                      id: 'pronunciationAutoPlay',
                      title: 'Autoplay pronunciation',
                      value: state.settings['pronunciationAutoPlay'],
                    ),
                    dictionaryUpdateRow,
                    dictionaryClearRow,
                  ],
                );
              }

              return Container();
            },
          ),
        ),
      ),
    );
  }

  String _getParsedFileSize(int fileSize) {
    String sizeSuffix = 'Mb';
    double size = fileSize / 1e+6;
    if (fileSize > 1e+9) {
      sizeSuffix = 'Gb';
      size = fileSize / 1e+9;
    }

    return '${size.toStringAsFixed(2)} $sizeSuffix';
  }
}

class SettingsCheckbox extends StatelessWidget {
  final String id;
  final String title;
  final bool value;

  SettingsCheckbox({
    @required this.id,
    @required this.title,
    @required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.only(
            top: SizeUtil.vmax(20),
            right: SizeUtil.vmax(15),
            bottom: SizeUtil.vmax(20),
            left: SizeUtil.vmax(15),
          ),
          child: Text(
            title,
            style: TextStyle(fontSize: SizeUtil.vmax(17))
          ),
        ),
        Container(
          width: SizeUtil.vmax(70),
          height: SizeUtil.vmax(30),
          padding: EdgeInsets.only(right: SizeUtil.vmax(5)),
          child: Switch(
            value: value,
            onChanged: (value) {
              BlocProvider.of<SettingsBloc>(context).add(
                SettingsChange(
                  type: 'bool',
                  id: id,
                  value: value
                )
              );
            },
          ),
        ),
      ],
    );
  }
}

class SettingsButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function action;
  final String subtitle;
  final bool loading;
  final Color iconColor;
  final bool disabled;

  SettingsButton({
    @required this.title,
    @required this.icon,
    @required this.action,
    this.subtitle,
    this.loading,
    this.iconColor,
    this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    Widget subtitleWidget = Container();

    if (subtitle != null) {
      subtitleWidget = Text(
        subtitle,
        style: TextStyle(
          fontSize: SizeUtil.vmax(12),
          color: Colors.grey,
        )
      );
    }

    Widget iconWidget = Icon(
      icon,
      size: SizeUtil.vmax(30),
      color: disabled == true ? Colors.grey : iconColor ?? Colors.green,
    );

    if (loading == true) {
      iconWidget = SizedBox(
        width: SizeUtil.vmax(25),
        height: SizeUtil.vmax(25),
        child: CircularProgressIndicator(
          strokeWidth: SizeUtil.vmax(1.5),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.only(
            top: SizeUtil.vmax(20),
            right: SizeUtil.vmax(15),
            bottom: SizeUtil.vmax(20),
            left: SizeUtil.vmax(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(fontSize: SizeUtil.vmax(17))
              ),
              subtitleWidget,
            ],
          ),
        ),
        Container(
          width: SizeUtil.vmax(75),
          child: FlatButton(
            child: iconWidget,
            onPressed: (disabled == true || loading == true) ? () => {} : action,
          ),
        ),
      ],
    );
  }
}
