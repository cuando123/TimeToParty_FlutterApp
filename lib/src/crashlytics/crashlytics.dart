import 'dart:async';
import 'dart:isolate';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

Future<void> guardWithCrashlytics(
  void Function() mainFunction, {
  required FirebaseCrashlytics? crashlytics,
}) async {
  await runZonedGuarded<Future<void>>(() async {
    if (kDebugMode) {
      // Log more when in debug mode.
      Logger.root.level = Level.FINE;
    }
    // Subscribe to log messages.
    Logger.root.onRecord.listen((record) {
      final message = '${record.level.name}: ${record.time}: '
          '${record.loggerName}: '
          '${record.message}';

      debugPrint(message);
      // Add the message to the rotating Crashlytics log.
      crashlytics?.log(message);

      if (record.level >= Level.SEVERE) {
        crashlytics?.recordError(message, filterStackTrace(StackTrace.current),
            fatal: true);
      }
    });
    // Pass all uncaught errors from the framework to Crashlytics.
    if (crashlytics != null) {
     // WidgetsFlutterBinding.ensureInitialized();???
      FlutterError.onError = crashlytics.recordFlutterFatalError;
    }
    if (!kIsWeb) {
      // To catch errors outside of the Flutter context, we attach an error
      // listener to the current isolate.
      Isolate.current.addErrorListener(RawReceivePort((dynamic pair) async {
        final errorAndStacktrace = pair as List<dynamic>;
        await crashlytics?.recordError(
            errorAndStacktrace.first, errorAndStacktrace.last as StackTrace?,
            fatal: true);
      }).sendPort);
    }
    // Run the actual code.
    mainFunction();
  }, (error, stack) {
    // This sees all errors that occur in the runZonedGuarded zone.
    debugPrint('ERROR: $error\n\n'
        'STACK:$stack');
    crashlytics?.recordError(error, stack, fatal: true);
  });
}
@visibleForTesting
StackTrace filterStackTrace(StackTrace stackTrace) {
  try {
    final lines = stackTrace.toString().split('\n');
    final buf = StringBuffer();
    for (final line in lines) {
      if (line.contains('crashlytics.dart') ||
          line.contains('_BroadcastStreamController.java') ||
          line.contains('logger.dart')) {
        continue;
      }
      buf.writeln(line);
    }
    return StackTrace.fromString(buf.toString());
  } catch (e) {
    debugPrint('Problem while filtering stack trace: $e');
  }
  return stackTrace;
}