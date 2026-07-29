abstract final class TimeFormatter {
  static String clock(int totalSeconds) {
    final safeSeconds = totalSeconds.clamp(0, 863999).toInt();
    final hours = safeSeconds ~/ 3600;
    final minutes = (safeSeconds % 3600) ~/ 60;
    final seconds = safeSeconds % 60;

    return '${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(seconds)}';
  }

  static String totalFocus(int totalSeconds) {
    final totalMinutes = totalSeconds ~/ 60;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours == 0) {
      return '${minutes}m';
    }

    return '${hours}h ${minutes}m';
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
