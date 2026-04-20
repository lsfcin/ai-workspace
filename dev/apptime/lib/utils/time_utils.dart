/// Formats milliseconds as a compact human-readable duration.
/// < 60 min → '5min' ; ≥ 60 min → '1h05'.
String fmtDuration(int ms) {
  final totalMin = ms ~/ 60000;
  if (totalMin < 60) return '${totalMin}min';
  final h = totalMin ~/ 60;
  final m = totalMin % 60;
  return '${h}h${m.toString().padLeft(2, '0')}';
}
