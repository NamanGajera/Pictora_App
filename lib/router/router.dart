import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pictora/features/post/screens/add_post_screen.dart';
import 'package:pictora/features/post/screens/post_asset_picker_screen.dart';
import 'package:pictora/features/auth/screens/register_screen.dart';
import 'package:pictora/features/home/screens/home_screen.dart';
import 'package:pictora/features/search/screens/search_screen.dart';
import 'package:pictora/utils/helper/page_transition.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/post/screens/video_cover_selector_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/widgets/app_bottom_navigation_bar.dart';
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
              path: RouterName.postAssetPicker.path,
              name: RouterName.postAssetPicker.name,
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  NoTransitionPage<void>(
                key: state.pageKey,
                child: const PostAssetPickerScreen(),
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
    GoRoute(
      path: RouterName.addPost.path,
      name: RouterName.addPost.name,
      pageBuilder: (context, state) {
        AddPostScreenDataModel screenData =
            state.extra as AddPostScreenDataModel;
        return SlideTransitionPage(
          child: AddPostScreen(
            selectedAssets: screenData.selectedAssets,
          ),
        );
      },
    ),
    GoRoute(
      path: RouterName.videoCoverSelector.path,
      name: RouterName.videoCoverSelector.name,
      pageBuilder: (context, state) {
        VideoCoverSelectorDataModel screenData =
            state.extra as VideoCoverSelectorDataModel;
        return SlideTransitionPage(
          child: VideoCoverSelector(
            covers: screenData.covers,
            videoFile: screenData.videoFile,
          ),
        );
      },
    ),
  ],
);
