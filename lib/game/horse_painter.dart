import 'dart:math' as math;
import 'dart:ui';

/// Yarış atı çizimi (sağa bakar). (x, y) atın gövde merkezi, [size] gövde
/// uzunluğunun yarısı; [phase] bacak koşusu için ilerleyen açıdır.
void paintHorse(
  Canvas canvas,
  double x,
  double y,
  double size,
  Color coat,
  Color silks,
  double phase,
) {
  Paint fill(Color c) => Paint()..color = c;
  Paint line(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round;
  final dark = Color.lerp(coat, const Color(0xFF000000), 0.45)!;
  final s = size;

  // Gölge
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(x, y + s * 0.85),
      width: s * 2.3,
      height: s * 0.28,
    ),
    fill(const Color(0x33000000)),
  );

  // Bacaklar: iki çift, ters fazda sallanır.
  for (var i = 0; i < 4; i++) {
    final front = i < 2;
    final baseX = x + (front ? s * 0.62 : -s * 0.62) + (i.isOdd ? s * 0.12 : 0);
    final swing =
        math.sin(phase + i * math.pi / 2 + (front ? 0 : math.pi)) * s * 0.28;
    canvas.drawLine(
      Offset(baseX, y + s * 0.2),
      Offset(baseX + swing, y + s * 0.8),
      line(i.isOdd ? dark : coat, s * 0.16),
    );
  }

  // Kuyruk
  canvas.drawPath(
    Path()
      ..moveTo(x - s * 0.95, y - s * 0.1)
      ..quadraticBezierTo(
        x - s * 1.5,
        y + s * 0.05 + math.sin(phase) * s * 0.1,
        x - s * 1.35,
        y + s * 0.55,
      ),
    line(dark, s * 0.14),
  );

  // Gövde
  canvas.drawOval(
    Rect.fromCenter(center: Offset(x, y), width: s * 2.1, height: s * 0.95),
    fill(coat),
  );

  // Boyun ve baş
  final neck = Path()
    ..moveTo(x + s * 0.7, y - s * 0.25)
    ..lineTo(x + s * 1.15, y - s * 0.85)
    ..lineTo(x + s * 1.4, y - s * 0.7)
    ..lineTo(x + s * 0.95, y + s * 0.1)
    ..close();
  canvas.drawPath(neck, fill(coat));
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(x + s * 1.45, y - s * 0.72),
      width: s * 0.7,
      height: s * 0.42,
    ),
    fill(coat),
  );
  // Yele, kulak, göz
  canvas
    ..drawLine(
      Offset(x + s * 0.8, y - s * 0.3),
      Offset(x + s * 1.2, y - s * 0.85),
      line(dark, s * 0.12),
    )
    ..drawPath(
      Path()
        ..moveTo(x + s * 1.22, y - s * 0.9)
        ..lineTo(x + s * 1.3, y - s * 1.1)
        ..lineTo(x + s * 1.38, y - s * 0.88)
        ..close(),
      fill(dark),
    )
    ..drawCircle(
      Offset(x + s * 1.5, y - s * 0.76),
      s * 0.05,
      fill(const Color(0xFF212121)),
    );

  // Jokey: forma, kask.
  canvas
    ..drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x + s * 0.2, y - s * 0.78),
          width: s * 0.5,
          height: s * 0.7,
        ),
        Radius.circular(s * 0.18),
      ),
      fill(silks),
    )
    ..drawCircle(
      Offset(x + s * 0.28, y - s * 1.3),
      s * 0.25,
      fill(const Color(0xFFF1C9A5)),
    )
    ..drawArc(
      Rect.fromCircle(
        center: Offset(x + s * 0.28, y - s * 1.32),
        radius: s * 0.27,
      ),
      math.pi,
      math.pi,
      true,
      fill(silks),
    );
}
