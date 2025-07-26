import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/authScreens/login_screen.dart';
import '../screens/authScreens/splash_screen.dart';
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
      pageBuilder: (BuildContext context, GoRouterState state) =>
          MaterialPage<void>(
        key: state.pageKey,
        child: const LoginScreen(),
      ),
    ),

    // StatefulShellRoute.indexedStack(
    //   builder: (context, state, navigationShell) {
    //     return AppBottomNavigationBar(navigationShell: navigationShell);
    //   },
    //   branches: [
    //     StatefulShellBranch(
    //       routes: [
    //         GoRoute(
    //           path: RouterName.dashboard.path,
    //           name: RouterName.dashboard.name,
    //           pageBuilder: (BuildContext context, GoRouterState state) =>
    //               NoTransitionPage<void>(
    //             key: state.pageKey,
    //             child: const DashboardScreen(),
    //           ),
    //         ),
    //       ],
    //     ),
    //     StatefulShellBranch(
    //       routes: [
    //         GoRoute(
    //           path: RouterName.member.path,
    //           name: RouterName.member.name,
    //           pageBuilder: (BuildContext context, GoRouterState state) {
    //             final MembersScreenDataModel data =
    //                 state.extra as MembersScreenDataModel? ??
    //                     MembersScreenDataModel();
    //             return NoTransitionPage<void>(
    //               key: state.pageKey,
    //               child: MembersScreen(
    //                 onBack: () => context.go(RouterName.dashboard.path),
    //                 pageIndex: data.pageIndex,
    //               ),
    //             );
    //           },
    //         ),
    //       ],
    //     ),
    //     StatefulShellBranch(
    //       routes: [
    //         GoRoute(
    //           path: RouterName.addPost.path,
    //           name: RouterName.addPost.name,
    //           pageBuilder: (BuildContext context, GoRouterState state) =>
    //               NoTransitionPage<void>(
    //             key: state.pageKey,
    //             child: AddPostScreen(
    //               key: addPostKey,
    //               onBack: () => context.go(RouterName.dashboard.path),
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //     StatefulShellBranch(
    //       routes: [
    //         GoRoute(
    //           path: RouterName.community.path,
    //           name: RouterName.community.name,
    //           pageBuilder: (BuildContext context, GoRouterState state) {
    //             final CommunityScreenDataModel? data =
    //                 state.extra as CommunityScreenDataModel?;
    //             logInfo(message: 'CommunityScreenDataModel ${data?.tabIndex}');
    //             logInfo(
    //                 message:
    //                     'CommunityScreenDataModel ${data?.showUploadFile}');
    //             return NoTransitionPage<void>(
    //               key: state.pageKey,
    //               child: CommunityScreen(
    //                 onBack: () => context.go(RouterName.dashboard.path),
    //                 tabIndex: data?.tabIndex ?? 0,
    //                 showUploadFile: data?.showUploadFile,
    //               ),
    //             );
    //           },
    //         ),
    //       ],
    //     ),
    //     StatefulShellBranch(
    //       routes: [
    //         GoRoute(
    //           path: RouterName.profile.path,
    //           name: RouterName.profile.name,
    //           pageBuilder: (BuildContext context, GoRouterState state) =>
    //               NoTransitionPage<void>(
    //             key: state.pageKey,
    //             child: ProfileScreen(
    //               onBack: () => context.go(RouterName.dashboard.path),
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ],
    // ),
  ],
);
