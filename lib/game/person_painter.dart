import 'dart:ui';

/// Mini oyunların ortak karakter çizimi. (x, y) gövdenin merkezi, [unit] top
/// yarıçapıdır; toplam boy ≈ 5.8 x [unit] x [scale].
void paintPerson(
  Canvas canvas,
  double x,
  double y,
  double unit,
  Color shirt, {
  double scale = 1,
  double tilt = 0,
  Color skin = const Color(0xFFE0AC83),
  Color hair = const Color(0xFF3E2723),
}) {
  final r = unit * scale;
  Paint p(Color c) => Paint()..color = c;
  final dark = Color.lerp(shirt, const Color(0xFF000000), 0.35)!;

  // Zemin gölgesi (dönmez).
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(x, y + r * 2.5),
      width: r * 3.2,
      height: r * 0.9,
    ),
    p(const Color(0x33000000)),
  );

  canvas
    ..save()
    ..translate(x, y)
    ..rotate(tilt);

  // Bacaklar + çoraplar + kramponlar
  for (final side in const [-1.0, 1.0]) {
    final lx = side * r * 0.55;
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(lx - r * 0.3, r * 1.1, r * 0.6, r * 1.1),
          Radius.circular(r * 0.25),
        ),
        p(skin),
      )
      ..drawRect(
        Rect.fromLTWH(lx - r * 0.3, r * 1.6, r * 0.6, r * 0.6),
        p(const Color(0xFFFFFFFF)),
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(lx - r * 0.38, r * 2.1, r * 0.95, r * 0.45),
          Radius.circular(r * 0.2),
        ),
        p(const Color(0xFF212121)),
      );
  }

  // Şort
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(-r * 1.0, r * 0.5, r * 2.0, r * 0.9),
      Radius.circular(r * 0.3),
    ),
    p(dark),
  );

  // Kollar
  for (final side in const [-1.0, 1.0]) {
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            side > 0 ? r * 1.0 : -r * 1.45,
            -r * 1.3,
            r * 0.45,
            r * 1.5,
          ),
          Radius.circular(r * 0.22),
        ),
        p(shirt),
      )
      ..drawCircle(Offset(side * r * 1.22, r * 0.35), r * 0.25, p(skin));
  }

  // Forma + yaka çizgisi
  canvas
    ..drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-r * 1.0, -r * 1.5, r * 2.0, r * 2.2),
        Radius.circular(r * 0.5),
      ),
      p(shirt),
    )
    ..drawRect(
      Rect.fromLTWH(-r * 1.0, -r * 0.35, r * 2.0, r * 0.28),
      p(const Color(0x55FFFFFF)),
    );

  // Kafa, saç, yüz
  final head = Offset(0, -r * 2.35);
  canvas
    ..drawCircle(head, r * 0.95, p(skin))
    ..drawArc(
      Rect.fromCircle(center: head, radius: r * 0.98),
      3.14159,
      3.14159,
      true,
      p(hair),
    )
    ..drawCircle(
      head.translate(-r * 0.32, r * 0.05),
      r * 0.11,
      p(const Color(0xFF212121)),
    )
    ..drawCircle(
      head.translate(r * 0.32, r * 0.05),
      r * 0.11,
      p(const Color(0xFF212121)),
    )
    ..drawArc(
      Rect.fromCenter(
        center: head.translate(0, r * 0.3),
        width: r * 0.6,
        height: r * 0.35,
      ),
      0.2,
      2.7,
      false,
      Paint()
        ..color = const Color(0xFF5D4037)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.08
        ..strokeCap = StrokeCap.round,
    )
    ..restore();
}
