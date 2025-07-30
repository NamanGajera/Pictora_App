import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/features/post/bloc/post_bloc.dart';
import 'package:pictora/utils/extensions/widget_extension.dart';
import 'package:pinch_zoom_release_unzoom/pinch_zoom_release_unzoom.dart';

import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../utils/constants/app_assets.dart';
import '../../../../utils/services/custom_logger.dart';
import '../../models/post_data.dart';
import 'heart_animation.dart';

class PostMediaDisplay extends StatefulWidget {
  final List<MediaData>? mediaData;
  final String postId;

  const PostMediaDisplay({
    super.key,
    required this.mediaData,
    required this.postId,
  });

  @override
  State<PostMediaDisplay> createState() => _PostMediaDisplayState();
}

class _PostMediaDisplayState extends State<PostMediaDisplay> {
  late bool hasVideos;
  Map<String, VideoPlayerController> videoControllers = {};
  Map<String, bool> isInitialized = {};
  Map<String, bool> isPlaying = {};
  Map<String, ValueNotifier<bool>> isLikedNotifierAnimation = {};
  int currentPage = 0;
  PageController controller = PageController();

  @override
  void initState() {
    super.initState();
    _initializeMedia();

    isLikedNotifierAnimation[widget.postId] = ValueNotifier<bool>(false);
  }

  void _initializeMedia() {
    // Get all media items from postMappings
    final mediaItems = widget.mediaData;
    hasVideos = false;

    if ((mediaItems ?? []).isNotEmpty) {
      for (var i = 0; i < (mediaItems ?? []).length; i++) {
        final fileUrl = '${mediaItems?[i].mediaUrl}';
        if (VideoExtension(fileUrl).isVideoUrl) {
          final videoKey = '${widget.postId}_$i';
          videoControllers[videoKey] =
              VideoPlayerController.networkUrl(Uri.parse(fileUrl));
          isInitialized[videoKey] = false;
          isPlaying[videoKey] = false;
          hasVideos = true;

          _initializeVideoController(videoKey);
        }
      }
    }
  }

  void _initializeVideoController(String key) async {
    try {
      await videoControllers[key]?.initialize();
      if (mounted) {
        setState(() {
          isInitialized[key] = true;
        });
      }
    } catch (e) {
      logInfo(message: "Error initializing video controller: $e");
      // Handle initialization error
      if (mounted) {
        setState(() {
          isInitialized[key] = false;
        });
      }
    }
  }

  void _togglePlay(String videoKey) {
    if (videoControllers[videoKey] != null) {
      setState(() {
        if (videoControllers[videoKey]!.value.isPlaying) {
          videoControllers[videoKey]!.pause();
          isPlaying[videoKey] = false;
        } else {
          // Pause all other videos first
          videoControllers.forEach((key, controller) {
            if (key != videoKey && controller.value.isPlaying) {
              controller.pause();
              isPlaying[key] = false;
            }
          });

          videoControllers[videoKey]!.play();
          isPlaying[videoKey] = true;
        }
      });
    }
  }

