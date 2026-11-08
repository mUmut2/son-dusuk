/// Bir takımın puan durumu satırı.
class StandingsRow {
  StandingsRow(this.teamId);

  final String teamId;
  int played = 0;
  int won = 0;
  int drawn = 0;
  int lost = 0;
  int goalsFor = 0;
  int goalsAgainst = 0;

  int get goalDifference => goalsFor - goalsAgainst;
  int get points => won * 3 + drawn;

  void _add(int scored, int conceded) {
    played++;
    goalsFor += scored;
    goalsAgainst += conceded;
    if (scored > conceded) {
      won++;
    } else if (scored == conceded) {
      drawn++;
    } else {
      lost++;
    }
  }
}

/// Puan durumu. Sıralama: puan, averaj, atılan gol, sonra takım kimliği
/// (deterministik olması için).
class Standings {
  Standings(Iterable<String> teamIds)
    : _rows = {for (final id in teamIds) id: StandingsRow(id)};

  final Map<String, StandingsRow> _rows;

  void record(String homeId, String awayId, int homeGoals, int awayGoals) {
    _rows[homeId]!._add(homeGoals, awayGoals);
    _rows[awayId]!._add(awayGoals, homeGoals);
  }

  StandingsRow row(String teamId) => _rows[teamId]!;

  List<StandingsRow> get sorted {
    final list = _rows.values.toList()
      ..sort((a, b) {
        final byPoints = b.points.compareTo(a.points);
        if (byPoints != 0) return byPoints;
        final byGd = b.goalDifference.compareTo(a.goalDifference);
        if (byGd != 0) return byGd;
        final byGf = b.goalsFor.compareTo(a.goalsFor);
        if (byGf != 0) return byGf;
        return a.teamId.compareTo(b.teamId);
      });
    return list;
  }
}
