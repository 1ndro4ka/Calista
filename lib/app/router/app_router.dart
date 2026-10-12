import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';

import '../../features/home/presentation/pages/home_page.dart';
import '../../features/projects/presentation/pages/create_project_page.dart';
import '../../features/projects/presentation/pages/edit_project_page.dart';
import '../../features/projects/presentation/pages/my_projects_page.dart';
import '../../features/projects/presentation/pages/project_details_page.dart';

import '../../features/applications/presentation/pages/applications_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';

import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

import '../../features/shell/presentation/pages/main_navigation_shell.dart';
import '../providers/app_providers.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _myProjectsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'myProjects');
final _applicationsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'applications');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

final goRouterProvider = Provider<GoRouter>((ref) {
  // Listen to auth state changes to trigger router re-evaluation
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final user = authState.value;
      final isAuth = user != null;
      final location = state.matchedLocation;

      final isSplash = location == '/';
      final isAuthRoute = location == '/login' ||
          location == '/register' ||
          location == '/forgot-password';

      if (isSplash) return null;

      if (!isAuth && !isAuthRoute) {
        return '/login';
      }

      if (isAuth && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),

      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // Stateful Bottom Navigation Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),

          // Branch 1: My Projects
          StatefulShellBranch(
            navigatorKey: _myProjectsNavigatorKey,
            routes: [
              GoRoute(
                path: '/my-projects',
                builder: (context, state) => const MyProjectsPage(),
              ),
            ],
          ),

          // Branch 2: Applications
          StatefulShellBranch(
            navigatorKey: _applicationsNavigatorKey,
            routes: [
              GoRoute(
                path: '/applications',
                builder: (context, state) => const ApplicationsPage(),
              ),
            ],
          ),

          // Branch 3: Profile
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // Details, Create, Edit, Notifications Routes (Pushed above bottom shell)
      GoRoute(
        path: '/project/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProjectDetailsPage(projectId: id);
        },
      ),
      GoRoute(
        path: '/project/:id/edit',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EditProjectPage(projectId: id);
        },
      ),
      GoRoute(
        path: '/create-project',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CreateProjectPage(),
      ),
      GoRoute(
        path: '/edit-profile',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NotificationsPage(),
      ),
    ],
  );
});
