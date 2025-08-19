import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pictora/features/post/screens/widgets/heart_animation.dart';
import 'package:pictora/core/utils/extensions/string_extensions.dart';
import 'package:pinch_zoom_release_unzoom/pinch_zoom_release_unzoom.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../core/utils/constants/bloc_instances.dart';
import '../../bloc/post_bloc.dart';
import '../../models/post_data.dart';

class PostMediaDisplay extends StatefulWidget {
  final List<MediaData>? mediaData;
  final String postId;
  final bool isLike;

  const PostMediaDisplay({
    super.key,
    required this.mediaData,
    required this.postId,
    required this.isLike,
  });

  @override
  State<PostMediaDisplay> createState() => _PostMediaDisplayState();
}

class _PostMediaDisplayState extends State<PostMediaDisplay> with AutomaticKeepAliveClientMixin {
  final ValueNotifier<Map<String, VideoPlayerController>> _videoControllers = ValueNotifier({});
  final ValueNotifier<Map<String, bool>> _isInitialized = ValueNotifier({});
  final ValueNotifier<int> _currentPage = ValueNotifier(0);
  final PageController _pageController = PageController();
  Map<String, ValueNotifier<bool>> isLikedNotifierAnimation = {};
  final Map<String, bool> _isPlaying = {};

  @override
  void initState() {
    super.initState();
    _initializeMedia();
    _videoControllers.addListener(_updateState);
    _isInitialized.addListener(_updateState);
    isLikedNotifierAnimation[widget.postId] = ValueNotifier<bool>(false);
  }

  void _updateState() => setState(() {});

  void _initializeMedia() {
    for (var i = 0; i < (widget.mediaData ?? []).length; i++) {
      final fileUrl = '${widget.mediaData?[i].mediaUrl}';
      if (fileUrl.isVideoUrl) {
        final videoKey = '${widget.postId}_$i';
        if (!_videoControllers.value.containsKey(videoKey)) {
          _videoControllers.value[videoKey] = VideoPlayerController.networkUrl(Uri.parse(fileUrl))
            ..initialize().then((_) {
              _isInitialized.value = {..._isInitialized.value, videoKey: true};
              _videoControllers.value[videoKey]!.setLooping(true);
            });
          _isPlaying[videoKey] = false;
        }
      }
    }
  }

  void _togglePlay(String videoKey) {
    if (_videoControllers.value[videoKey]?.value.isInitialized ?? false) {
      if (_isPlaying[videoKey] == true) {
        _videoControllers.value[videoKey]!.pause();
      } else {
        _videoControllers.value.forEach((key, controller) {
          if (key != videoKey && controller.value.isPlaying) controller.pause();
        });
        _videoControllers.value[videoKey]!.play();
      }
      _isPlaying[videoKey] = !(_isPlaying[videoKey] ?? false);
      _updateState();
    }
  }

