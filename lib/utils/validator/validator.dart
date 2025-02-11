class EValidator {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required.';
    }
    if (!RegExp(r'^[\w-\.]+@ata-it-th\.com$').hasMatch(value)) {
      return 'Invalid email address.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    // mini length
    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    // upper case
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }

    // numbers
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number.';
    }

    // special characters
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character.';
    }

    return null;
  }
}
