import 'contract.dart';

enum OfferKind {
  /// Başka bir kulüpten transfer teklifi (ya da serbest oyuncuya teklif).
  transfer,

  /// Mevcut kulübün sözleşme uzatma teklifi.
  renewal,
}

/// Bir kulübün oyuncuya sunduğu sözleşme. [maxWage] GİZLİDİR: kulübün
/// pazarlıkta çıkabileceği üst sınırdır, arayüzde gösterilmez.
class TransferOffer {
  const TransferOffer({
    required this.kind,
    required this.clubId,
    required this.weeklyWage,
    required this.maxWage,
    required this.years,
    required this.role,
    required this.expiresAt,
    this.negotiated = false,
  });

  factory TransferOffer.fromJson(Map<String, dynamic> json) => TransferOffer(
    kind: OfferKind.values.byName(json['kind'] as String),
    clubId: json['clubId'] as String,
    weeklyWage: json['weeklyWage'] as int,
    maxWage: json['maxWage'] as int,
    years: json['years'] as int,
    role: SquadRole.values.byName(json['role'] as String),
    expiresAt: json['expiresAt'] as int,
    negotiated: json['negotiated'] as bool? ?? false,
  );

  final OfferKind kind;
  final String clubId;
  final int weeklyWage;
  final int maxWage;
  final int years;
  final SquadRole role;

  /// Son geçerli mutlak hafta numarası (bkz. `CareerState.absoluteWeek`).
  final int expiresAt;

  /// Pazarlık hakkı bir kez kullanılır.
  final bool negotiated;

  TransferOffer copyWith({bool? negotiated}) => TransferOffer(
    kind: kind,
    clubId: clubId,
    weeklyWage: weeklyWage,
    maxWage: maxWage,
    years: years,
    role: role,
    expiresAt: expiresAt,
    negotiated: negotiated ?? this.negotiated,
  );

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    'clubId': clubId,
    'weeklyWage': weeklyWage,
    'maxWage': maxWage,
    'years': years,
    'role': role.name,
    'expiresAt': expiresAt,
    'negotiated': negotiated,
  };
}
