/// A utility class providing standardized form validation functions.
class FormValidators {
  /// Private constructor to prevent instantiation
  FormValidators._();

  /// Validates that the field is not empty
  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regex = RegExp(pattern);

    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates password strength
  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    // Check for at least one special character
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Validates that passwords match
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.trim().isEmpty) {
      return 'Confirm password is required';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validates phone number format
  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Nigerian phone number validation
    // Supports formats like: 08012345678, +2348012345678, 2348012345678
    const pattern = r'^(\+234|234|0)[0-9]{10}$';
    final regex = RegExp(pattern);

    if (!regex.hasMatch(value)) {
      return 'Please enter a valid Nigerian phone number';
    }

    return null;
  }

  /// Validates name format (letters, spaces, hyphens, apostrophes)
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    const pattern = r"^[a-zA-Z\s'-]+$";
    final regex = RegExp(pattern);

    if (!regex.hasMatch(value)) {
      return 'Please enter a valid name';
    }

    return null;
  }

  /// Validates that a selection has been made
  static String? dropdownSelection(dynamic value) {
    if (value == null) {
      return 'Please make a selection';
    }
    return null;
  }
}
