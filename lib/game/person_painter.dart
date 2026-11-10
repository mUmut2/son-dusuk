import 'dart:math' as math;
import 'dart:ui';

/// [paintPerson] çiziminin kapladığı dikdörtgen (gölge hariç). Yerleşimlerin
/// üst üste binmediğini doğrulamak için kullanılır.
Rect personBounds(double x, double y, double unit, {double scale = 1}) {
  final r = unit * scale;
  return Rect.fromLTRB(x - r * 1.5, y - r * 3.55, x + r * 1.5, y + r * 2.6);
}

const _skins = [
  Color(0xFFE0AC83),
  Color(0xFFF1C9A5),
  Color(0xFFB77B55),
  Color(0xFF8D5A3B),
];
const _hairs = [
  Color(0xFF3E2723),
  Color(0xFF1B1B1B),
  Color(0xFF8D5B2E),
  Color(0xFFD9A441),
];

Color _shade(Color c, double amount) => amount >= 0
    ? Color.lerp(c, const Color(0xFF000000), amount)!
    : Color.lerp(c, const Color(0xFFFFFFFF), -amount)!;

/// Mini oyunların ortak karakter çizimi. (x, y) gövdenin merkezi, [unit] top
/// yarıçapıdır; toplam boy ≈ 6.1 x [unit] x [scale].
///
/// [variant] saç biçimini, saç ve ten rengini seçer (aynı sahnedeki
/// oyuncular birbirinin kopyası gibi görünmesin). [skin]/[hair] verilirse onu
/// kullanır. [keeper] true ise uzun kollu forma ve eldiven çizer.
void paintPerson(
  Canvas canvas,
  double x,
  double y,
  double unit,
  Color shirt, {
  double scale = 1,
  double tilt = 0,
  int variant = 0,
  bool keeper = false,
  Color? skin,
  Color? hair,
}) {
  final r = unit * scale;
  final skinColor = skin ?? _skins[variant % _skins.length];
  final hairColor = hair ?? _hairs[(variant ~/ 2) % _hairs.length];
  final hairStyle = (variant + variant ~/ 4) % 4;
  final ink = _shade(shirt, 0.6); // çizgi rengi: formanın koyusu
  final skinInk = _shade(skinColor, 0.4);
  final shorts = keeper ? const Color(0xFF263238) : _shade(shirt, 0.4);

  Paint fill(Color c) => Paint()..color = c;
  Paint line(Color c, [double w = 0.07]) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = r * w
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
  Paint gradient(Rect rect, Color top, Color bottom) => Paint()
    ..shader = Gradient.linear(rect.topCenter, rect.bottomCenter, [
      top,
      bottom,
    ]);

  void rrect(Rect rect, double radius, Paint paint, Color outline) {
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(r * radius));
    canvas
      ..drawRRect(rr, paint)
      ..drawRRect(rr, line(outline));
  }

  Rect box(double l, double t, double w, double h) =>
      Rect.fromLTWH(r * l, r * t, r * w, r * h);

  // Zemin gölgesi (dönmez).
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(x, y + r * 2.5),
      width: r * 3.2,
      height: r * 0.9,
    ),
    fill(const Color(0x33000000)),
  );

  canvas
    ..save()
    ..translate(x, y)
    ..rotate(tilt);

  // Bacaklar: ten, takım renginde çorap (beyaz şeritli), kramponlar.
  for (final side in const [-1.0, 1.0]) {
    final lx = side * 0.5;
    final leg = box(lx - 0.3, 1.1, 0.6, 1.1);
    rrect(leg, 0.25, fill(skinColor), skinInk);
    final sock = box(lx - 0.3, 1.55, 0.6, 0.65);
    canvas
      ..drawRect(sock, fill(shirt))
      ..drawRect(box(lx - 0.3, 1.7, 0.6, 0.12), fill(const Color(0xCCFFFFFF)));
    final bootLeft = side > 0 ? lx - 0.32 : lx - 0.63;
    final boot = box(bootLeft, 2.08, 0.95, 0.48);
    rrect(boot, 0.22, fill(const Color(0xFF263238)), const Color(0xFF000000));
    canvas.drawRect(
      box(bootLeft + 0.08, 2.44, 0.79, 0.07),
      fill(const Color(0xFFECEFF1)),
    );
  }

  // Şort: yan şeritli.
  final shortsRect = box(-1.0, 0.45, 2.0, 0.95);
  rrect(
    shortsRect,
    0.3,
    gradient(shortsRect, _shade(shorts, -0.1), _shade(shorts, 0.15)),
    _shade(shorts, 0.5),
  );
  canvas
    ..drawLine(
      Offset(0, r * 0.75),
      Offset(0, r * 1.38),
      line(_shade(shorts, 0.5), 0.05),
    )
    ..drawRect(box(-0.98, 0.62, 0.1, 0.6), fill(const Color(0x88FFFFFF)))
    ..drawRect(box(0.88, 0.62, 0.1, 0.6), fill(const Color(0x88FFFFFF)));

  // Kollar: kısa kollu forma + ten (kaleci: uzun kol + eldiven).
  for (final side in const [-1.0, 1.0]) {
    final left = side > 0 ? 1.0 : -1.45;
    final handColor = keeper ? const Color(0xFF76FF03) : skinColor;
    final handR = keeper ? 0.36 : 0.26;
    if (!keeper) {
      rrect(box(left, -0.5, 0.45, 0.85), 0.22, fill(skinColor), skinInk);
    }
    rrect(
      box(left, -1.3, 0.45, keeper ? 1.55 : 0.9),
      0.22,
      fill(_shade(shirt, 0.08)),
      ink,
    );
    canvas
      ..drawCircle(
        Offset(side * r * 1.22, r * 0.36),
        r * handR,
        fill(handColor),
      )
      ..drawCircle(
        Offset(side * r * 1.22, r * 0.36),
        r * handR,
        line(keeper ? const Color(0xFF33691E) : skinInk, 0.05),
      );
  }

  // Forma: ışıklı üstten koyu alta geçiş, şerit, yaka.
  final torso = box(-1.0, -1.5, 2.0, 2.2);
  rrect(
    torso,
    0.5,
    gradient(torso, _shade(shirt, -0.22), _shade(shirt, 0.12)),
    ink,
  );
  canvas.drawRect(box(-0.99, -0.45, 1.98, 0.3), fill(const Color(0x44FFFFFF)));
  // Boyun + V yaka
  canvas.drawPath(
    Path()
      ..moveTo(-r * 0.42, -r * 1.5)
      ..lineTo(0, -r * 0.95)
      ..lineTo(r * 0.42, -r * 1.5)
      ..close(),
    fill(skinColor),
  );
  canvas.drawPath(
    Path()
      ..moveTo(-r * 0.42, -r * 1.5)
      ..lineTo(0, -r * 0.95)
      ..lineTo(r * 0.42, -r * 1.5),
    line(const Color(0xFFFFFFFF), 0.09),
  );

  // Kafa
  final head = Offset(0, -r * 2.3);
  final headR = r * 1.0;
  // Kulaklar
  for (final side in const [-1.0, 1.0]) {
    final ear = head.translate(side * headR * 0.97, r * 0.1);
    canvas
      ..drawCircle(ear, r * 0.22, fill(skinColor))
      ..drawCircle(ear, r * 0.22, line(skinInk, 0.05));
  }
  canvas
    ..drawCircle(head, headR, fill(skinColor))
    ..drawCircle(head, headR, line(skinInk, 0.06));

  // Saç
  final hairInk = _shade(hairColor, 0.4);
  final top = Rect.fromCircle(center: head, radius: headR * 1.04);
  switch (hairStyle) {
    case 1: // dikenli
      canvas.drawArc(top, math.pi, math.pi, true, fill(hairColor));
      for (var i = 0; i < 5; i++) {
        final a = math.pi * (1.15 + 0.175 * i);
        final tip = head + Offset(math.cos(a), math.sin(a)) * (headR * 1.27);
        final b1 =
            head + Offset(math.cos(a - 0.2), math.sin(a - 0.2)) * (headR * 1.0);
        final b2 =
            head + Offset(math.cos(a + 0.2), math.sin(a + 0.2)) * (headR * 1.0);
        canvas.drawPath(
          Path()
            ..moveTo(b1.dx, b1.dy)
            ..lineTo(tip.dx, tip.dy)
            ..lineTo(b2.dx, b2.dy)
            ..close(),
          fill(hairColor),
        );
      }
    case 2: // kıvırcık
      canvas.drawArc(top, math.pi, math.pi, true, fill(hairColor));
      for (var i = 0; i < 7; i++) {
        final a = math.pi * (1.0 + i / 6);
        final c = head + Offset(math.cos(a), math.sin(a)) * (headR * 0.9);
        canvas.drawCircle(c, r * 0.3, fill(hairColor));
      }
    case 3: // kısa, alnı açık
      canvas.drawArc(
        Rect.fromCircle(
          center: head.translate(0, -r * 0.18),
          radius: headR * 1.03,
        ),
        math.pi * 1.02,
        math.pi * 0.96,
        true,
        fill(hairColor),
      );
    default: // kısa, kenarlı
      canvas
        ..drawArc(top, math.pi, math.pi, true, fill(hairColor))
        ..drawRect(
          Rect.fromLTWH(
            head.dx - headR * 1.03,
            head.dy - r * 0.05,
            r * 0.2,
            r * 0.4,
          ),
          fill(hairColor),
        )
        ..drawRect(
          Rect.fromLTWH(
            head.dx + headR * 1.03 - r * 0.2,
            head.dy - r * 0.05,
            r * 0.2,
            r * 0.4,
          ),
          fill(hairColor),
        );
  }
  canvas.drawArc(top, math.pi, math.pi, false, line(hairInk, 0.05));

  // Yüz: iri parlak gözler, kaşlar, yanaklar, gülümseme.
  for (final side in const [-1.0, 1.0]) {
    final eye = head.translate(side * r * 0.36, r * 0.2);
    canvas
      ..drawOval(
        Rect.fromCenter(center: eye, width: r * 0.36, height: r * 0.44),
        fill(const Color(0xFFFFFFFF)),
      )
      ..drawCircle(
        eye.translate(0, r * 0.04),
        r * 0.14,
        fill(const Color(0xFF212121)),
      )
      ..drawCircle(
        eye.translate(r * 0.05, -r * 0.04),
        r * 0.05,
        fill(const Color(0xFFFFFFFF)),
      )
      ..drawLine(
        eye.translate(-side * r * 0.12, -r * 0.3),
        eye.translate(side * r * 0.14, -r * 0.34),
        line(hairInk, 0.07),
      )
      ..drawCircle(
        head.translate(side * r * 0.62, r * 0.5),
        r * 0.15,
        fill(const Color(0x55E57373)),
      );
  }
  canvas
    ..drawArc(
      Rect.fromCenter(
        center: head.translate(0, r * 0.5),
        width: r * 0.56,
        height: r * 0.34,
      ),
      0.25,
      math.pi - 0.5,
      false,
      line(const Color(0xFF5D4037), 0.08),
    )
    ..restore();
}
