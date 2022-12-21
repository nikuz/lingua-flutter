import 'package:flutter/material.dart';
import 'package:lingua_flutter/widgets/typography/typography.dart';
import 'package:lingua_flutter/widgets/link/link.dart';

class Terms extends StatelessWidget {
  const Terms({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 15,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TypographyText('Terms & Conditions', variant: TypographyVariant.h4),
                const TypographyText('By downloading or using the app, these terms will automatically apply to you – you should make sure therefore that you read them carefully before using the app. You’re not allowed to copy or modify the app, any part of the app, or our trademarks in any way. You’re not allowed to attempt to extract the source code of the app, and you also shouldn’t try to translate the app into other languages or make derivative versions. The app itself, and all the trademarks, copyright, database rights, and other intellectual property rights related to it, still belong to Nikolay.Kuznetsov.'),
                const TypographyText('Nikolay.Kuznetsov is committed to ensuring that the app is as useful and efficient as possible. For that reason, we reserve the right to make changes to the app or to charge for its services, at any time and for any reason. We will never charge you for the app or its services without making it very clear to you exactly what you’re paying for.'),
                const TypographyText('The "My new words" app stores and processes personal data that you have provided to us, to provide my Service. It’s your responsibility to keep your phone and access to the app secure.'),
                const TypographyText('The app does use third-party services that declare their Terms and Conditions.'),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                    left: 10,
                  ),
                  child: Link(
                    text: 'Google Play Services',
                    href: Uri.parse('https://policies.google.com/terms'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                    left: 10,
                  ),
                  child: Link(
                    text: 'Firebase Crashlytics',
                    href: Uri.parse('https://firebase.google.com/terms/crashlytics'),
                  ),
                ),
                const TypographyText('You should be aware that there are certain things that Nikolay.Kuznetsov will not take responsibility for. Certain functions of the app will require the app to have an active internet connection. The connection can be Wi-Fi or provided by your mobile network provider, but Nikolay.Kuznetsov cannot take responsibility for the app not working at full functionality if you don’t have access to Wi-Fi, and you don’t have any of your data allowance left.'),
                const TypographyText('If you’re using the app outside of an area with Wi-Fi, you should remember that the terms of the agreement with your mobile network provider will still apply. As a result, you may be charged by your mobile provider for the cost of data for the duration of the connection while accessing the app, or other third-party charges. In using the app, you’re accepting responsibility for any such charges, including roaming data charges if you use the app outside of your home territory (i.e. region or country) without turning off data roaming. If you are not the bill payer for the device on which you’re using the app, please be aware that we assume that you have received permission from the bill payer for using the app.'),
                const TypographyText('With respect to Nikolay.Kuznetsov’s responsibility for your use of the app, when you’re using the app, it’s important to bear in mind that although we endeavor to ensure that it is updated and correct at all times, we do rely on third parties to provide information to us so that we can make it available to you. Nikolay.Kuznetsov accepts no liability for any loss, direct or indirect, you experience as a result of relying wholly on this functionality of the app.'),
                const TypographyText('At some point, we may wish to update the app. The app is currently available on Android & iOS – the requirements for the both systems (and for any additional systems we decide to extend the availability of the app to) may change, and you’ll need to download the updates if you want to keep using the app. Nikolay.Kuznetsov does not promise that it will always update the app so that it is relevant to you and/or works with the Android & iOS version that you have installed on your device. However, you promise to always accept updates to the application when offered to you, We may also wish to stop providing the app, and may terminate use of it at any time without giving notice of termination to you. Unless we tell you otherwise, upon any termination, (a) the rights and licenses granted to you in these terms will end; (b) you must stop using the app, and (if needed) delete it from your device.'),
                const TypographyText('Changes to This Terms and Conditions', variant: TypographyVariant.h4),
                const TypographyText('I may update our Terms and Conditions from time to time. Thus, you are advised to review this page periodically for any changes. I will notify you of any changes by posting the new Terms and Conditions on this page.'),
                const TypographyText('These terms and conditions are effective as of 2022-12-21'),
                const TypographyText('Contact Us', variant: TypographyVariant.h4),
                const TypographyText('If you have any questions or suggestions about my Terms and Conditions, do not hesitate to contact me at'),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: Link(
                    text: 'micurino@gmail.com',
                    href: Uri(
                      scheme: 'mailto',
                      path: 'micurino@gmail.com',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
