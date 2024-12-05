import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _logger = Logger('LegalConsentService');

class LegalConsentService {
  static const String _termsConsentDateKey = 'terms_user_consent_date';
  static const String _privacyConsentDateKey = 'privacy_user_consent_date';
  static const String _latestTermsVersionKey = 'latest_terms_version';
  static const String _latestPrivacyVersionKey = 'latest_privacy_version';
  static const String _versionsUrl =
      'https://raw.githubusercontent.com/inqira/habit_tracker/main/legal/versions.json';

  final SharedPreferences _prefs;

  LegalConsentService(this._prefs);

  Future<void> updateLatestVersions() async {
    try {
      final response = await http.get(Uri.parse(_versionsUrl));

      if (response.statusCode != 200) {
        _logger.fine('Error fetching versions: ${response.statusCode}');
        return;
      }

      final Map<String, dynamic> versions = json.decode(response.body);

      final String latestTermsVersion =
          versions['terms_of_use']['latest_version'] as String;
      final String latestPrivacyVersion =
          versions['privacy_policy']['latest_version'] as String;

      await _prefs.setString(_latestTermsVersionKey, latestTermsVersion);
      await _prefs.setString(_latestPrivacyVersionKey, latestPrivacyVersion);
    } catch (e) {
      _logger.fine('Error updating legal versions: $e');
      // Don't rethrow - we want this to fail silently
    }
  }

  Future<void> saveConsent({
    required bool termsAccepted,
    required bool privacyAccepted,
  }) async {
    final now = DateTime.now().toIso8601String();
    if (termsAccepted) {
      await _prefs.setString(_termsConsentDateKey, now);
    }
    if (privacyAccepted) {
      await _prefs.setString(_privacyConsentDateKey, now);
    }
  }

  bool needsConsent() {
    final String? termsConsentDate = _prefs.getString(_termsConsentDateKey);
    final String? privacyConsentDate = _prefs.getString(_privacyConsentDateKey);

    // If no consent dates are found, consent is needed
    if (termsConsentDate == null || privacyConsentDate == null) {
      return true;
    }

    // If we have latest versions, check if consent is outdated
    final String? latestTermsVersion = _prefs.getString(_latestTermsVersionKey);
    final String? latestPrivacyVersion =
        _prefs.getString(_latestPrivacyVersionKey);

    try {
      final termsConsent = DateTime.parse(termsConsentDate);
      final privacyConsent = DateTime.parse(privacyConsentDate);

      // If we have latest versions, compare dates
      if (latestTermsVersion != null && latestPrivacyVersion != null) {
        final latestTerms = DateTime.parse(latestTermsVersion);
        final latestPrivacy = DateTime.parse(latestPrivacyVersion);

        return termsConsent.isBefore(latestTerms) ||
            privacyConsent.isBefore(latestPrivacy);
      }

      // If no latest versions (offline), consent is valid if dates exist
      return false;
    } catch (e) {
      _logger.fine('Error parsing dates: $e');
      return true;
    }
  }
}
