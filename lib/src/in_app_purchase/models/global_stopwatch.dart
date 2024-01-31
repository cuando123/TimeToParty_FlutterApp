class GlobalStopwatch {
  static final Stopwatch _stopwatch = Stopwatch();

  static void start() => _stopwatch.start();
  static void stop() => _stopwatch.stop();
  static void reset() => _stopwatch.reset();
  static int getElapsedTime() => _stopwatch.elapsed.inSeconds;
}
