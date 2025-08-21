// Dart SDK
import 'dart:developer' as developer;

enum LogLevel { trace, debug, info, warn, error }

void logTrace({
  String? message,
  String? tag,
  LogLevel level = LogLevel.trace,
  Object? error,
  StackTrace? stackTrace,
  bool includeStackTrace = false,
  int maxLength = 1000,
}) {
  // Skip if in release mode (optional)
  // if (kReleaseMode) return;

  try {
    final currentStackTrace = stackTrace ?? StackTrace.current;
    final trace = currentStackTrace.toString().split('\n');

    // Get caller information (skip this function and go to actual caller)
    final callerTrace = trace.length > 1 ? trace[2] : trace[0];
    final parts = callerTrace.split('(');
    final location = parts.length > 1 ? parts[1].replaceAll(')', '') : callerTrace;

    // Format timestamp
    final now = DateTime.now();
    final timestamp = '${now.hour}:${now.minute}:${now.second}:${now.millisecond}';

    // Determine log prefix based on level
    final levelPrefix = _getLevelPrefix(level);

    // Build log message - removed method name section
    final timeSection = '[$timestamp]';

    final logMessage = '''
$levelPrefix $timeSection ($location) ${message ?? 'No message'}${error != null ? '\nError: $error' : ''}${includeStackTrace && stackTrace != null ? '\nStack Trace:\n$stackTrace' : ''}
''';

    // Use appropriate logging method based on level
    switch (level) {
      case LogLevel.error:
        developer.log(
          logMessage,
          name: tag ?? 'APP',
          level: 1000,
          error: error,
          stackTrace: stackTrace,
        );
        break;
      case LogLevel.warn:
        developer.log(
          logMessage,
          name: tag ?? 'APP',
          level: 900,
        );
        break;
      case LogLevel.info:
        developer.log(
          logMessage,
          name: tag ?? 'APP',
          level: 800,
        );
        break;
      case LogLevel.debug:
      case LogLevel.trace:
        developer.log(
          logMessage,
          name: tag ?? 'APP',
          level: 700,
        );
        break;
    }
  } catch (e) {
    // Fallback logging if main logging fails
    developer.log('Logging failed: $e', name: 'LOG_ERROR');
  }
}

String _getLevelPrefix(LogLevel level) {
  switch (level) {
    case LogLevel.trace:
      return '🔍 TRACE';
    case LogLevel.debug:
      return '🐛 DEBUG';
    case LogLevel.info:
      return 'ℹ️  INFO ';
    case LogLevel.warn:
      return '⚠️  WARN ';
    case LogLevel.error:
      return '❌ ERROR';
  }
}

// Convenience methods for different log levels
void logDebug({String? message, String? tag}) {
  logTrace(message: message, tag: tag, level: LogLevel.debug);
}

void logInfo({String? message, String? tag}) {
  logTrace(message: message, tag: tag, level: LogLevel.info);
}

void logWarn({String? message, String? tag}) {
  logTrace(message: message, tag: tag, level: LogLevel.warn);
}

void logError({
  String? message,
  String? tag,
  Object? error,
  StackTrace? stackTrace,
}) {
  logTrace(
    message: message,
    tag: tag,
    level: LogLevel.error,
    error: error,
    stackTrace: stackTrace,
    includeStackTrace: true,
  );
}

// Extension for easy logging on any object
extension ObjectLogging on Object {
  void logThis({String? tag, LogLevel level = LogLevel.debug}) {
    logTrace(message: toString(), tag: tag, level: level);
  }
}
