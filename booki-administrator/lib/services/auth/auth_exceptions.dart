class AuthException implements Exception {
  AuthProblem problem;
  AuthException(this.problem);
}

enum AuthProblem {
  userNotFound,
  wrongPassword,
  weakPassword,
  emailInUse,
  invalidEmail,
  emailUnverified,
  userUnauthorized,
  generic
}