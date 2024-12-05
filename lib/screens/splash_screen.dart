import 'package:flutter/material.dart';

import 'package:habits/screens/home/home_screen.dart';
import 'package:habits/screens/setup_screen.dart';
import 'package:habits/services/service_locator.dart';
import 'package:habits/widgets/legal_consent_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Add any initialization logic here
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  void _onConsentComplete() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final needsConsent = serviceLocator.legalConsentService.needsConsent();
    if (needsConsent) {
      return Scaffold(
        body: LegalConsentWidget(
          legalConsentService: serviceLocator.legalConsentService,
          onConsentComplete: _onConsentComplete,
        ),
      );
    }

    // Check if user needs setup (no name set)
    final settings = serviceLocator.settingsService.settings;
    if (settings.name.value.isEmpty) {
      return const SetupScreen();
    }

    return const HomeScreen();
  }
}
