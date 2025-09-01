// reels_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/core/utils/constants/bloc_instances.dart';
import 'package:pictora/core/utils/extensions/build_context_extension.dart';

import '../../bloc/post_bloc.dart';
import '../widgets/reel_display.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    postBloc.add(GetAllReelsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          final reelData = state.reelsData ?? [];

          if (reelData.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          }

          // for (int i = 0; i < 5; i++) {
          //   final nextUrl = reelData[i + 1].mediaData?[0].mediaUrl;
          //   if (nextUrl != null) {
          //     VideoControllerManager.getController(nextUrl);
          //   }
          // }

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: reelData.length,
            physics: const ClampingScrollPhysics(),
            onPageChanged: (index) {
              if (index + 1 < reelData.length) {
                final nextUrl = reelData[index + 1].mediaData?[0].mediaUrl;
                if (nextUrl != null) {
                  VideoControllerManager.getController(nextUrl);
                }
              }
            },
            itemBuilder: (context, index) {
              final reel = reelData[index];
              return SizedBox(
                height: context.screenHeight,
                width: context.screenWidth,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ReelsMediaDisplay(
                        mediaData: reel.mediaData,
                        postId: reel.id ?? '',
                        isLike: reel.isLiked ?? false,
                        key: PageStorageKey(reel.id),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
