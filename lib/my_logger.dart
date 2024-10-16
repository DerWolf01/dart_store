import 'package:logger/logger.dart';

MyLogger get myLogger => MyLogger();

class MyLogger {
  static MyLogger? _instance;

  final Logger internalLogger = Logger(
      filter: ProductionFilter(),
      printer: PrettyPrinter(
          methodCount: 2,
          // number of method calls to be displayed
          errorMethodCount: 25,
          stackTraceBeginIndex: 1,
          levelEmojis: {
            Level.info: 'ℹ️',
            Level.error: '❌',
            Level.warning: '⚠️',
            Level.debug: '🐞',
            Level.trace: '🔬',
            Level.fatal: '🤷'
          },

          // number of method calls if stacktrace is provided
          lineLength: 120,
          // width of the output
          colors: true,
          // Colorful log messages
          printEmojis: true,
          // Print an emoji for each log message
          dateTimeFormat: DateTimeFormat
              .dateAndTime // Should each log print contain a timestamp
          ),
      output: ConsoleOutput());

  final bool enabled;
  factory MyLogger() {
    if (_instance == null) {
      throw Exception("Logger not initialized");
    }
    return _instance!;
  }
  factory MyLogger.init({bool enabled = true}) {
    Logger.level = Level.trace;
    _instance = MyLogger._internal(
      enabled: enabled,
    );

    return _instance!;
  }
  MyLogger._internal({
    this.enabled = true,
  });
  void d(dynamic message, {Object? header}) {
    if (!enabled) return;
    internalLogger.d(message, error: header);
  }

  e(dynamic message, {Object? header, StackTrace? stackTrace}) {
    if (!enabled) return;
    internalLogger.e(message, error: header, stackTrace: stackTrace);
  }

  void i(dynamic message, {Object? header}) {
    if (!enabled) return;
    internalLogger.i(
      message,
      error: header,
      stackTrace: StackTrace.empty,
    );
  }

  void w(String message, {Object? header}) {
    if (!enabled) return;
    internalLogger.w(message, error: header);
  }
}
