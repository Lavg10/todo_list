class Validator {
  static String? validateEmail(String email) {
    if (!email.contains('@') || !email.contains('.')) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String password) {
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
