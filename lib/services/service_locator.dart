import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

import 'package:habits/repositories/category_repository.dart';
import 'package:habits/repositories/habit_entry_repository.dart';
import 'package:habits/repositories/habit_repository.dart';
import 'package:habits/services/category_service.dart';
import 'package:habits/services/habit_entry_service.dart';
import 'package:habits/services/habit_service.dart';
import 'package:habits/services/legal_consent_service.dart';
import 'package:habits/services/settings_service.dart';
import 'package:habits/services/statistics_service.dart';

class ServiceLocator {
  static ServiceLocator? _instance;
  final GetIt _getIt = GetIt.instance;
  final Lock _lock = Lock();
  final Completer<void> _setupCompleter = Completer<void>();

  ServiceLocator._();

  static ServiceLocator get instance {
    _instance ??= ServiceLocator._();
    return _instance!;
  }

  T get<T extends Object>() => _getIt<T>();

  CategoryService get categoryService => _getIt<CategoryService>();
  SettingsService get settingsService => _getIt<SettingsService>();
  HabitService get habitService => _getIt<HabitService>();
  HabitEntryService get habitEntryService => _getIt<HabitEntryService>();
  StatisticsService get statisticsService => _getIt<StatisticsService>();
  LegalConsentService get legalConsentService => _getIt<LegalConsentService>();

  Future<void> setup() async {
    if (_setupCompleter.isCompleted) {
      return;
    }

    await _lock.synchronized(() async {
      if (_setupCompleter.isCompleted) {
        return;
      }

      try {
        // Initialize SharedPreferences and Database
        final prefs = await SharedPreferences.getInstance();

        // Register repositories
        if (!_getIt.isRegistered<CategoryRepository>()) {
          _getIt.registerLazySingleton<CategoryRepository>(
              () => CategoryRepository());
        }

        if (!_getIt.isRegistered<HabitRepository>()) {
          _getIt
              .registerLazySingleton<HabitRepository>(() => HabitRepository());
        }

        if (!_getIt.isRegistered<HabitEntryRepository>()) {
          _getIt.registerLazySingleton<HabitEntryRepository>(
              () => HabitEntryRepository());
        }

        // Register services
        if (!_getIt.isRegistered<CategoryService>()) {
          _getIt.registerLazySingleton<CategoryService>(
            () => CategoryService(_getIt<CategoryRepository>()),
          );
        }

        if (!_getIt.isRegistered<SettingsService>()) {
          _getIt
              .registerLazySingleton<SettingsService>(() => SettingsService());
        }

        if (!_getIt.isRegistered<HabitService>()) {
          _getIt.registerLazySingleton<HabitService>(
            () => HabitService(_getIt<HabitRepository>()),
          );
        }

        if (!_getIt.isRegistered<HabitEntryService>()) {
          _getIt.registerLazySingleton<HabitEntryService>(
            () => HabitEntryService(
              _getIt<HabitService>(),
              _getIt<HabitEntryRepository>(),
            ),
          );
        }

        if (!_getIt.isRegistered<LegalConsentService>()) {
          _getIt.registerLazySingleton<LegalConsentService>(
            () => LegalConsentService(prefs),
          );
          // Update legal versions in the background
          _getIt<LegalConsentService>().updateLatestVersions();
        }

        if (!_getIt.isRegistered<StatisticsService>()) {
          _getIt.registerSingleton(
            StatisticsService(
                _getIt<HabitService>(), _getIt<HabitEntryService>()),
          );
        }

        _setupCompleter.complete();
      } catch (e) {
        _setupCompleter.completeError(e);
        rethrow;
      }
    });
  }
}

// Top-level convenience getter
final serviceLocator = ServiceLocator.instance;
