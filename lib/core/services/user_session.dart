/// Simple in-memory user session — no external state management needed.
/// Call [UserSession.instance] anywhere in the app after login.
class UserSession {
  UserSession._();
  static final UserSession instance = UserSession._();

  // Populated on login
  String fullName = '';
  String nationalId = '';
  String email = '';
  String phone = '';
  String address = '';
  String dateOfBirth = '';
  String gender = '';
  int applicationsCount = 4;
  int licensesCount = 2;
  int violationsCount = 0;

  /// Set user data when they sign in.
  void login({
    required String fullName,
    required String nationalId,
    required String email,
    String phone = '',
    String address = '',
    String dateOfBirth = '',
    String gender = 'Male',
  }) {
    this.fullName = fullName;
    this.nationalId = nationalId;
    this.email = email;
    this.phone = phone;
    this.address = address;
    this.dateOfBirth = dateOfBirth;
    this.gender = gender;
  }

  void logout() {
    fullName = '';
    nationalId = '';
    email = '';
    phone = '';
    address = '';
    dateOfBirth = '';
    gender = '';
  }

  /// Returns first name only for greetings.
  String get firstName {
    if (fullName.isEmpty) return 'User';
    return fullName.split(' ').first;
  }

  /// Returns masked national ID.
  String get maskedId {
    if (nationalId.length < 4) return nationalId;
    return '${nationalId.substring(0, 1)}****${nationalId.substring(nationalId.length - 4)}';
  }
}

/// Mock user lookup for demo purposes.
/// Maps login identifier → user profile.
class MockUsers {
  static const List<Map<String, String>> _users = [
    {
      'identifier': 'ahmad',
      'fullName': 'Ahmad Al-Rashid',
      'nationalId': '9876543210',
      'email': 'ahmad@email.com',
      'phone': '+962 79 555 1234',
      'address': 'Amman, Jordan — Al Jubeiha',
      'dateOfBirth': 'Jan 15, 1990',
      'gender': 'Male',
    },
    {
      'identifier': 'sara',
      'fullName': 'Sara Hassan',
      'nationalId': '9123456780',
      'email': 'sara@email.com',
      'phone': '+962 77 444 5678',
      'address': 'Irbid, Jordan',
      'dateOfBirth': 'Mar 22, 1995',
      'gender': 'Female',
    },
    {
      'identifier': 'khalid',
      'fullName': 'Khalid Al-Masri',
      'nationalId': '9234567801',
      'email': 'khalid@email.com',
      'phone': '+962 78 333 9012',
      'address': 'Zarqa, Jordan',
      'dateOfBirth': 'Jul 8, 1987',
      'gender': 'Male',
    },
  ];

  /// Find a user by identifier (email prefix, full email, or national ID).
  static Map<String, String>? find(String input) {
    final q = input.toLowerCase().trim();
    // Try exact match or starts-with on identifier, email, or nationalId
    for (final u in _users) {
      if (q == u['identifier'] ||
          q.startsWith(u['identifier']!) ||
          q == u['email'] ||
          q == u['nationalId']) {
        return u;
      }
    }
    return null;
  }

  /// Derive a display name from any freeform input (fallback).
  static String deriveDisplayName(String input) {
    // If it looks like an email, use the part before @
    if (input.contains('@')) {
      final prefix = input.split('@').first;
      return prefix
          .split(RegExp(r'[._\-]'))
          .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' ')
          .trim();
    }
    // If it looks like a numeric ID, show generic
    if (RegExp(r'^\d+$').hasMatch(input)) {
      return 'Applicant';
    }
    // Otherwise capitalize words
    return input
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ')
        .trim();
  }
}
