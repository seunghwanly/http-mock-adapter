import 'dart:developer';

typedef OutputCallback = void Function(String message, Level level);

typedef OutputEvent = (String, Level);

Logger getLogger(bool printLogs) {
  return Logger(
    level: printLogs ? Level.debug : Level.off,
  );
}

enum Level {
  debug(0),
  info(800),
  warning(900),
  error(1000),
  off(2000);

  final int value;
  const Level(this.value);
}

class Logger {
  const Logger({
    required this.level,
  });

  final Level level;

  static final Set<OutputCallback> _outputCallbacks = <OutputCallback>{};

  static void addOutputListener(OutputCallback callback) {
    _outputCallbacks.add(callback);
  }

  static void removeOutputListener(OutputCallback callback) {
    _outputCallbacks.remove(callback);
  }

  void e(String message) {
    if (level == Level.off) {
      return;
    }

    if (_outputCallbacks.isNotEmpty) {
      for (final callback in _outputCallbacks) {
        callback(message, Level.error);
      }
    }

    log(message, level: Level.error.value);
  }

  void d(String message) {
    if (level == Level.off) {
      return;
    }

    if (_outputCallbacks.isNotEmpty) {
      for (final callback in _outputCallbacks) {
        callback(message, Level.debug);
      }
    }

    log(message, level: Level.debug.value);
  }
}