  @override
  void dispose() {
    videoControllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  void _handleDoubleTap() {
    isLikedNotifierAnimation[widget.postId]?.value = true;
    // communityBloc.add(TogglePostLikeEvent(
    //     isLike: !(widget.communityPostData[widget.index].isLiked ?? false),
    //     postId: postId ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    final postMappings = widget.mediaData;

    List<Map<String, dynamic>> mediaItems = [];

    for (var i = 0; i < (postMappings ?? []).length; i++) {
      final fileUrl = '${postMappings?[i].mediaUrl}';

      if (VideoExtension(fileUrl).isVideoUrl) {
        mediaItems.add({
          'type': 'video',
          'url': fileUrl,
          'key': '${widget.postId}_$i',
        });
      } else {
        // It's an image
        mediaItems.add({
          'type': 'image',
          'url': fileUrl,
        });
      }
    }

    if (mediaItems.isEmpty) {
      return Container();
    }

    return VisibilityDetector(
      key: Key('video-${widget.postId}'),
      onVisibilityChanged: (info) {
        final currentMedia =
            mediaItems.isNotEmpty ? mediaItems[currentPage] : null;

        if (currentMedia != null && currentMedia['type'] == 'video') {
          final videoKey = currentMedia['key'];

          if (info.visibleFraction > 0.9) {
            logWarn(
                message: 'Post ${widget.postId} is visible - playing video');
            if (videoControllers[videoKey] != null &&
                !videoControllers[videoKey]!.value.isPlaying) {
              videoControllers.forEach((key, controller) {
                if (key != videoKey && controller.value.isPlaying) {
                  controller.pause();
                  isPlaying[key] = false;
                }
              });

              videoControllers[videoKey]!.play();
              isPlaying[videoKey] = true;
            }
          } else {
            logWarn(
                message:
                    'Post ${widget.postId} is not visible - pausing video');
            if (videoControllers[videoKey] != null &&
                videoControllers[videoKey]!.value.isPlaying) {
              videoControllers[videoKey]!.pause();
              isPlaying[videoKey] = false;
            }
          }
        }
      },
      child: GestureDetector(
        onDoubleTap: _handleDoubleTap,
        child: Container(
          height: 260,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              BlocBuilder<PostBloc, PostState>(
                builder: (context, state) {
                  return PageView.builder(
                    key: PageStorageKey(widget.postId),
                    controller: controller,
                    // physics: state.blockScroll
                    //     ? const NeverScrollableScrollPhysics()
                    //     : null,
                    onPageChanged: (value) {
                      setState(() {
                        currentPage = value;
                      });
                    },
                    itemBuilder: (context, index) {
                      final mediaItem = mediaItems[index];

                      return MediaPageItem(
                        mediaItem: mediaItem,
                        videoControllers: videoControllers,
                        isInitialized: isInitialized,
                        onTogglePlay: _togglePlay,
                      );
                    },
                    itemCount: mediaItems.length,
                  );
                },
              ),

              // Counter indicator

              if (mediaItems.length > 1)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${currentPage + 1}/${mediaItems.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

              if (mediaItems.length > 1)
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      mediaItems.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: currentPage == index ? 8 : 6,
                        height: currentPage == index ? 8 : 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentPage == index
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                ),

              // Heart animation overlay
              Positioned.fill(
                child: Center(
                  child: ValueListenableBuilder(
                    valueListenable: isLikedNotifierAnimation[widget.postId] ??
                        ValueNotifier(false),
                    builder: (BuildContext context, bool value, Widget? child) {
                      return Opacity(
                        opacity: value ? 1 : 0,
                        child: HeartAnimationWidget(
                          isAnimating: value,
                          duration: const Duration(milliseconds: 400),
                          onEnd: () {
                            if (isLikedNotifierAnimation
                                .containsKey(widget.postId)) {
                              isLikedNotifierAnimation[widget.postId]!.value =
                                  false;
                            }
                          },
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 90,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MediaPageItem extends StatefulWidget {
  final Map<String, dynamic> mediaItem;
  final Map<String, VideoPlayerController> videoControllers;
  final Map<String, bool> isInitialized;
  final Function(String) onTogglePlay;

  const MediaPageItem({
    super.key,
    required this.mediaItem,
    required this.videoControllers,
    required this.isInitialized,
    required this.onTogglePlay,
  });

  @override
  State<MediaPageItem> createState() => _MediaPageItemState();
}

class _MediaPageItemState extends State<MediaPageItem>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Handle the tap on media item
    Widget mediaContent;

    if (widget.mediaItem['type'] == 'video') {
      final videoKey = widget.mediaItem['key'];
      mediaContent = GestureDetector(
        onTap: () => widget.onTogglePlay(videoKey),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: CustomVideoPlayer(
            videoController: widget.videoControllers[videoKey]!,
            isInitialize: widget.isInitialized[videoKey] ?? false,
          ).withAutomaticKeepAlive(),
        ),
      );
    } else {
      // Image content
      mediaContent = ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: FadeInImage.assetNetwork(
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: AppAssets.appLogo,
          placeholderFit: BoxFit.fitHeight,
          image: widget.mediaItem['url'],
          imageErrorBuilder: ((context, error, stackTrace) {
            return Image.asset(AppAssets.appLogo);
          }),
        ),
      );
    }

    // Wrap individual media item with zoom
    return PinchZoomReleaseUnzoomWidget(
      twoFingersOn: () {
        // communityBloc.add(BlocScrollEvent(blockScroll: true));
      },
      twoFingersOff: () => Future.delayed(
        PinchZoomReleaseUnzoomWidget.defaultResetDuration,
        () {
          // communityBloc.add(BlocScrollEvent(blockScroll: false));
        },
      ),
      fingersRequiredToPinch: 2,
      log: true,
      child: mediaContent,
    );
  }
}

class CustomVideoPlayer extends StatefulWidget {
  final VideoPlayerController videoController;
  final bool isInitialize;

  const CustomVideoPlayer({
    super.key,
    required this.videoController,
    required this.isInitialize,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 380,
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.isInitialize)
            AspectRatio(
              aspectRatio: widget.videoController.value.aspectRatio,
              child: VideoPlayer(widget.videoController),
            )
          else
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

extension VideoExtension on String {
  static final List<String> _videoExtensions = [
    '.mp4',
    '.mov',
    '.avi',
    '.mkv',
    '.flv',
    '.wmv',
    '.webm',
    '.3gp',
    '.mpeg',
    '.mpg',
    '.m4v'
  ];

  bool get isVideoUrl {
    final path = toLowerCase(); // Normalize to lowercase
    return _videoExtensions.any((ext) => path.endsWith(ext));
  }
}
