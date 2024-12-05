import 'package:diacritic/diacritic.dart';

extension StringExtensions on String? {
  /// Converts a string to snake case, removes special characters,
  /// and converts accented characters to their English equivalents.
  /// Example: "Héllö Wörld!".toSnakeCase() -> "hello_world"
  String toSnakeCase() {
    if (this == null) {
      return '';
    } else if (this!.isEmpty) {
      return '';
    } else {
      String str = this!;

      // Remove diacritics (accent marks)
      String normalized = removeDiacritics(str);

      // Convert to lowercase
      normalized = normalized.toLowerCase();

      // Replace Turkish 'ı' with 'i'
      normalized = normalized.replaceAll('ı', 'i');

      // Replace special characters with spaces
      normalized = normalized.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');

      // Replace multiple spaces with single space and trim
      normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();

      // Replace spaces with underscores
      return normalized.replaceAll(' ', '_');
    }
  }
}
