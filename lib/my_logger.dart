import 'package:logger/logger.dart';

MyLogger get myLogger
 => MyLogger();

class MyLogger {
  static MyLogger? _instance;

  final Logger internalLogger;

  final bool enabled;
  factory MyLogger() {
    if (_instance == null) {
      throw Exception("Logger not initialized");
    }
    return _instance!;
  }
  MyLogger._internal({this.enabled = true, required this.internalLogger});
  error(String message) {
    if (!enabled) return;
    internalLogger.e(message);
  }

  void log(dynamic message) {
    if (!enabled) return;
    internalLogger.i(message);
  }

  void warning(String message) {
    if (!enabled) return;
    internalLogger.w(message);
  }

  static Future<MyLogger> init({bool enabled = true}) async {
    _instance = MyLogger._internal(
        enabled: enabled,
        internalLogger: Logger(
          printer: PrettyPrinter(),
        )..init);

    return _instance!;
  }
}
