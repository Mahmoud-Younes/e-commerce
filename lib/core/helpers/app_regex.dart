class AppRegex {
  static bool isEmailValid(String email) => RegExp(
        r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$',
      ).hasMatch(email);

  static bool hasLowerCase(String text) => RegExp(r'^(?=.*[a-z])').hasMatch(text);

  static bool hasUpperCase(String text) => RegExp(r'^(?=.*[A-Z])').hasMatch(text);

  static bool hasNumber(String text) => RegExp(r'^(?=.*?[0-9])').hasMatch(text);

  static bool hasSpecialCharacter(String text) =>
      RegExp(r'^(?=.*?[#?!@$%^&*-])').hasMatch(text);

  static bool hasMinLength(String text) => RegExp(r'^.{8,}').hasMatch(text);
}
