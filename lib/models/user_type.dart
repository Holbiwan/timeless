// This file defines user roles and provides helpers to convert between  enum and stored string values.

enum UserType {
  candidate,
  employer,
}

class UserTypeHelper {
  // Convert value to a string for storage or API usage
  static String getUserTypeString(UserType type) {
    switch (type) {
      case UserType.candidate:
        return 'candidate';
      case UserType.employer:
        return 'employer';
    }
  }

  // Convert a stored string into its enum equivalent
  static UserType getUserTypeFromString(String type) {
    switch (type) {
      case 'candidate':
        return UserType.candidate;
      case 'employer':
        return UserType.employer;
      default:
        return UserType.candidate;
    }
  }
}
