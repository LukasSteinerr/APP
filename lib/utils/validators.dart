class Validators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }

    // More flexible URL validation for Xtream servers
    // This allows IP addresses, ports, and various URL formats
    final urlPattern = RegExp(
      r'^(http|https)://([a-zA-Z0-9][-a-zA-Z0-9_.]*(\.[a-zA-Z0-9][-a-zA-Z0-9_.]*)+|([0-9]{1,3}\.){3}[0-9]{1,3})(:[0-9]+)?(/[-a-zA-Z0-9_%./~]*)?$',
      caseSensitive: false,
    );

    if (!urlPattern.hasMatch(value)) {
      // If it doesn't match the pattern, try to fix common issues
      String fixedUrl = value;

      // Add http:// if missing
      if (!fixedUrl.startsWith('http://') && !fixedUrl.startsWith('https://')) {
        fixedUrl = 'http://$fixedUrl';
      }

      // Try again with the fixed URL
      if (urlPattern.hasMatch(fixedUrl)) {
        return null; // Accept the URL after fixing
      }

      return 'Please enter a valid URL (e.g., http://example.com or http://192.168.1.1:8080)';
    }

    return null;
  }

  static String? validateConnectionName(String? value) {
    return validateRequired(value, 'Connection name');
  }

  static String? validateServerUrl(String? value) {
    return validateUrl(value);
  }

  static String? validateUsername(String? value) {
    return validateRequired(value, 'Username');
  }

  static String? validatePassword(String? value) {
    return validateRequired(value, 'Password');
  }
}
