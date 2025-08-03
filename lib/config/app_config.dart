class AppConfig {
  static const String adminEmail = 'admin@bkit.edu.in';
  static const String adminPhone = '+91 80-12345678';
  static const String collegeName = 'B.K.I.T College';
  static const String copyrightYear = '2024';
  
  static String get contactInfo => 'Contact $adminEmail or call $adminPhone';
  static String get copyrightNotice => '© $copyrightYear $collegeName. All rights reserved.';
}