extension ValidationExtensions on String {
  // Validate email
  bool get isValidEmail {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(this);
  }

  // Phone number validation (basic international format)
  bool get isPhoneNumber {
    final phoneRegExp = RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');
    return phoneRegExp.hasMatch(this);
  }

  // Password validation (at least 8 characters, 1 uppercase, 1 lowercase, 1 number)
  bool get isStrongPassword {
    final passwordRegExp = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$');
    return passwordRegExp.hasMatch(this);
  }

  // Check if string is a valid URL
  bool get isURL {
    final urlRegExp = RegExp(r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$');
    return urlRegExp.hasMatch(this);
  }

  // Check if string contains only alphabets
  bool get isAlphabetOnly {
    final alphabetRegExp = RegExp(r'^[a-zA-Z]+$');
    return alphabetRegExp.hasMatch(this);
  }

  // Check if string is alphanumeric
  bool get isAlphanumeric {
    final alphanumericRegExp = RegExp(r'^[a-zA-Z0-9]+$');
    return alphanumericRegExp.hasMatch(this);
  }

  // Check if string contains only numbers
  bool get isNumeric {
    final numericRegExp = RegExp(r'^-?[0-9]+$');
    return numericRegExp.hasMatch(this);
  }

  // Check if string is a valid date (YYYY-MM-DD)
  bool get isDate {
    try {
      DateTime.parse(this);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if string is a valid time (HH:MM)
  bool get isTime {
    final timeRegExp = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return timeRegExp.hasMatch(this);
  }

  // Check if string is a valid hexadecimal color code
  bool get isHexColor {
    final hexColorRegExp = RegExp(r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$');
    return hexColorRegExp.hasMatch(this);
  }

  // Check if string is empty or contains only whitespace
  bool get isBlank => trim().isEmpty;

  // Check if string is not empty and contains non-whitespace characters
  bool get isNotBlank => !isBlank;

  // Check if string contains at least one digit
  bool get containsDigit => contains(RegExp(r'[0-9]'));

  // Check if string contains at least one special character
  bool get containsSpecialCharacter => contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  // All common video extensions
  static final List<String> _videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.flv', '.wmv', '.webm', '.mpeg', '.mpg', '.3gp', '.m4v', '.ts'];

  // All common image extensions
  static final List<String> _imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff', '.webp', '.heic', '.heif', '.svg'];

  bool get isVideoUrl => _videoExtensions.any((ext) => toLowerCase().endsWith(ext));

  bool get isImageUrl => _imageExtensions.any((ext) => toLowerCase().endsWith(ext));
}
