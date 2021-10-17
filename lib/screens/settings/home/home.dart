import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SafeArea(
        child: BlocListener<SettingsBloc, SettingsState>(
          listener: (context, state) async {
            if (state is SettingsLoaded) {
              if (state.settings['offlineDictionaryUpdateError']) {
                void clearDictionaryUpdateError() => (
                  _settingsBloc.add(SettingsChange(
                    type: 'bool',
                    id: 'offlineDictionaryUpdateError',
                    value: false,
                    savePrefs: false,
                  ))
                );
                await prompt(
                  context: context,
                  title: 'Error',
                  text: 'Some error occurred during dictionary download. Please try again later.',
                  acceptCallback: () => clearDictionaryUpdateError(),
                  closeCallback: () => clearDictionaryUpdateError(),
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
                  acceptCallback: () {
                    _settingsBloc.add(SettingsDownloadDictionary());
                  },
                  closeCallback: () {
                    _settingsBloc.add(SettingsChange(
                      type: 'int',
                      id: 'offlineDictionaryPreUpdateSize',
                      value: null,
                      savePrefs: false,
                    ));
                  },
                );
              }
              if (state.settings['offlineDictionaryClearConfirmation']) {
                await prompt(
                  context: context,
                  title: 'Clear confirmation',
                  text: 'Are you sure you wish to clean the offline dictionary?',
                  withCancel: true,
                  acceptCallback: () {
                    _settingsBloc.add(SettingsClearDictionary());
                  },
                  closeCallback: () {
                    _settingsBloc.add(SettingsChange(
                      type: 'bool',
                      id: 'offlineDictionaryClearConfirmation',
                      value: false,
                      savePrefs: false,
                    ));
                  },
                );
              }
            }
          },
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              if (state is SettingsLoaded) {
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

                Widget dictionaryUpdateRow = SettingsButton(
                  title: 'Offline dictionary',
                  subtitle: dictionaryUpdateTime,
                  icon: Icons.file_download,
                  loading: state.settings['offlineDictionaryUpdateLoading'] == true,
                  action: () {
                    _settingsBloc.add(SettingsDownloadDictionaryInfo());
                  },
                  secondButtonIcon: Icons.delete_forever,
                  secondButtonIconColor: Colors.red,
                  secondButtonAction: () {
                    _settingsBloc.add(SettingsChange(
                      type: 'bool',
                      id: 'offlineDictionaryClearConfirmation',
                      value: true,
                      savePrefs: false,
                    ));
                  },
                  secondButtonLoading: state.settings['offlineDictionaryClearLoading'] == true,
                  secondButtonDisabled: (
                      state.settings['offlineDictionaryUpdateLoading'] == true
                          || offlineDictionaryUpdateSize == null
                  ),
                );

                return Column(
                  children: <Widget>[
                    SettingsCheckbox(
                      id: 'pronunciationAutoPlay',
                      title: 'Autoplay pronunciation',
                      value: state.settings['pronunciationAutoPlay'],
                    ),
                    SettingsCheckbox(
                      id: 'darkModeEnabled',
                      title: 'Dark mode',
                      value: state.settings['darkModeEnabled'],
                    ),
                    dictionaryUpdateRow,
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
  final Function onChange;

  SettingsCheckbox({
    @required this.id,
    @required this.title,
    @required this.value,
    this.onChange,
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
          padding: EdgeInsets.only(right: SizeUtil.vmax(5)),
          child: Switch(
            value: value,
            onChanged: (changeValue) {
              BlocProvider.of<SettingsBloc>(context).add(
                SettingsChange(
                  type: 'bool',
                  id: id,
                  value: changeValue,
                  savePrefs: true,
                )
              );
              if (onChange is Function) {
                onChange(changeValue);
              }
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
  final IconData secondButtonIcon;
  final Color secondButtonIconColor;
  final Function secondButtonAction;
  final bool secondButtonLoading;
  final bool secondButtonDisabled;

  SettingsButton({
    @required this.title,
    @required this.icon,
    @required this.action,
    this.subtitle,
    this.loading,
    this.iconColor,
    this.disabled,
    this.secondButtonIcon,
    this.secondButtonIconColor,
    this.secondButtonAction,
    this.secondButtonLoading,
    this.secondButtonDisabled,
  });

  @override
  Widget build(BuildContext context) {
    Widget subtitleWidget = Container();
    Widget secondButtonWidget = Container();
    Widget loadingWidget = SizedBox(
      width: SizeUtil.vmax(25),
      height: SizeUtil.vmax(25),
      child: CircularProgressIndicator(
        strokeWidth: SizeUtil.vmax(1.5),
      ),
    );

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
      iconWidget = loadingWidget;
    }

    if (secondButtonIcon != null) {
      Widget secondIconWidget = Icon(
        secondButtonIcon,
        size: SizeUtil.vmax(30),
        color: secondButtonDisabled == true ? Colors.grey : secondButtonIconColor ?? Colors.green,
      );
      if (secondButtonLoading) {
        secondIconWidget = loadingWidget;
      }
      secondButtonWidget = ButtonTheme(
        minWidth: 55,
        child: TextButton(
          child: secondIconWidget,
          onPressed: (secondButtonDisabled == true || secondButtonLoading == true)
              ? () => {}
              : secondButtonAction,
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
        Row(
          children: [
            ButtonTheme(
              minWidth: 55,
              child: TextButton(
                child: iconWidget,
                onPressed: (disabled == true || loading == true) ? () => {} : action,
              ),
            ),
            secondButtonWidget,
          ],
        ),
      ],
    );
  }
}
