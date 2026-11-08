import '../../core/game_random.dart';
import '../club/club_balance.dart';
import '../club/contract.dart';
import '../club/squad.dart';
import '../club/transfer_market.dart';
import '../league/club_world.dart';
import '../player/player.dart';
import 'career_state.dart';

/// Yeni kariyer ve eski kayıtları kulüp sistemine bağlama.
abstract final class CareerFactory {
  /// Yeni kariyer: rastgele bir dünya, amatör ligde bir kulüp ve ilk sözleşme.
  static CareerState create(Player player, GameRandom random) =>
      assignClub(CareerState(player: player), random.nextInt(1 << 30) + 1);

  /// [worldSeed] dünyasında amatör bir kulüp ve başlangıç sözleşmesi verir.
  static CareerState assignClub(CareerState state, int worldSeed) {
    final world = ClubWorld(worldSeed);
    final club = world.startingClub(GameRandom(worldSeed));
    final role = Squad.roleOrProspect(state.player, club);
    final wage = TransferMarket.fairWage(
      tier: world.tierOf(club.id),
      player: state.player,
      role: role,
    );
    return state.copyWith(
      worldSeed: worldSeed,
      contract: Contract(
        clubId: club.id,
        weeklyWage: wage.round(),
        endSeason: state.season + ClubBalance.startingContractYears - 1,
        role: role,
      ),
    );
  }
}
