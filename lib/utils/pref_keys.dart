class PrefKeys {
  // sign in
  static const isLogin = "is_login";
  static const register = "register";
  static const accessToken = "token";
  static const rol = "Rol";
  static const company = "company";
  static const registerToken = "registerToken";
  static const userId = "userId";
  static const phoneId = "phoneId";
  static const phoneNumber = "phoneNumber";
  static const imageId = "imageId";
  static const imageIdM = "imageIdM";
  static const openConfirmSignUpPage = "openConfirmSignUpPage";
  static const totalPost = "totalPost";
  static const allCountryData = "allCountryData";
  static const allDesignation = "allDesignation";
  static const emailRememberManager = "emailRememberManager";
  static const emailRememberUser = "emailRememberUser";
  static const passwordRememberUser = "passwordRememberUser";
  static const passwordRememberManager = "passwordRememberManager";

  // User Data
  static const firstName = "firstName";
  static const lasttName = "lstName";
  static const jobPosition = "jobPosition";
  static const profilePhoto = "profilePhoto";
  static const city = "city";
  static const state = "state";
  static const country = "country";
  static const positionList = "";
  static const fullName = "fullName";
  static const occupation = "Occupation";
  static const dateOfBirth = 'dateOfBirth';
  static const address = "address";
  static const bio = "bio";
  static const profileImageUrl = "profileImageUrl";

  // Job Matching Preferences - REMOVED
  static const experienceLevel = "experienceLevel"; // Junior, Mid, Senior, Lead
  static const skillsList = "skillsList"; // JSON array of skills
  static const salaryRangeMin = "salaryRangeMin"; // Minimum expected salary
  static const salaryRangeMax = "salaryRangeMax"; // Maximum expected salary
  static const jobTypes = "jobTypes"; // JSON array: Full-time, Contract, Remote
  static const industryPreferences =
      "industryPreferences"; // JSON array of industries
  static const companyTypes =
      "companyTypes"; // JSON array: Startup, Enterprise, etc.
  static const maxCommuteDistance = "maxCommuteDistance"; // In kilometers
  static const workLocationPreference =
      "workLocationPreference"; // Remote, On-site, Hybrid
  // static const jobPreferencesCompleted = "jobPreferencesCompleted"; // REMOVED

  //logout
  static const email = "Email";
  static const password = "password";
  static const rememberMe = "remember me";
  static const companyName = "companyName";
  static const firstnameu = "firstnameu";

  static const imageManager = "imageManager";
  static const deviceToken = "deviceToken";

  // CV and additional profile data
  static const cvFilePath = "cvFilePath";
  static const cvFileName = "cvFileName";
  static const phone = "phone";
  static const skills = "skills";
  static const salaryMin = "salaryMin";
  static const salaryMax = "salaryMax";

  // Theme and Language preferences
  static const isDarkMode = "isDarkMode";
  static const currentLanguage = "currentLanguage";

  // Employer specific keys
  static const employerId = "employerId";
  static const userType = "userType"; // 'candidate' or 'employer'
  static const siretCode = "siretCode";
  static const apeCode = "apeCode";
}
