// Dart SDK
import 'dart:async';

// Flutter
import 'package:flutter/material.dart';

// Third-party
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

// Project
import 'package:pictora/core/utils/extensions/extensions.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/services/service.dart';
import '../../bloc/post_bloc.dart';
import '../../models/post_data.dart';
import 'heart_animation.dart';

class ReelsMediaDisplay extends StatefulWidget {
  final List<MediaData>? mediaData;
  final String postId;
  final bool isLike;

  const ReelsMediaDisplay({
    super.key,
    required this.mediaData,
    required this.postId,
    required this.isLike,
  });

  @override
  State<ReelsMediaDisplay> createState() => _ReelsMediaDisplayState();
}

class _ReelsMediaDisplayState extends State<ReelsMediaDisplay> with AutomaticKeepAliveClientMixin {
  final ValueNotifier<VideoPlayerController?> _controllerNotifier = ValueNotifier(null);
  final ValueNotifier<bool> _isMutedNotifier = ValueNotifier(true);
  final ValueNotifier<bool> _showMuteIconNotifier = ValueNotifier(false);
  final ValueNotifier<Offset?> _tapPosition = ValueNotifier(null);
  Map<String, ValueNotifier<bool>> isLikedNotifierAnimation = {};

  bool _isDisposed = false;
  bool _isVisible = false;
  Timer? _muteIconTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    isLikedNotifierAnimation[widget.postId] = ValueNotifier<bool>(false);
  }

  Future<void> _initializeVideo() async {
    final videoUrl = widget.mediaData
        ?.firstWhere(
          (m) => (m.mediaUrl ?? '').isVideoUrl,
          orElse: () => MediaData(),
        )
        .mediaUrl;

    if (videoUrl == null || videoUrl.isEmpty) return;

    try {
      final controller = await VideoControllerManager.getController(videoUrl);

      if (_isDisposed) {
        return;
      }

      controller.setVolume(_isMutedNotifier.value ? 0 : 1);

      controller.addListener(() {
        if (!_isDisposed && controller.value.isInitialized) {
          _controllerNotifier.value = controller;
        }
      });

      if (controller.value.isInitialized) {
        _controllerNotifier.value = controller;
      }
    } catch (e) {
      logDebug(message: "Error initializing video controller: $e");
    }
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (_isDisposed) return;

    final visible = info.visibleFraction > 0.8;
    if (visible != _isVisible) {
      _isVisible = visible;
      final controller = _controllerNotifier.value;

      if (controller != null && controller.value.isInitialized && !controller.value.isBuffering) {
        if (_isVisible) {
          controller.play();
        } else {
          controller.pause();
        }
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _muteIconTimer?.cancel();

    final controller = _controllerNotifier.value;
    if (controller != null && controller.value.isInitialized) {
      controller.removeListener(() {});
      if (!_isVisible) {
        controller.pause();
      }
    }

    _controllerNotifier.dispose();
    _isMutedNotifier.dispose();
    _showMuteIconNotifier.dispose();

    super.dispose();
  }

  void _toggleMute() {
    final controller = _controllerNotifier.value;
    if (controller != null && controller.value.isInitialized && !_isDisposed) {
      _isMutedNotifier.value = !_isMutedNotifier.value;
      controller.setVolume(_isMutedNotifier.value ? 0 : 1);
      _showMuteIconNotifier.value = true;
      _muteIconTimer?.cancel();
      _muteIconTimer = Timer(const Duration(seconds: 1), () {
        if (!_isDisposed) {
          _showMuteIconNotifier.value = false;
        }
      });
    }
  }

  void _handleDoubleTap() {
    isLikedNotifierAnimation[widget.postId]?.value = true;
    if (!widget.isLike) {
      postBloc.add(TogglePostLikeEvent(
        postId: widget.postId,
        isLike: !(widget.isLike),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ValueListenableBuilder<VideoPlayerController?>(
      valueListenable: _controllerNotifier,
      builder: (context, controller, _) {
        if (controller == null) {
          return _buildFallbackImage();
        }

        return Stack(
          children: [
            GestureDetector(
              onTap: _toggleMute,
              onDoubleTap: _handleDoubleTap,
              onDoubleTapDown: (details) {
                final localPosition = details.localPosition;

                logDebug(message: "Local Tap Position: $localPosition");
                _tapPosition.value = localPosition;
              },
              onLongPressStart: (_) {
                if (controller.value.isPlaying && !_isDisposed) {
                  controller.pause();
                }
              },
              onLongPressEnd: (_) {
                if (!_isDisposed && _isVisible) {
                  controller.play();
                }
              },
              child: VisibilityDetector(
                key: Key(widget.postId),
                onVisibilityChanged: _handleVisibilityChanged,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio == 0 ? 16 / 9 : controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _showMuteIconNotifier,
              builder: (context, showMuteIcon, _) {
                return AnimatedOpacity(
                  opacity: showMuteIcon ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  child: Center(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _isMutedNotifier,
                      builder: (context, isMuted, _) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Icon(
                            isMuted ? Icons.volume_off : Icons.volume_up,
                            color: Colors.white,
                            size: 28,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: _tapPosition,
              builder: (context, value, child) {
                return Positioned(
                  left: (_tapPosition.value?.dx ?? 0) - 50,
                  top: (_tapPosition.value?.dy ?? 0) < 140 ? (_tapPosition.value?.dy ?? 0) - 20 : (_tapPosition.value?.dy ?? 0) - 100,
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
                );
              },
            ),
            if (controller.value.isInitialized && controller.value.duration > Duration.zero)
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: Colors.white,
                    backgroundColor: Colors.grey,
                    bufferedColor: Colors.grey,
                  ),
                ),
              )
            else
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: const LinearProgressIndicator(
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFallbackImage() {
    final thumbnailUrl = widget.mediaData?.first.thumbnail;
    return CachedNetworkImage(
      imageUrl: thumbnailUrl ?? '',
      cacheKey: thumbnailUrl ?? '',
      key: ValueKey(thumbnailUrl ?? ''),
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class VideoControllerManager {
  static final Map<String, VideoPlayerController> _controllers = {};
  static final Map<String, Completer<VideoPlayerController>> _pendingInitializations = {};

  static Future<VideoPlayerController> getController(String url) async {
    if (_pendingInitializations.containsKey(url)) {
      return _pendingInitializations[url]!.future;
    }
    if (_controllers.containsKey(url)) {
      return _controllers[url]!;
    }
    final completer = Completer<VideoPlayerController>();
    _pendingInitializations[url] = completer;
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize();
      controller.setLooping(true);

      _controllers[url] = controller;
      completer.complete(controller);
    } catch (e) {
      completer.completeError(e);
    } finally {
      _pendingInitializations.remove(url);
    }
    return completer.future;
  }

  static void retainOnly(Set<String> keepUrls) {
    final toRemove = _controllers.keys.where((url) => !keepUrls.contains(url)).toList();
    for (final url in toRemove) {
      _controllers[url]?.dispose();
      _controllers.remove(url);
    }
  }

  static void clearAll() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _pendingInitializations.clear();
  }
}
