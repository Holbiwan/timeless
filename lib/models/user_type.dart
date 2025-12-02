enum UserType {
  candidate,
  employer,
}

class UserTypeHelper {
  static String getUserTypeString(UserType type) {
    switch (type) {
      case UserType.candidate:
        return 'candidate';
      case UserType.employer:
        return 'employer';
    }
  }

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