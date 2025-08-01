extension StringExtensions on String {
  // Check if a string is null or empty
  bool get isNullOrEmpty => isEmpty;

  // Validate if the string is an email
  bool get isValidEmail {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(this);
  }

  // Capitalize the first letter of the string
  String capitalize() {
    if (isEmpty) return '';
    return this[0].toUpperCase() + substring(1);
  }
}

extension PasswordValidation on String? {
  String? validatePassword() {
    if (this == null || this!.isEmpty) {
      return 'Please enter a password';
    }

    if (this!.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    // Check for at least one uppercase letter
    if (!RegExp(r'(?=.*?[A-Z])').hasMatch(this!)) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!RegExp(r'(?=.*?[a-z])').hasMatch(this!)) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one number
    if (!RegExp(r'(?=.*?[0-9])').hasMatch(this!)) {
      return 'Password must contain at least one number';
    }

    return null;
  }
}
