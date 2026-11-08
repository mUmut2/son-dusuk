import 'package:flutter/material.dart';

import '../../domain/social/event_models.dart';
import '../../domain/social/relationships.dart';

IconData relationIcon(Relation r) => switch (r) {
  Relation.coach => Icons.sports,
  Relation.teammates => Icons.groups,
  Relation.fans => Icons.celebration,
  Relation.family => Icons.family_restroom,
  Relation.media => Icons.mic,
};

IconData eventKindIcon(EventKind k) => switch (k) {
  EventKind.press => Icons.mic,
  EventKind.personal => Icons.person,
  EventKind.career => Icons.work_outline,
  EventKind.money => Icons.payments_outlined,
};

IconData newsIcon(NewsKind k) => switch (k) {
  NewsKind.match => Icons.sports_soccer,
  NewsKind.signed => Icons.draw,
  NewsKind.event => Icons.forum,
  NewsKind.injury => Icons.healing,
};

/// 0-100 değere göre renk: düşük kırmızı, orta nötr, yüksek yeşil.
Color relationColor(BuildContext context, double value) {
  final scheme = Theme.of(context).colorScheme;
  if (value < 30) return scheme.error;
  if (value < 55) return scheme.outline;
  return scheme.primary;
}
