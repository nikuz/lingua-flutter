import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/utils/sizes.dart';

import 'bloc/bloc.dart';
import 'bloc/state.dart';
import 'bloc/events.dart';

class SettingsHomePage extends StatefulWidget {
  @override
  _SettingsHomePageState createState() => _SettingsHomePageState();
}

class _SettingsHomePageState extends State<SettingsHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Settings'),
      ),
      body: SafeArea(
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            if (state is SettingsLoaded) {
              return Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                          top: SizeUtil.vmax(20),
                          right: SizeUtil.vmax(15),
                          bottom: SizeUtil.vmax(20),
                          left: SizeUtil.vmax(15),
                        ),
                        child: Center(
                          child: Text(
                            'Autoplay pronunciation',
                            style: TextStyle(fontSize: SizeUtil.vmax(17))
                          ),
                        ),
                      ),
                      Container(
                        width: SizeUtil.vmax(70),
                        height: SizeUtil.vmax(30),
                        padding: EdgeInsets.only(right: SizeUtil.vmax(5)),
                        child: Switch(
                          value: state.settings['pronunciationAutoPlay'],
                          onChanged: (value) {
                            BlocProvider.of<SettingsBloc>(context).add(
                              SettingsChange(
                                type: 'bool',
                                id: 'pronunciationAutoPlay',
                                value: value
                              )
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            return Container();
          },
        )
      ),
    );
  }
}
