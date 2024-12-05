extension EnumExtension<T extends Enum> on List<T> {
  T? byNameOrNull(String? name) {
    if (name == null) return null;

    try {
      return byName(name);
    } catch (_) {
      return null;
    }
  }

  T byNameOrDefaultValue(String? name, T defaultValue) {
    return byNameOrNull(name) ?? defaultValue;
  }
}