  @override
  void dispose() {
    _videoControllers.value.forEach((_, controller) => controller.dispose());
    _videoControllers.dispose();
    _isInitialized.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    isLikedNotifierAnimation[widget.postId]?.value = true;
    postBloc.add(TogglePostLikeEvent(
      postId: widget.postId,
      isLike: !(widget.isLike),
    ));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final mediaItems = widget.mediaData?.map((media) {
          return {
            'type': (media.mediaUrl ?? '').isVideoUrl ? 'video' : 'image',
            'url': media.mediaUrl,
            'thumbnail': media.thumbnail,
          };
        }).toList() ??
        [];

    if (mediaItems.isEmpty) return Container();

    return VisibilityDetector(
      key: Key(widget.postId),
      onVisibilityChanged: (info) {
        final currentMedia = mediaItems[_currentPage.value];
        if (currentMedia['type'] == 'video') {
          final videoKey = '${widget.postId}_${_currentPage.value}';
          if (info.visibleFraction > 0.9) {
            _togglePlay(videoKey);
          } else {
            _videoControllers.value[videoKey]?.pause();
            _isPlaying[videoKey] = false;
          }
        }
      },
      child: GestureDetector(
        onDoubleTap: _handleDoubleTap,
        onTap: () {
          final currentMedia = mediaItems[_currentPage.value];
          if (currentMedia['type'] == 'video') {
            final videoKey = '${widget.postId}_${_currentPage.value}';
            _togglePlay(videoKey);
          }
        },
        child: Container(
          height: 380,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (value) => _currentPage.value = value,
                itemCount: mediaItems.length,
                physics: postBloc.state.isBlockScroll ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
                itemBuilder: (_, index) {
                  final media = mediaItems[index];
                  return media['type'] == 'video'
                      ? PinchZoomReleaseUnzoomWidget(
                          twoFingersOn: () {
                            postBloc.add(BlockScrollEvent(isBlockScroll: true));
                          },
                          twoFingersOff: () => Future.delayed(
                            PinchZoomReleaseUnzoomWidget.defaultResetDuration,
                            () {
                              postBloc.add(BlockScrollEvent(isBlockScroll: false));
                            },
                          ),
                          fingersRequiredToPinch: 2,
                          log: true,
                          child: Center(
                            child: _VideoPlayer(
                              videoKey: '${widget.postId}_$index',
                              controllers: _videoControllers.value,
                              isInitialized: _isInitialized.value,
                              thumbnailUrl: media['thumbnail'] ?? '',
                            ),
                          ),
                        )
                      : PinchZoomReleaseUnzoomWidget(
                          twoFingersOn: () {
                            postBloc.add(BlockScrollEvent(isBlockScroll: true));
                          },
                          twoFingersOff: () => Future.delayed(
                            PinchZoomReleaseUnzoomWidget.defaultResetDuration,
                            () {
                              postBloc.add(BlockScrollEvent(isBlockScroll: false));
                            },
                          ),
                          fingersRequiredToPinch: 2,
                          log: true,
                          child: _ImageDisplay(url: media['url'] ?? ''),
                        );
                },
              ),

              Positioned.fill(
                child: Center(
                  child: ValueListenableBuilder(
                    valueListenable: isLikedNotifierAnimation[widget.postId] ?? ValueNotifier(false),
                    builder: (BuildContext context, bool value, Widget? child) {
                      return Opacity(
                        opacity: value ? 1 : 0,
                        child: HeartAnimationWidget(
                          isAnimating: value,
                          duration: const Duration(milliseconds: 400),
                          onEnd: () {
                            if (isLikedNotifierAnimation.containsKey(widget.postId)) {
                              isLikedNotifierAnimation[widget.postId]!.value = false;
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

              // Page indicators
              if (mediaItems.length > 1) ...[
                Positioned(
                  top: 12,
                  right: 12,
                  child: ValueListenableBuilder<int>(
                    valueListenable: _currentPage,
                    builder: (_, value, __) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${value + 1}/${mediaItems.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: ValueListenableBuilder<int>(
                    valueListenable: _currentPage,
                    builder: (_, value, __) => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        mediaItems.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: value == index ? 8 : 6,
                          height: value == index ? 8 : 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: value == index ? Colors.white : Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _VideoPlayer extends StatelessWidget {
  final String videoKey;
  final String thumbnailUrl;
  final Map<String, VideoPlayerController> controllers;
  final Map<String, bool> isInitialized;

  const _VideoPlayer({
    required this.videoKey,
    required this.controllers,
    required this.isInitialized,
    required this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    final controller = controllers[videoKey];
    final initialized = isInitialized[videoKey] ?? false;

    return SizedBox(
      width: double.infinity,
      child: initialized && controller != null
          ? AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: Stack(
                children: [
                  VideoPlayer(controller),
                  if (!controller.value.isPlaying)
                    const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white54,
                        size: 50,
                      ),
                    ),
                ],
              ),
            )
          : CachedNetworkImage(
              imageUrl: thumbnailUrl,
              cacheKey: thumbnailUrl,
              key: ValueKey(thumbnailUrl),
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[100],
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xff9CA3AF)),
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: const Color(0xffF3F4F6),
                height: double.infinity,
                child: const Icon(
                  Icons.image_outlined,
                  color: Color(0xff9CA3AF),
                  size: 32,
                ),
              ),
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
    );
  }
}

class _ImageDisplay extends StatefulWidget {
  final String url;

  const _ImageDisplay({required this.url});

  @override
  State<_ImageDisplay> createState() => _ImageDisplayState();
}

class _ImageDisplayState extends State<_ImageDisplay> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: CachedNetworkImage(
        imageUrl: widget.url,
        cacheKey: widget.url,
        key: ValueKey(widget.url),
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[100],
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff9CA3AF)),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: const Color(0xffF3F4F6),
          child: const Icon(
            Icons.image_outlined,
            color: Color(0xff9CA3AF),
            size: 32,
          ),
        ),
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
