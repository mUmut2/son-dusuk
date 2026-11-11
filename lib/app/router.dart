import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/achievements/achievements_screen.dart';
import '../presentation/create/create_player_screen.dart';
import '../presentation/equipment/equipment_screen.dart';
import '../presentation/spending/spending_screen.dart';
import '../presentation/game/club_tab.dart';
import '../presentation/game/game_shell.dart';
import '../presentation/game/home_tab.dart';
import '../presentation/game/profile_tab.dart';
import '../presentation/game/training_tab.dart';
import '../presentation/game/week_summary_screen.dart';
import '../presentation/match/match_screen.dart';
import '../presentation/menu/main_menu_screen.dart';
import '../presentation/national/national_screen.dart';
import '../presentation/providers.dart';
import '../presentation/settings/settings_screen.dart';
import '../presentation/social/event_screen.dart';
import '../presentation/social/social_tab.dart';
import '../presentation/simulator/season_simulator_screen.dart';
import '../presentation/summary/career_summary_screen.dart';

/// Uygulamanın tek yönlendirme noktası. Yeni ekranlar buraya eklenir.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    redirect: (context, state) {
      final inGame = state.matchedLocation.startsWith('/game');
      final career = ref.read(activeCareerProvider);
      if (inGame && career == null) return '/';
      // Emekli kariyerde yalnızca özet, hafta sonucu ve başarımlar açılır.
      if (inGame && career != null && career.state.retired) {
        const open = {'/game/summary', '/game/week', '/game/achievements'};
        if (!open.contains(state.matchedLocation)) return '/game/summary';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const MainMenuScreen()),
      GoRoute(
        path: '/create/:slot',
        builder: (context, state) => CreatePlayerScreen(
          slot: int.tryParse(state.pathParameters['slot'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        path: '/game/match',
        builder: (context, state) => const MatchScreen(),
      ),
      GoRoute(
        path: '/game/week',
        builder: (context, state) => const WeekSummaryScreen(),
      ),
      GoRoute(
        path: '/game/event/:id',
        builder: (context, state) =>
            EventScreen(eventId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/game/national',
        builder: (context, state) => const NationalScreen(),
      ),
      GoRoute(
        path: '/game/equipment',
        builder: (context, state) => const EquipmentScreen(),
      ),
      GoRoute(
        path: '/game/spending',
        builder: (context, state) => const SpendingScreen(),
      ),
      GoRoute(
        path: '/game/achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/game/summary',
        builder: (context, state) => const CareerSummaryScreen(),
      ),
      GoRoute(
        path: '/simulator',
        builder: (context, state) => const SeasonSimulatorScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => GameShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/game',
                builder: (context, state) => const HomeTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/game/training',
                builder: (context, state) => const TrainingTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/game/club',
                builder: (context, state) => const ClubTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/game/social',
                builder: (context, state) => const SocialTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/game/profile',
                builder: (context, state) => const ProfileTab(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
