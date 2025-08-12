import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pictora/features/auth/screens/register_screen.dart';
import 'package:pictora/features/home/screens/home_screen.dart';
import 'package:pictora/features/post/screens/add_post_screen.dart';
import 'package:pictora/features/post/screens/comment_screen.dart';
import 'package:pictora/features/post/screens/liked_by_user_screen.dart';
import 'package:pictora/features/post/screens/post_asset_picker_screen.dart';
import 'package:pictora/features/post/screens/post_list_screen.dart';
import 'package:pictora/features/profile/screens/follow_section_screen.dart';
import 'package:pictora/features/search/screens/search_screen.dart';
import 'package:pictora/utils/helper/page_transition.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/post/screens/video_cover_selector_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/widgets/app_bottom_navigation_bar.dart';
import '../utils/constants/screens_keys.dart';
import 'router_name.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouterName.splash.path,
  routes: [
    GoRoute(
      path: RouterName.splash.path,
      name: RouterName.splash.name,
      pageBuilder: (BuildContext context, GoRouterState state) => MaterialPage<void>(
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
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouterName.search.path,
              name: RouterName.search.name,
              pageBuilder: (BuildContext context, GoRouterState state) => NoTransitionPage<void>(
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
              pageBuilder: (BuildContext context, GoRouterState state) => NoTransitionPage<void>(
                key: state.pageKey,
                child: PostAssetPickerScreen(
                  key: assetPickerScreenKey,
                ),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouterName.profile.path,
              name: RouterName.profile.name,
              pageBuilder: (BuildContext context, GoRouterState state) => NoTransitionPage<void>(
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
        AddPostScreenDataModel screenData = state.extra as AddPostScreenDataModel;
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
        VideoCoverSelectorDataModel screenData = state.extra as VideoCoverSelectorDataModel;
        return SlideTransitionPage(
          child: VideoCoverSelector(
            covers: screenData.covers,
            videoFile: screenData.videoFile,
          ),
        );
      },
    ),
    GoRoute(
      path: RouterName.postComment.path,
      name: RouterName.postComment.name,
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
    GoRoute(
      path: RouterName.likedByUsers.path,
      name: RouterName.likedByUsers.name,
      pageBuilder: (context, state) {
        LikedByUserScreenDataModel screenData = state.extra as LikedByUserScreenDataModel;
        return SlideUpTransitionPage(
          child: LikedByUserScreen(
            postId: screenData.postId,
          ),
        );
      },
    ),
    GoRoute(
      path: RouterName.otherUserProfile.path,
      name: RouterName.otherUserProfile.name,
      pageBuilder: (context, state) {
        ProfileScreenDataModel screenData = state.extra as ProfileScreenDataModel;
        return SlideTransitionPage(
          child: ProfileScreen(
            userId: screenData.userId,
          ),
        );
      },
    ),
    GoRoute(
      path: RouterName.postLists.path,
      name: RouterName.postLists.name,
      pageBuilder: (context, state) {
        PostListScreenDataModel screenData = state.extra as PostListScreenDataModel;
        return SlideTransitionPage(
          child: PostListScreen(
            postsData: screenData.postData,
            index: screenData.index,
          ),
        );
      },
    ),
    GoRoute(
      path: RouterName.followSection.path,
      name: RouterName.followSection.name,
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
  ],
);
