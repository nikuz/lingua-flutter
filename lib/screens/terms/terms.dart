import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/widgets/typography/typography.dart';
import 'package:lingua_flutter/widgets/link/link.dart';
import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/app_config.dart' as config;

@RoutePage()
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);
    final isInDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        backgroundColor: theme.colors.background,
        foregroundColor: theme.colors.primary,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isInDarkMode ? Brightness.light : Brightness.dark,
          statusBarBrightness: isInDarkMode ? Brightness.dark : Brightness.light,
        ),
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(fontSize: 20),
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
                const TypographyText(text: 'Last updated: December 27, 2022'),
                const TypographyText(text: 'Please read these terms and conditions carefully before using Our Service.', align: TextAlign.justify),

                const TypographyText(text: 'Interpretation and Definitions', variant: TypographyVariant.h4),

                const TypographyText(text: 'Interpretation', variant: TypographyVariant.h6),
                const TypographyText(text: 'The words of which the initial letter is capitalized have meanings defined under the following conditions. The following definitions shall have the same meaning regardless of whether they appear in singular or in plural.', align: TextAlign.justify),

                const TypographyText(text: 'Definitions', variant: TypographyVariant.h6),
                const TypographyText(text: 'For the purposes of these Terms and Conditions:', align: TextAlign.justify),
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    ListTile(
                      title: TypographyText(
                        align: TextAlign.justify,
                        children: [
                          TextSpan(text: 'Application ', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: 'means the software program provided by the Company downloaded by You on any electronic device, named Wisual'),
                        ],
                      ),
                    ),
                    ListTile(
                      title: TypographyText(
                        align: TextAlign.justify,
                        children: [
                          TextSpan(text: 'Application Store ', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: 'means the digital distribution service operated and developed by Apple Inc. (Apple App Store) or Google Inc. (Google Play Store) in which the Application has been downloaded.'),
                        ],
                      ),
                    ),
                    ListTile(
                      title: TypographyText(
                        align: TextAlign.justify,
                        children: [
                          TextSpan(text: 'Affiliate ', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: 'means an entity that controls, is controlled by or is under common control with a party, where "control" means ownership of 50% or more of the shares, equity interest or other securities entitled to vote for election of directors or other managing authority.'),
                        ],
                      ),
                    ),
                    ListTile(
                      title: TypographyText(
                        align: TextAlign.justify,
                        children: [
                          TextSpan(text: 'Country ', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: 'refers to: British Columbia, Canada'),
                        ],
                      ),
                    ),
                    ListTile(
                      title: TypographyText(
                        align: TextAlign.justify,
                        children: [
                          TextSpan(text: 'Company ', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: '(referred to as either "the Company", "We", "Us" or "Our" in this Agreement) refers to Wisual.'),
                        ],
                      ),
                    ),
                    ListTile(
                      title: TypographyText(
                        align: TextAlign.justify,
                        children: [
                          TextSpan(text: 'Device ', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: 'means any device that can access the Service such as a computer, a cellphone or a digital tablet.'),
                        ],
                      ),
                    ),
                    ListTile(
                      title: TypographyText(
                        align: TextAlign.justify,
                        children: [
                          TextSpan(text: 'Service ', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: 'refers to the Application.'),
                        ],
                      ),
                    ),
                    ListTile(
                      title: TypographyText(
                        align: TextAlign.justify,
                        children: [
                          TextSpan(text: 'Terms and Conditions ', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: '(also referred as "Terms") mean these Terms and Conditions that form the entire agreement between You and the Company regarding the use of the Service. This Terms and Conditions agreement has been created with the help of the TermsFeed Terms and Conditions Generator.'),
                        ],
                      ),
                    ),
                    ListTile(
                      title: TypographyText(
                        align: TextAlign.justify,
                        children: [
                          TextSpan(text: 'Third-party Social Media Service ', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: 'means any services or content (including data, information, products or services) provided by a third-party that may be displayed, included or made available by the Service.'),
                        ],
                      ),
                    ),
                    ListTile(
                      title: TypographyText(
                        align: TextAlign.justify,
                        children: [
                          TextSpan(text: 'You ', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: 'means the individual accessing or using the Service, or the company, or other legal entity on behalf of which such individual is accessing or using the Service, as applicable.'),
                        ],
                      ),
                    ),
                  ],
                ),

                const TypographyText(text: 'Acknowledgment', variant: TypographyVariant.h4),
                const TypographyText(text: 'These are the Terms and Conditions governing the use of this Service and the agreement that operates between You and the Company. These Terms and Conditions set out the rights and obligations of all users regarding the use of the Service.', align: TextAlign.justify),
                const TypographyText(text: 'Your access to and use of the Service is conditioned on Your acceptance of and compliance with these Terms and Conditions. These Terms and Conditions apply to all visitors, users and others who access or use the Service.', align: TextAlign.justify),
                const TypographyText(text: 'By accessing or using the Service You agree to be bound by these Terms and Conditions. If You disagree with any part of these Terms and Conditions then You may not access the Service.', align: TextAlign.justify),
                const TypographyText(text: 'You represent that you are over the age of 18. The Company does not permit those under 18 to use the Service.', align: TextAlign.justify),
                const TypographyText(text: 'Your access to and use of the Service is also conditioned on Your acceptance of and compliance with the Privacy Policy of the Company. Our Privacy Policy describes Our policies and procedures on the collection, use and disclosure of Your personal information when You use the Application or the Website and tells You about Your privacy rights and how the law protects You. Please read Our Privacy Policy carefully before using Our Service.', align: TextAlign.justify),

                const TypographyText(text: 'Links to Other Websites', variant: TypographyVariant.h4),
                const TypographyText(text: 'Our Service may contain links to third-party web sites or services that are not owned or controlled by the Company.', align: TextAlign.justify),
                const TypographyText(text: 'The Company has no control over, and assumes no responsibility for, the content, privacy policies, or practices of any third party web sites or services. You further acknowledge and agree that the Company shall not be responsible or liable, directly or indirectly, for any damage or loss caused or alleged to be caused by or in connection with the use of or reliance on any such content, goods or services available on or through any such web sites or services.', align: TextAlign.justify),
                const TypographyText(text: 'We strongly advise You to read the terms and conditions and privacy policies of any third-party web sites or services that You visit.', align: TextAlign.justify),

                const TypographyText(text: 'Termination', variant: TypographyVariant.h4),
                const TypographyText(text: 'We may terminate or suspend Your access immediately, without prior notice or liability, for any reason whatsoever, including without limitation if You breach these Terms and Conditions.', align: TextAlign.justify),
                const TypographyText(text: 'Upon termination, Your right to use the Service will cease immediately.', align: TextAlign.justify),

                const TypographyText(text: 'Limitation of Liability', variant: TypographyVariant.h4),
                const TypographyText(text: 'Notwithstanding any damages that You might incur, the entire liability of the Company and any of its suppliers under any provision of this Terms and Your exclusive remedy for all of the foregoing shall be limited to the amount actually paid by You through the Service or 100 USD if You have not purchased anything through the Service.', align: TextAlign.justify),
                const TypographyText(text: 'To the maximum extent permitted by applicable law, in no event shall the Company or its suppliers be liable for any special, incidental, indirect, or consequential damages whatsoever (including, but not limited to, damages for loss of profits, loss of data or other information, for business interruption, for personal injury, loss of privacy arising out of or in any way related to the use of or inability to use the Service, third-party software and/or third-party hardware used with the Service, or otherwise in connection with any provision of this Terms), even if the Company or any supplier has been advised of the possibility of such damages and even if the remedy fails of its essential purpose.', align: TextAlign.justify),
                const TypographyText(text: 'Some states do not allow the exclusion of implied warranties or limitation of liability for incidental or consequential damages, which means that some of the above limitations may not apply. In these states, each party\'s liability will be limited to the greatest extent permitted by law.', align: TextAlign.justify),

                const TypographyText(text: '"AS IS" and "AS AVAILABLE" Disclaimer', variant: TypographyVariant.h4),
                const TypographyText(text: 'The Service is provided to You "AS IS" and "AS AVAILABLE" and with all faults and defects without warranty of any kind. To the maximum extent permitted under applicable law, the Company, on its own behalf and on behalf of its Affiliates and its and their respective licensors and service providers, expressly disclaims all warranties, whether express, implied, statutory or otherwise, with respect to the Service, including all implied warranties of merchantability, fitness for a particular purpose, title and non-infringement, and warranties that may arise out of course of dealing, course of performance, usage or trade practice. Without limitation to the foregoing, the Company provides no warranty or undertaking, and makes no representation of any kind that the Service will meet Your requirements, achieve any intended results, be compatible or work with any other software, applications, systems or services, operate without interruption, meet any performance or reliability standards or be error free or that any errors or defects can or will be corrected.', align: TextAlign.justify),
                const TypographyText(text: 'Without limiting the foregoing, neither the Company nor any of the company\'s provider makes any representation or warranty of any kind, express or implied: (i) as to the operation or availability of the Service, or the information, content, and materials or products included thereon; (ii) that the Service will be uninterrupted or error-free; (iii) as to the accuracy, reliability, or currency of any information or content provided through the Service; or (iv) that the Service, its servers, the content, or e-mails sent from or on behalf of the Company are free of viruses, scripts, trojan horses, worms, malware, timebombs or other harmful components.', align: TextAlign.justify),
                const TypographyText(text: 'Some jurisdictions do not allow the exclusion of certain types of warranties or limitations on applicable statutory rights of a consumer, so some or all of the above exclusions and limitations may not apply to You. But in such a case the exclusions and limitations set forth in this section shall be applied to the greatest extent enforceable under applicable law.', align: TextAlign.justify),

                const TypographyText(text: 'Governing Law', variant: TypographyVariant.h4),
                const TypographyText(text: 'The laws of the Country, excluding its conflicts of law rules, shall govern this Terms and Your use of the Service. Your use of the Application may also be subject to other local, state, national, or international laws.', align: TextAlign.justify),

                const TypographyText(text: 'Disputes Resolution', variant: TypographyVariant.h4),
                const TypographyText(text: 'If You have any concern or dispute about the Service, You agree to first try to resolve the dispute informally by contacting the Company.', align: TextAlign.justify),

                const TypographyText(text: 'For European Union (EU) Users', variant: TypographyVariant.h4),
                const TypographyText(text: 'If You are a European Union consumer, you will benefit from any mandatory provisions of the law of the country in which you are resident in.', align: TextAlign.justify),

                const TypographyText(text: 'United States Legal Compliance', variant: TypographyVariant.h4),
                const TypographyText(text: 'You represent and warrant that (i) You are not located in a country that is subject to the United States government embargo, or that has been designated by the United States government as a "terrorist supporting" country, and (ii) You are not listed on any United States government list of prohibited or restricted parties.', align: TextAlign.justify),

                const TypographyText(text: 'Severability and Waiver', variant: TypographyVariant.h4),
                const TypographyText(text: 'Severability', variant: TypographyVariant.h6),
                const TypographyText(text: 'If any provision of these Terms is held to be unenforceable or invalid, such provision will be changed and interpreted to accomplish the objectives of such provision to the greatest extent possible under applicable law and the remaining provisions will continue in full force and effect.', align: TextAlign.justify),
                const TypographyText(text: 'Waiver', variant: TypographyVariant.h6),
                const TypographyText(text: 'Except as provided herein, the failure to exercise a right or to require performance of an obligation under these Terms shall not effect a party\'s ability to exercise such right or require such performance at any time thereafter nor shall the waiver of a breach constitute a waiver of any subsequent breach.', align: TextAlign.justify),

                const TypographyText(text: 'Translation Interpretation', variant: TypographyVariant.h4),
                const TypographyText(text: 'These Terms and Conditions may have been translated if We have made them available to You on our Service. You agree that the original English text shall prevail in the case of a dispute.', align: TextAlign.justify),

                const TypographyText(text: 'Changes to These Terms and Conditions', variant: TypographyVariant.h4),
                const TypographyText(text: 'We reserve the right, at Our sole discretion, to modify or replace these Terms at any time. If a revision is material We will make reasonable efforts to provide at least 30 days\' notice prior to any new terms taking effect. What constitutes a material change will be determined at Our sole discretion.', align: TextAlign.justify),
                const TypographyText(text: 'By continuing to access or use Our Service after those revisions become effective, You agree to be bound by the revised terms. If You do not agree to the new terms, in whole or in part, please stop using the website and the Service.', align: TextAlign.justify),

                const TypographyText(text: 'Contact Us', variant: TypographyVariant.h4),
                const TypographyText(text: 'If you have any questions about these Terms and Conditions, You can contact us:', align: TextAlign.justify),

                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ListTile(
                      title: Link(
                        text: config.privacyEmail,
                        href: Uri(
                          scheme: 'mailto',
                          path: config.privacyEmail,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
