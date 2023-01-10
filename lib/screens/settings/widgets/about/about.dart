import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:lingua_flutter/screens/router.dart';
import 'package:lingua_flutter/widgets/typography/typography.dart';
import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/app_config.dart' as config;

import '../../bloc/settings_cubit.dart';
import '../../bloc/settings_state.dart';
import '../category/category.dart';
import '../row/row.dart';

class SettingsAbout extends StatelessWidget {
  const SettingsAbout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final MyTheme theme = Styles.theme(context);

        return Column(
          children: [
            SettingsCategory(
              title: 'About',
              children: [
                SettingsRow(
                  title: 'Rate us',
                  type: SettingsRowType.link,
                  onPressed: () async {
                    final InAppReview inAppReview = InAppReview.instance;

                    if (await inAppReview.isAvailable()) {
                      inAppReview.requestReview();
                    }
                  },
                  child: Row(
                    children: [
                      for (var i = 0, l = 5; i < l; i++)
                        const Icon(
                          Icons.star,
                          size: 20,
                        ),
                    ],
                  ),
                ),
                SettingsRow(
                  title: 'Send a feedback',
                  type: SettingsRowType.link,
                  onPressed: () {
                    launchUrl(Uri.parse('mailto:${config.privacyEmail}'));
                  },
                  child: const Icon(
                    Icons.email,
                    size: 20,
                  ),
                ),
                SettingsRow(
                  title: 'Share the App',
                  type: SettingsRowType.link,
                  onPressed: () {
                    Share.share(Platform.isAndroid ? config.playMarketUrl : config.appStoreUrl);
                  },
                  child: const Icon(
                    Icons.ios_share,
                    size: 20,
                  ),
                ),
                SettingsRow(
                  title: 'Terms & Conditions',
                  type: SettingsRowType.link,
                  onPressed: () {
                    AutoRouter.of(context).pushNamed(Routes.terms);
                  },
                  child: const Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 20,
                  ),
                ),
                SettingsRow(
                  title: 'Privacy Policy',
                  type: SettingsRowType.link,
                  onPressed: () {
                    launchUrl(Uri.parse(config.privacyPolicyUrl));
                  },
                  child: const Icon(
                    Icons.open_in_new_rounded,
                    size: 20,
                  ),
                ),
              ],
            ),
            TypographyText(
              text: 'Version: ${config.version}',
              margin: const EdgeInsets.only(top: 5, bottom: 15),
              style: TextStyle(
                color: theme.colors.grey,
              ),
            ),
          ],
        );
      },
    );
  }
}
