import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'core/design/app_theme.dart';
import 'core/design/app_colors.dart';
import 'features/home/home_screen.dart';
import 'features/log_entry/log_entry_screen.dart';
import 'features/stats/stats_screen.dart';
import 'features/settings/settings_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          final location = state.uri.toString();
          final showBottomBar = location.startsWith('/home') || location.startsWith('/settings') || location == '/';
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: child,
            bottomNavigationBar: showBottomBar ? _BottomNavBar(currentRoute: location) : null,
          );
        },
        routes: [
          
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        ],
      ),
      GoRoute(path: '/log/:dateEpochDay', builder: (_, state) {
        final date = int.parse(state.pathParameters['dateEpochDay']!);
        return LogEntryScreen(dateEpochDay: date);
      }),
      GoRoute(path: '/stats', builder: (_, __) => const StatsScreen()),
    ],
  );
});

class _BottomNavBar extends StatelessWidget {
  final String currentRoute;
  const _BottomNavBar({required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final isHome = currentRoute == '/' || currentRoute.startsWith('/home');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.background : const Color(0xFFFAF9FA);
    final borderColor = isDark ? AppColors.border.withValues(alpha: 0.2) : const Color(0xFFE0E0E8);
    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      padding: EdgeInsets.only(top: 6, bottom: 8 + MediaQuery.of(context).padding.bottom),
      child: Row(children: [
        Expanded(child: _navItem(Icons.date_range, '日志', isHome, () {
          if (!isHome) context.go('/home');
        })),
        Expanded(child: _navItem(Icons.settings, '设置', currentRoute.startsWith('/settings'), () {
          if (!currentRoute.startsWith('/settings')) context.go('/settings');
        })),
      ]),
    );
  }

  Widget _navItem(IconData icon, String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 22, color: selected ? AppColors.amber : AppColors.textMuted.withValues(alpha: 0.5)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: selected ? AppColors.amber : AppColors.textMuted.withValues(alpha: 0.5))),
      ]),
    );
  }
}

class HamLogApp extends ConsumerWidget {
  const HamLogApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'QSO Keeper',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      locale: const Locale('zh'),
      routerConfig: router,
    );
  }
}
