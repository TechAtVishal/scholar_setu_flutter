import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/language_select_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/schemes_screen.dart';
import 'screens/scheme_detail_screen.dart';
import 'screens/eligibility_screen.dart';
import 'screens/application_form_screen.dart';
import 'screens/documents_screen.dart';
import 'screens/track_screen.dart';
import 'screens/application_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/grievance_screen.dart';
import 'screens/officer_dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/main_shell_screen.dart';
import 'models/scheme_model.dart';
import 'models/application_model.dart';
import 'providers/app_provider.dart';

class AppRouter {
  static GoRouter createRouter(AppProvider appProvider) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: appProvider,
      routes: [
        GoRoute(path: '/splash', builder: (ctx, state) => const SplashScreen()),
        GoRoute(path: '/language', builder: (ctx, state) => const LanguageSelectScreen()),
        GoRoute(path: '/login', builder: (ctx, state) => const LoginScreen()),
        ShellRoute(
          builder: (ctx, state, child) => MainShellScreen(child: child),
          routes: [
            GoRoute(path: '/home', builder: (ctx, state) => const HomeScreen()),
            GoRoute(path: '/schemes', builder: (ctx, state) => const SchemesScreen()),
            GoRoute(path: '/track', builder: (ctx, state) => const TrackScreen()),
            GoRoute(path: '/profile', builder: (ctx, state) => const ProfileScreen()),
          ],
        ),
        GoRoute(
          path: '/scheme-detail',
          builder: (ctx, state) {
            final scheme = state.extra as SchemeModel;
            return SchemeDetailScreen(scheme: scheme);
          },
        ),
        GoRoute(path: '/eligibility', builder: (ctx, state) => const EligibilityScreen()),
        GoRoute(
          path: '/apply',
          builder: (ctx, state) {
            final scheme = state.extra as SchemeModel;
            return ApplicationFormScreen(scheme: scheme);
          },
        ),
        GoRoute(path: '/documents', builder: (ctx, state) => const DocumentsScreen()),
        GoRoute(
          path: '/application-detail',
          builder: (ctx, state) {
            final app = state.extra as ApplicationModel;
            return ApplicationDetailScreen(application: app);
          },
        ),
        GoRoute(path: '/notifications', builder: (ctx, state) => const NotificationsScreen()),
        GoRoute(path: '/chatbot', builder: (ctx, state) => const ChatbotScreen()),
        GoRoute(path: '/grievance', builder: (ctx, state) => const GrievanceScreen()),
        GoRoute(path: '/officer', builder: (ctx, state) => const OfficerDashboardScreen()),
        GoRoute(path: '/settings', builder: (ctx, state) => const SettingsScreen()),
      ],
      redirect: (ctx, state) {
        final auth = appProvider.isAuthenticated;
        final goingToAuth = ['/splash', '/language', '/login'].contains(state.matchedLocation);
        
        if (!auth && !goingToAuth) {
          return '/splash';
        }
        
        return null;
      },
    );
  }
}
