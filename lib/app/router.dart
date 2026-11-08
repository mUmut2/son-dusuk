import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/create/create_player_screen.dart';
import '../presentation/game/game_shell.dart';
import '../presentation/game/home_tab.dart';
import '../presentation/game/profile_tab.dart';
import '../presentation/match/match_screen.dart';
import '../presentation/menu/main_menu_screen.dart';
import '../presentation/providers.dart';
import '../presentation/settings/settings_screen.dart';
import '../presentation/simulator/season_simulator_screen.dart';
import 'l10n/app_localizations.dart';

/// Uygulamanın tek yönlendirme noktası. Yeni ekranlar buraya eklenir.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    redirect: (context, state) {
      final inGame = state.matchedLocation.startsWith('/game');
      if (inGame && ref.read(activeCareerProvider) == null) return '/';
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
                builder: (context, state) => PlaceholderTab(
                  title: AppLocalizations.of(context).navTraining,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/game/club',
                builder: (context, state) =>
                    PlaceholderTab(title: AppLocalizations.of(context).navClub),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/game/social',
                builder: (context, state) => PlaceholderTab(
                  title: AppLocalizations.of(context).navSocial,
                ),
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
