import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pictora/screens/addPostScreens/add_post_screen.dart';
import 'package:pictora/screens/authScreens/register_screen.dart';
import 'package:pictora/screens/homeScreens/home_screen.dart';
import 'package:pictora/screens/searchScreens/search_screen.dart';
import 'package:pictora/utils/helper/page_transition.dart';
import '../screens/authScreens/login_screen.dart';
import '../screens/authScreens/splash_screen.dart';
import '../screens/profileScreens/profile_screen.dart';
import '../screens/widgets/app_bottom_navigation_bar.dart';
import 'router_name.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouterName.splash.path,
  routes: [
    GoRoute(
      path: RouterName.splash.path,
      name: RouterName.splash.name,
      pageBuilder: (BuildContext context, GoRouterState state) =>
          MaterialPage<void>(
        key: state.pageKey,
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: RouterName.login.path,
      name: RouterName.login.name,
      pageBuilder: (context, state) {
        return SlideTransitionPage(child: LoginScreen());
      },
    ),
    GoRoute(
      path: RouterName.register.path,
      name: RouterName.register.name,
      pageBuilder: (context, state) {
        return SlideTransitionPage(child: RegisterScreen());
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppBottomNavigationBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouterName.home.path,
              name: RouterName.home.name,
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  NoTransitionPage<void>(
                key: state.pageKey,
                child: const HomeScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouterName.search.path,
              name: RouterName.search.name,
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  NoTransitionPage<void>(
                key: state.pageKey,
                child: const SearchScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouterName.addPost.path,
              name: RouterName.addPost.name,
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  NoTransitionPage<void>(
                key: state.pageKey,
                child: const AddPostScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouterName.profile.path,
              name: RouterName.profile.name,
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  NoTransitionPage<void>(
                key: state.pageKey,
                child: const ProfileScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
