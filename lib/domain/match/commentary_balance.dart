/// Spiker anlatımı ayarları.
abstract final class CommentaryBalance {
  /// Maç uzunluğu (dakika).
  static const int matchMinutes = 90;

  /// Canlı anlatımda bir maç dakikasının gerçek süresi (saniye).
  /// Tam maç yaklaşık 20 sn sürer; "Geç" ile atlanabilir.
  static const double secondsPerMinute = 0.22;

  /// İki "ara anlatım" satırı arasındaki dakika aralığı.
  static const int fillerGapMin = 5;
  static const int fillerGapMax = 11;
}
