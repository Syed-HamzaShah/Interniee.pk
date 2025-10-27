class AppLogger {
  static void info(String message) {
    print('ℹ️  $message');
  }

  static void error(String message) {
    print('❌ Error: $message');
  }

  static void warning(String message) {
    print('⚠️  $message');
  }

  static void success(String message) {
    print('✅ $message');
  }
}
