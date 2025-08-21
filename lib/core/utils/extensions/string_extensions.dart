extension StringExtensions on String {
  // Check if a string is null or empty
  bool get isNullOrEmpty => trim().isEmpty;

  // Capitalize the first letter
  String capitalize() {
    if (isEmpty) return '';
    return this[0].toUpperCase() + substring(1);
  }
}
