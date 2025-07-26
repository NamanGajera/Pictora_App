extension ValidationExtensions on String {
  // Email validation
  bool get isEmail {
    final emailRegExp = RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    return emailRegExp.hasMatch(this);
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
}
