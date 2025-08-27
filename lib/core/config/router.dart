// Dart SDK
import 'dart:io';

// Flutter
import 'package:flutter/material.dart';

// Third-party
import 'package:go_router/go_router.dart';

// Project
import '../utils/constants/constants.dart';
import '../utils/helper/helper.dart';
import '../utils/widgets/app_bottom_navigation_bar.dart';
import '../../features/auth/auth.dart';
import '../../features/home/home.dart';
import '../../features/post/post.dart';
import '../../features/profile/profile.dart';
import '../../features/search/search.dart';
import 'router_name.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: RouterName.splash.path,
  routes: [
    /// Splash
    GoRoute(
      path: RouterName.splash.path,
      name: RouterName.splash.name,
      onExit: (context, state) {
        FocusManager.instance.primaryFocus?.unfocus();
        return true;
      },
      pageBuilder: (BuildContext context, GoRouterState state) => MaterialPage<void>(
        key: state.pageKey,
        child: const SplashScreen(),
      ),
    ),

    /// Login
    GoRoute(
      path: RouterName.login.path,
      name: RouterName.login.name,
      onExit: (context, state) {
        FocusManager.instance.primaryFocus?.unfocus();
        return true;
      },
      pageBuilder: (context, state) {
        return SlideTransitionPage(child: LoginScreen());
      },
    ),

    /// Register
    GoRoute(
      path: RouterName.register.path,
      name: RouterName.register.name,
      onExit: (context, state) {
        FocusManager.instance.primaryFocus?.unfocus();
        return true;
      },
      pageBuilder: (context, state) {
        return SlideTransitionPage(child: RegisterScreen());
      },
    ),

    /// Bottom Nav Bar Screens
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppBottomNavigationBar(navigationShell: navigationShell);
      },
      branches: [
        /// Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouterName.home.path,
              name: RouterName.home.name,
              onExit: (context, state) {
                FocusManager.instance.primaryFocus?.unfocus();
                return true;
              },
              pageBuilder: (BuildContext context, GoRouterState state) {
                HomeScreenDataModel? screenData = state.extra as HomeScreenDataModel?;
                return NoTransitionPage<void>(
                  key: state.pageKey,
                  child: HomeScreen(
                    fileImage: screenData?.fileImage ?? File(''),
                  ),
                );
              },
            ),
          ],
        ),

        /// Search
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouterName.search.path,
              name: RouterName.search.name,
              onExit: (context, state) {
                FocusManager.instance.primaryFocus?.unfocus();
                return true;
              },
              pageBuilder: (BuildContext context, GoRouterState state) => NoTransitionPage<void>(
                key: state.pageKey,
                child: const SearchScreen(),
              ),
            ),
          ],
        ),

        /// Post Create
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouterName.postAssetPicker.path,
              name: RouterName.postAssetPicker.name,
              onExit: (context, state) {
                FocusManager.instance.primaryFocus?.unfocus();
                return true;
              },
              pageBuilder: (BuildContext context, GoRouterState state) => NoTransitionPage<void>(
                key: state.pageKey,
                child: PostAssetPickerScreen(
                  key: assetPickerScreenKey,
                ),
              ),
            ),
          ],
        ),

        /// Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouterName.profile.path,
              name: RouterName.profile.name,
              onExit: (context, state) {
                FocusManager.instance.primaryFocus?.unfocus();
                return true;
              },
              pageBuilder: (BuildContext context, GoRouterState state) => NoTransitionPage<void>(
                key: state.pageKey,
                child: const ProfileScreen(),
              ),
            ),
          ],
        ),
      ],
    ),

    /// Add Post
    GoRoute(
      path: RouterName.addPost.path,
      name: RouterName.addPost.name,
      onExit: (context, state) {
        FocusManager.instance.primaryFocus?.unfocus();
        return true;
      },
      pageBuilder: (context, state) {
        AddPostScreenDataModel screenData = state.extra as AddPostScreenDataModel;
        return SlideTransitionPage(
          child: AddPostScreen(
            selectedAssets: screenData.selectedAssets,
          ),
        );
      },
    ),

    /// Video Cover Selector
    GoRoute(
      path: RouterName.videoCoverSelector.path,
      name: RouterName.videoCoverSelector.name,
      onExit: (context, state) {
        FocusManager.instance.primaryFocus?.unfocus();
        return true;
      },
      pageBuilder: (context, state) {
        VideoCoverSelectorDataModel screenData = state.extra as VideoCoverSelectorDataModel;
        return SlideTransitionPage(
          child: VideoCoverSelector(
            covers: screenData.covers,
            videoFile: screenData.videoFile,
          ),
        );
      },
    ),

    /// Post Comment
    GoRoute(
      path: RouterName.postComment.path,
      name: RouterName.postComment.name,
      onExit: (context, state) {
        FocusManager.instance.primaryFocus?.unfocus();
        return true;
      },
      pageBuilder: (context, state) {
        CommentScreenDataModel screenData = state.extra as CommentScreenDataModel;
        return SlideUpTransitionPage(
          child: CommentScreen(
            postId: screenData.postId,
            postUserId: screenData.postUserId,
          ),
        );
      },
    ),

    /// Liked By User
    GoRoute(
      path: RouterName.likedByUsers.path,
      name: RouterName.likedByUsers.name,
      onExit: (context, state) {
        FocusManager.instance.primaryFocus?.unfocus();
        return true;
      },
      pageBuilder: (context, state) {
        LikedByUserScreenDataModel screenData = state.extra as LikedByUserScreenDataModel;
        return SlideUpTransitionPage(
          child: LikedByUserScreen(
            postId: screenData.postId,
          ),
        );
      },
    ),

    /// Profile for Other User
    GoRoute(
      path: RouterName.otherUserProfile.path,
      name: RouterName.otherUserProfile.name,
      onExit: (context, state) {
        FocusManager.instance.primaryFocus?.unfocus();
        return true;
      },
      pageBuilder: (context, state) {
        ProfileScreenDataModel screenData = state.extra as ProfileScreenDataModel;
        return SlideTransitionPage(
          child: ProfileScreen(
            userId: screenData.userId,
          ),
        );
      },
    ),

    /// Post Lists
    GoRoute(
      path: RouterName.postLists.path,
      name: RouterName.postLists.name,
      onExit: (context, state) {
        FocusManager.instance.primaryFocus?.unfocus();
        return true;
      },
      pageBuilder: (context, state) {
        PostListScreenDataModel screenData = state.extra as PostListScreenDataModel;
        return SlideTransitionPage(
          child: PostListScreen(
            postListNavigation: screenData.postListNavigation,
            index: screenData.index,
          ),
        );
      },
    ),

    /// Follow Section
    GoRoute(
      path: RouterName.followSection.path,
      name: RouterName.followSection.name,
      onExit: (context, state) {
        FocusManager.instance.primaryFocus?.unfocus();
        return true;
      },
      pageBuilder: (context, state) {
        FollowSectionScreenDataModel screenData = state.extra as FollowSectionScreenDataModel;
        return SlideTransitionPage(
          child: FollowSectionScreen(
            userId: screenData.userId,
            tabIndex: screenData.tabIndex,
            userName: screenData.userName,
          ),
        );
      },
    ),

    /// Profile Edit
    GoRoute(
      path: RouterName.profileEdit.path,
      name: RouterName.profileEdit.name,
      onExit: (context, state) {
        FocusManager.instance.primaryFocus?.unfocus();
        return true;
      },
      pageBuilder: (context, state) {
        final ProfileEditScreenDataModel screenData = state.extra as ProfileEditScreenDataModel;
        return SlideTransitionPage(
          child: ProfileEditScreen(
            userData: screenData.userData,
          ),
        );
      },
    ),
  ],
);
