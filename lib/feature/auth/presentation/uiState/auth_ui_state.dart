class AuthUiState {
  final bool isLoading;
  final String? errorMessage;
  final bool signInPasswordVisible;
  final String activeLanguage;

  final bool signUpPasswordVisible;
  final bool signUpRePasswordVisible;
  final String? signUpGender;
  final String? signUpNationalityValue;
  final int? signUpNationalityId;
  final String? signUpImagePath;

  final bool newPasswordVisible;
  final bool newRePasswordVisible;

  final bool verifyTimeExpired;
  final bool verifyResend;
  final int verifyCountResend;
  final int? verifyIdentify;

  const AuthUiState({
    this.isLoading = false,
    this.errorMessage,
    this.signInPasswordVisible = false,
    this.activeLanguage = 'km',
    this.signUpPasswordVisible = false,
    this.signUpRePasswordVisible = false,
    this.signUpGender,
    this.signUpNationalityValue,
    this.signUpNationalityId,
    this.signUpImagePath,
    this.newPasswordVisible = false,
    this.newRePasswordVisible = false,
    this.verifyTimeExpired = false,
    this.verifyResend = false,
    this.verifyCountResend = 0,
    this.verifyIdentify,
  });

  AuthUiState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? signInPasswordVisible,
    String? activeLanguage,
    bool? signUpPasswordVisible,
    bool? signUpRePasswordVisible,
    String? signUpGender,
    String? signUpNationalityValue,
    int? signUpNationalityId,
    String? signUpImagePath,
    bool? newPasswordVisible,
    bool? newRePasswordVisible,
    bool? verifyTimeExpired,
    bool? verifyResend,
    int? verifyCountResend,
    int? verifyIdentify,
  }) => AuthUiState(
    isLoading: isLoading ?? this.isLoading,
    errorMessage: errorMessage,
    signInPasswordVisible: signInPasswordVisible ?? this.signInPasswordVisible,
    activeLanguage: activeLanguage ?? this.activeLanguage,
    signUpPasswordVisible: signUpPasswordVisible ?? this.signUpPasswordVisible,
    signUpRePasswordVisible:
        signUpRePasswordVisible ?? this.signUpRePasswordVisible,
    signUpGender: signUpGender ?? this.signUpGender,
    signUpNationalityValue:
        signUpNationalityValue ?? this.signUpNationalityValue,
    signUpNationalityId: signUpNationalityId ?? this.signUpNationalityId,
    signUpImagePath: signUpImagePath ?? this.signUpImagePath,
    newPasswordVisible: newPasswordVisible ?? this.newPasswordVisible,
    newRePasswordVisible: newRePasswordVisible ?? this.newRePasswordVisible,
    verifyTimeExpired: verifyTimeExpired ?? this.verifyTimeExpired,
    verifyResend: verifyResend ?? this.verifyResend,
    verifyCountResend: verifyCountResend ?? this.verifyCountResend,
    verifyIdentify: verifyIdentify ?? this.verifyIdentify,
  );
}
