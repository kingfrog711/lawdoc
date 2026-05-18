import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'l10n/strings.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/chat/tanya_dulu_screen.dart';
import 'screens/lawyers/browse_lawyers_screen.dart';
import 'screens/lawyers/lawyer_profile_screen.dart';
import 'screens/pro_bono/pro_bono_screen.dart';
import 'screens/knowledge/knowledge_base_screen.dart';
import 'theme/theme.dart';
import 'widgets/shell_scaffold.dart';

final _router = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (_, __) => const OnboardingScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => ShellScaffold(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/chat', builder: (_, __) => const TanyaDuluScreen()),
        GoRoute(path: '/lawyers', builder: (_, __) => const BrowseLawyersScreen()),
        GoRoute(
          path: '/lawyers/:id',
          builder: (_, state) =>
              LawyerProfileScreen(lawyerId: state.pathParameters['id']!),
        ),
        GoRoute(path: '/pro-bono', builder: (_, __) => const ProBonoScreen()),
        GoRoute(path: '/knowledge', builder: (_, __) => const KnowledgeBaseScreen()),
      ],
    ),
  ],
);

class LawDocApp extends StatelessWidget {
  const LawDocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: langIsId,
      builder: (context, _, __) => MaterialApp.router(
        title: 'LawDoc',
        theme: AppTheme.light,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
