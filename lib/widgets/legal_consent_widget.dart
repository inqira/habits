import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:habits/services/legal_consent_service.dart';

class LegalConsentWidget extends StatelessWidget {
  final LegalConsentService legalConsentService;
  final VoidCallback onConsentComplete;

  const LegalConsentWidget({
    super.key,
    required this.legalConsentService,
    required this.onConsentComplete,
  });

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;
        return Center(
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            margin: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Legal Consent Required',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    const Text(
                      'To use this app, you must agree to our Terms of Use and Privacy Policy.',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () => _launchURL(
                              'https://github.com/inqira/habits/blob/main/legal/terms_of_use.md'),
                          child: const Text('Terms of Use'),
                        ),
                        OutlinedButton(
                          onPressed: () => _launchURL(
                              'https://github.com/inqira/habits/blob/main/legal/privacy_policy.md'),
                          child: const Text('Privacy Policy'),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    SizedBox(
                      width: isSmallScreen ? double.infinity : 200,
                      child: OutlinedButton(
                        onPressed: () async {
                          await legalConsentService.saveConsent(
                            termsAccepted: true,
                            privacyAccepted: true,
                          );
                          onConsentComplete();
                        },
                        child: const Text('I Agree'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
