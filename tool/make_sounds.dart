// Kısa ses efektlerini sentezleyip assets/sounds altına WAV olarak yazar.
// Her şey koddan üretilir; telifli ses yoktur. Çalıştır: dart run tool/make_sounds.dart
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const int sampleRate = 22050;

/// Tek bir nota: [freq] Hz, [seconds] sn, hızlı giriş + üstel sönüm.
List<double> note(
  double freq,
  double seconds, {
  double volume = 0.6,
  double harmonics = 0.3,
  double decay = 5,
}) {
  final n = (seconds * sampleRate).round();
  final out = List<double>.filled(n, 0);
  for (var i = 0; i < n; i++) {
    final t = i / sampleRate;
    final attack = math.min(1.0, t / 0.005);
    final env = attack * math.exp(-decay * t / seconds);
    final w =
        math.sin(2 * math.pi * freq * t) +
        harmonics * math.sin(2 * math.pi * freq * 2 * t);
    out[i] = volume * env * w / (1 + harmonics);
  }
  return out;
}

/// Frekansı [from]'dan [to]'ya kayan ses (düşüş/yükseliş).
List<double> glide(double from, double to, double seconds, {double volume = 0.6}) {
  final n = (seconds * sampleRate).round();
  final out = List<double>.filled(n, 0);
  var phase = 0.0;
  for (var i = 0; i < n; i++) {
    final p = i / n;
    final f = from + (to - from) * p;
    phase += 2 * math.pi * f / sampleRate;
    final env = math.min(1.0, i / (sampleRate * 0.005)) * (1 - p);
    out[i] = volume * env * math.sin(phase);
  }
  return out;
}

/// Hakem düdüğü: yüksek, hızlı titreşimli ton.
List<double> whistle(double seconds) {
  final n = (seconds * sampleRate).round();
  final out = List<double>.filled(n, 0);
  for (var i = 0; i < n; i++) {
    final t = i / sampleRate;
    final p = i / n;
    final env = math.min(1.0, t / 0.02) * math.min(1.0, (1 - p) / 0.15);
    final trill = 0.55 + 0.45 * math.sin(2 * math.pi * 34 * t);
    final f = 2900 + 60 * math.sin(2 * math.pi * 6 * t);
    out[i] = 0.5 * env * trill * math.sin(2 * math.pi * f * t);
  }
  return out;
}

List<double> concat(List<List<double>> parts) => [for (final p in parts) ...p];

/// [b]'yi [a]'nın [at] saniye sonrasına bindirir.
List<double> mix(List<double> a, List<double> b, double at) {
  final start = (at * sampleRate).round();
  final len = math.max(a.length, start + b.length);
  final out = List<double>.filled(len, 0);
  for (var i = 0; i < a.length; i++) {
    out[i] += a[i];
  }
  for (var i = 0; i < b.length; i++) {
    out[start + i] += b[i];
  }
  return out;
}

Uint8List wav(List<double> samples) {
  final data = ByteData(44 + samples.length * 2);
  void ascii(int offset, String s) {
    for (var i = 0; i < s.length; i++) {
      data.setUint8(offset + i, s.codeUnitAt(i));
    }
  }

  ascii(0, 'RIFF');
  data.setUint32(4, 36 + samples.length * 2, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little); // PCM
  data.setUint16(22, 1, Endian.little); // mono
  data.setUint32(24, sampleRate, Endian.little);
  data.setUint32(28, sampleRate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  ascii(36, 'data');
  data.setUint32(40, samples.length * 2, Endian.little);
  for (var i = 0; i < samples.length; i++) {
    final v = (samples[i].clamp(-1.0, 1.0) * 32767).round();
    data.setInt16(44 + i * 2, v, Endian.little);
  }
  return data.buffer.asUint8List();
}

void main() {
  // Notalar (Hz)
  const c5 = 523.25, e5 = 659.25, g5 = 783.99, c6 = 1046.5;
  const b5 = 987.77, e6 = 1318.5;

  final sounds = <String, List<double>>{
    // Başarı: kısa yükselen üç nota.
    'good': concat([
      note(c5, 0.09),
      note(e5, 0.09),
      note(g5, 0.2, decay: 4),
    ]),
    // Başarısızlık: alçalan boğuk ton.
    'bad': glide(330, 150, 0.35, volume: 0.5),
    // Gol: dört notalık küçük fanfar.
    'goal': concat([
      note(c5, 0.12),
      note(e5, 0.12),
      note(g5, 0.12),
      mix(note(c6, 0.55, decay: 3), note(g5, 0.55, volume: 0.3, decay: 3), 0),
    ]),
    // Düdük: maç başı/sonu.
    'whistle': whistle(0.65),
    // Satın alma: iki parlak "ding".
    'buy': mix(note(b5, 0.25, decay: 6), note(e6, 0.4, decay: 5), 0.09),
  };

  final dir = Directory('assets/sounds')..createSync(recursive: true);
  for (final e in sounds.entries) {
    final file = File('${dir.path}/${e.key}.wav')..writeAsBytesSync(wav(e.value));
    stdout.writeln('${file.path}  ${file.lengthSync()} bayt');
  }
}
