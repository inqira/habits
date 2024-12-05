import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch URL'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card.outlined(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Image.asset(
                    'assets/icon/app_icon.png',
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Let\'s Habit',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card.outlined(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: const Text('Developer'),
                  subtitle: const Text('Inqira'),
                  leading: const Icon(Icons.code),
                ),
                ListTile(
                  title: const Text('Source Code'),
                  subtitle: const Text('View on GitHub'),
                  leading: const Icon(Icons.source),
                  onTap: () => _launchUrl('https://github.com/inqira/habits'),
                ),
                ListTile(
                  title: const Text('Report an Issue'),
                  subtitle: const Text('Open a GitHub issue'),
                  leading: const Icon(Icons.bug_report),
                  onTap: () =>
                      _launchUrl('https://github.com/inqira/habits/issues'),
                ),
                ListTile(
                  title: const Text('License'),
                  subtitle: const Text('MIT License'),
                  leading: const Icon(Icons.description),
                  onTap: () => _launchUrl(
                      'https://github.com/inqira/habits/blob/main/LICENSE'),
                ),
                ListTile(
                  title: const Text('Terms of Use'),
                  subtitle: const Text('Read our terms of use'),
                  leading: const Icon(Icons.gavel),
                  onTap: () => _launchUrl(
                      'https://github.com/inqira/habits/blob/main/legal/terms_of_use.md'),
                ),
                ListTile(
                  title: const Text('Privacy Policy'),
                  subtitle: const Text('Read our privacy policy'),
                  leading: const Icon(Icons.privacy_tip),
                  onTap: () => _launchUrl(
                      'https://github.com/inqira/habits/blob/main/legal/privacy_policy.md'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
