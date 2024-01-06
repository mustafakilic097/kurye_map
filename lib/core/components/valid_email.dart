class ValidEmail {
  static bool isValidEmail(String email) {
    // Basit bir e-posta doğrulama regex'i
    // Daha karmaşık bir regex kullanabilir veya bir e-posta doğrulama kütüphanesi entegre edebilirsiniz.
    RegExp emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegex.hasMatch(email);
  }
}
