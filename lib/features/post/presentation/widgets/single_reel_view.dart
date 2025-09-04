// Dart SDK
import 'dart:async';
import 'dart:math' as math;

// Flutter
import 'package:flutter/material.dart';

// Third-party
import 'package:video_player/video_player.dart';

// Project
import 'package:pictora/core/utils/extensions/extensions.dart';
import 'package:pictora/features/post/presentation/widgets/reel_action_button_section.dart';
import 'package:pictora/features/post/presentation/widgets/reel_user_and_post_info_section.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/services/service.dart';
import '../../bloc/post_bloc.dart';
import '../../models/playable_item.dart';
import '../../models/post_data.dart';
import 'heart_animation.dart';

class SingleReelView extends StatefulWidget {
  final VideoPlayerController controller;
  final ReelControllerManager reelControllerManager;
  final PostData reel;
  const SingleReelView({
    super.key,
    required this.controller,
    required this.reel,
    required this.reelControllerManager,
  });

  @override
  State<SingleReelView> createState() => _SingleReelViewState();
}

class _SingleReelViewState extends State<SingleReelView> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    if (!widget.controller.value.isLooping) {
      widget.controller.setLooping(true);
    }
    isLikedNotifierAnimation[widget.reel.id ?? ''] = ValueNotifier(false);
  }

  @override
  void dispose() {
    final reelId = widget.reel.id ?? '';
    if (isLikedNotifierAnimation.containsKey(reelId)) {
      isLikedNotifierAnimation[reelId]?.dispose();
      isLikedNotifierAnimation.remove(reelId);
    }
    _tapPosition.dispose();
    _showMuteIconNotifier.dispose();

    super.dispose();
  }

  final ValueNotifier<Offset?> _tapPosition = ValueNotifier(null);
  Map<String, ValueNotifier<bool>> isLikedNotifierAnimation = {};
  final ValueNotifier<bool> _showMuteIconNotifier = ValueNotifier(false);

  void _handleDoubleTap() {
    isLikedNotifierAnimation[widget.reel.id]?.value = true;
    final reel = (postBloc.state.reelsData ?? []).firstWhere((r) => r.id == widget.reel.id, orElse: () => PostData());
    if (!(reel.isLiked ?? false)) {
      postBloc.add(TogglePostLikeEvent(
        postId: reel.id ?? '',
        isLike: !(reel.isLiked ?? false),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () {
        _showMuteIconNotifier.value = true;
        Timer(const Duration(seconds: 1), () {
          _showMuteIconNotifier.value = false;
        });
        widget.reelControllerManager.toggleMuteAll();
      },
      onDoubleTap: _handleDoubleTap,
      onDoubleTapDown: (details) {
        final localPosition = details.localPosition;
        _tapPosition.value = localPosition;
      },
      onLongPressStart: (_) {
        if (widget.controller.value.isPlaying) {
          widget.controller.pause();
        }
      },
      onLongPressEnd: (_) {
        widget.controller.play();
      },
      child: SizedBox(
        height: context.screenHeight,
        width: context.screenWidth,
        child: Stack(
          children: [
            Positioned.fill(
              child: widget.controller.value.isInitialized
                  ? Center(
                      child: AspectRatio(
                        aspectRatio: widget.controller.value.aspectRatio == 0 ? 16 / 9 : widget.controller.value.aspectRatio,
                        child: VideoPlayer(
                          key: ValueKey('reel_controller_${widget.reel.id}'),
                          widget.controller,
                        ),
                      ),
                    )
                  : _buildLoadingPlaceholder(widget.reel),
            ),
            ValueListenableBuilder<bool>(
                valueListenable: _showMuteIconNotifier,
                builder: (context, showIcon, child) {
                  return AnimatedOpacity(
                    opacity: showIcon ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: ValueListenableBuilder<bool>(
                      valueListenable: widget.reelControllerManager.isMuted,
                      builder: (context, isMuted, child) {
                        logDebug(message: "isMuted $isMuted");
                        return Center(
                          child: Container(
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
                          ),
                        );
                      },
                    ),
                  );
                }),
            ValueListenableBuilder(
              valueListenable: _tapPosition,
              builder: (context, value, child) {
                return Positioned(
                  left: (_tapPosition.value?.dx ?? 0) - 50,
                  top: (_tapPosition.value?.dy ?? 0) < 140 ? (_tapPosition.value?.dy ?? 0) - 20 : (_tapPosition.value?.dy ?? 0) - 100,
                  child: Center(
                    child: ValueListenableBuilder(
                      valueListenable: isLikedNotifierAnimation[widget.reel.id] ?? ValueNotifier(false),
                      builder: (BuildContext context, bool value, Widget? child) {
                        return Opacity(
                          opacity: value ? 1 : 0,
                          child: HeartAnimationWidget(
                            isAnimating: value,
                            duration: const Duration(milliseconds: 400),
                            onEnd: () {
                              if (isLikedNotifierAnimation.containsKey(widget.reel.id)) {
                                isLikedNotifierAnimation[widget.reel.id]!.value = false;
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
            Positioned(
              left: 16,
              bottom: 30,
              right: context.screenWidth * 0.25,
              child: ReelUserAndPostInfoSection(reel: widget.reel),
            ),
            Positioned(
              right: 5,
              bottom: 40,
              child: ReelActionButtonSection(reel: widget.reel),
            ),
            if (widget.controller.value.isInitialized && widget.controller.value.duration > Duration.zero)
              Positioned(
                bottom: 3,
                right: 0,
                left: 0,
                child: VideoProgressIndicator(
                  widget.controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: Colors.white,
                    backgroundColor: Colors.grey,
                    bufferedColor: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(PostData reel) {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ReelControllerManager {
  final List<PlayableItem> _playableItems;
  static const int _preloadRange = 1;
  final ValueNotifier<bool> isMuted = ValueNotifier(false);
  int _currentCenterIndex = 0;

  ReelControllerManager(List<String> videoUrls) : _playableItems = videoUrls.map((url) => PlayableItem(videoUrl: url)).toList();

  void handlePageChanged(int newIndex) {
    _currentCenterIndex = newIndex;
    _disposeControllersOutsideRange(newIndex);
    _preloadControllersInRange(newIndex);
  }

  void _disposeControllersOutsideRange(int centerIndex) {
    for (int i = 0; i < _playableItems.length; i++) {
      final item = _playableItems[i];
      if ((i < centerIndex - _preloadRange) || (i > centerIndex + _preloadRange)) {
        _disposeController(item);
      }
    }
  }

  void _disposeController(PlayableItem item) {
    if (item.controller != null) {
      if (item.listener != null) {
        item.controller!.removeListener(item.listener!);
      }
      item.controller!.dispose();
      item.controller = null;
      item.isInitialized = false;
      item.initializeFuture = null;
      item.removeListener();
    }
  }

  void _preloadControllersInRange(int centerIndex) {
    final start = math.max(0, centerIndex - _preloadRange);
    final end = math.min(_playableItems.length - 1, centerIndex + _preloadRange);

    for (int i = start; i <= end; i++) {
      final item = _playableItems[i];
      if (item.controller == null) {
        item.controller = VideoPlayerController.networkUrl(Uri.parse(item.videoUrl));

        void listener() {
          if (item.controller != null && item.controller!.value.isInitialized) {
            if (!item.controller!.value.isLooping) {
              item.controller!.setLooping(true);
            }
          }
        }

        item.setListener(listener);
        item.controller!.addListener(listener);

        item.initializeFuture = item.controller!.initialize().then((_) {
          item.isInitialized = true;
          item.controller!.setLooping(true);

          if (i == _currentCenterIndex) {
            item.controller!.play();
          }
        }).catchError((error) {
          logDebug(message: 'Failed to initialize controller at index: $i - $error');
          _disposeController(item);
        });
      }
    }
  }

  VideoPlayerController? getControllerForIndex(int index) {
    if (index < 0 || index >= _playableItems.length) return null;
    return _playableItems[index].controller;
  }

  void disposeAll() {
    for (final item in _playableItems) {
      _disposeController(item);
    }
    _playableItems.clear();
    isMuted.dispose();
  }

  void toggleMuteAll() {
    isMuted.value = !isMuted.value;
    for (final item in _playableItems) {
      if (item.controller != null && item.isInitialized) {
        item.controller!.setVolume(isMuted.value ? 0.0 : 1.0);
      }
    }
  }

  void stopAllVideos() {
    for (final item in _playableItems) {
      if (item.controller != null && item.controller!.value.isPlaying) {
        item.controller!.pause();
      }
    }
  }

  void disposeControllerAt(int index) {
    if (index >= 0 && index < _playableItems.length) {
      _disposeController(_playableItems[index]);
    }
  }

  List<PlayableItem> get playableItems => _playableItems;
}
