import 'package:go_router/go_router.dart';

import '../presentation/home/home_screen.dart';

/// Uygulamanın tek yönlendirme noktası. Yeni ekranlar buraya eklenir.
final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
