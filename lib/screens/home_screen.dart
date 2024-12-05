import 'package:flutter/material.dart';

import 'package:signals/signals_flutter.dart';

import 'package:habits/services/service_locator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = serviceLocator.settingsService;

    return Scaffold(
      appBar: AppBar(
        title: Watch((context) {
          return Text('Welcome ${settingsService.settings.name.value}');
        }),
      ),
      body: const Center(
        child: Text('Home Screen - Coming Soon'),
      ),
    );
  }
}
