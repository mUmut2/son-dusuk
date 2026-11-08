/// Birkaç tam sayıdan kararlı (platformdan bağımsız) bir seed üretir.
/// `Object.hash` yerine bunu kullanırız: web ve mobilde aynı sonucu verir.
int mixSeed(List<int> parts) {
  var h = 17;
  for (final p in parts) {
    h = (h * 31 + (p & 0xFFFFFF) + 7) & 0x3FFFFFFF;
    h = (h ^ (h >> 11)) & 0x3FFFFFFF;
  }
  return h;
}
