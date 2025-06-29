// lib/utils/time_formatter.dart

/// Formatiert Sekunden in einen menschenlesbaren String (MM:SS oder HH:MM:SS).
/// Gibt "00:00" zurück, wenn Sekunden negativ sind.
String formatTime(int seconds) {
  if (seconds < 0) seconds = 0;
  final Duration duration = Duration(seconds: seconds);
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final String minutes = twoDigits(duration.inMinutes.remainder(60));
  final String hours = twoDigits(duration.inHours);
  final String secondsStr = twoDigits(duration.inSeconds.remainder(60));

  if (duration.inHours > 0) {
    return '$hours:$minutes:$secondsStr';
  } else {
    return '$minutes:$secondsStr';
  }
}