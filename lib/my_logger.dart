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

  final bool debug;
  final bool info;
  final bool warning;
  final bool error;
  factory MyLogger() {
    if (_instance == null) {
      throw Exception("Logger not initialized");
    }
    return _instance!;
  }
  factory MyLogger.init({
    final bool debug = false,
    final bool info = true,
    final bool warning = true,
    final bool error = true,
  }) {
    Logger.level = Level.trace;
    _instance = MyLogger._internal(
      debug: debug,
      info: info,
      warning: warning,
      error: error,
    );

    return _instance!;
  }
  MyLogger._internal({
    required this.debug,
    required this.info,
    required this.warning,
    required this.error,
  });
  void d(dynamic message, {Object? header}) {
    if (!debug) return;
    internalLogger.d(message, error: header);
  }

  e(dynamic message, {Object? header, StackTrace? stackTrace}) {
    if (!error) return;
    internalLogger.e(message, error: header, stackTrace: stackTrace);
  }

  void i(dynamic message, {Object? header}) {
    if (!info) return;
    internalLogger.i(
      message,
      error: header,
      stackTrace: StackTrace.empty,
    );
  }

  void w(String message, {Object? header}) {
    if (!warning) return;
    internalLogger.w(message, error: header);
  }
}
