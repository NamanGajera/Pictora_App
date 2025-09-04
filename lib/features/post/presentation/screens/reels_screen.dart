// Flutter
import 'package:flutter/material.dart';

// Third-party
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:video_player/video_player.dart';

// Project
import 'package:pictora/features/post/models/models.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../bloc/post_bloc.dart';
import '../widgets/single_reel_view.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => ReelsScreenState();
}

class ReelsScreenState extends State<ReelsScreen> {
  late PageController _pageController;
  late ReelControllerManager _controllerManager;
  int _currentIndex = 0;
  List<String> _videoUrls = [];
  List<PostData> _reelData = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    postBloc.add(GetAllReelsEvent());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controllerManager.disposeAll();
    super.dispose();
  }

  void _handlePageChanged(int index) {
    if (_currentIndex >= 0 && _currentIndex < (_controllerManager.playableItems.length)) {
      final previousController = _controllerManager.getControllerForIndex(_currentIndex);
      if (previousController != null && previousController.value.isPlaying) {
        previousController.pause();
      }

      if ((_currentIndex - index).abs() > 2) {
        _controllerManager.disposeControllerAt(_currentIndex);
      }
    }

    _currentIndex = index;
    _controllerManager.handlePageChanged(index);

    final newController = _controllerManager.getControllerForIndex(index);
    if (newController != null) {
      if (newController.value.isInitialized) {
        newController.play();
      } else {
        _playWhenInitialized(newController, index);
      }
    }
    final state = postBloc.state;
    if (index >= _reelData.length - 5 && state.hasMoreReel) {
      postBloc.add(LoadMoreReelsEvent(
        body: {
          "skip": _reelData.length,
          "take": 10,
          "seed": state.seedForReel,
        },
      ));
    }
  }

  void _playWhenInitialized(VideoPlayerController controller, int index) {
    if (controller.value.isInitialized) {
      controller.play();
      setState(() {});
      return;
    }

    void checkInitialization() {
      if (controller.value.isInitialized) {
        controller.removeListener(checkInitialization);
        if (index == _currentIndex) {
          controller.play();
          setState(() {});
        }
      }
    }

    controller.addListener(checkInitialization);
  }

  @override
  void didUpdateWidget(ReelsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_reelData.length > 50) {
      _cleanupDistantControllers();
    }
  }

  void _cleanupDistantControllers() {
    final safeRange = 5;
    for (int i = 0; i < (_controllerManager.playableItems.length); i++) {
      if ((i < _currentIndex - safeRange) || (i > _currentIndex + safeRange)) {
        _controllerManager.disposeControllerAt(i);
      }
    }
  }

  void _handleVisibilityChanged(VisibilityInfo info, int index) {
    if (index != _currentIndex) return;

    final controller = _controllerManager.getControllerForIndex(index);

    if (controller != null && controller.value.isInitialized) {
      if (info.visibleFraction > 0.1) {
        if (!controller.value.isPlaying) {
          controller.play();
          controller.setLooping(true);
        }
      } else {
        if (controller.value.isPlaying) {
          controller.pause();
        }
      }
    }
  }

  Future<void> scrollToTop() async {
    if (_pageController.hasClients) {
      reelRefreshKey.currentState?.show();
    }
  }

  void stopAllVideo() {
    _controllerManager.stopAllVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        key: reelRefreshKey,
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          _currentIndex = 0;
          stopAllVideo();
          _reelData.clear();
          _controllerManager.disposeAll();
          postBloc.add(GetAllReelsEvent());
          _pageController.jumpToPage(0);
        },
        child: BlocConsumer<PostBloc, PostState>(
          buildWhen: (previous, current) => previous.getReelApiStatus != current.getReelApiStatus,
          listenWhen: (previous, current) => previous.getReelApiStatus != current.getReelApiStatus || previous.reelsData != current.reelsData,
          listener: (context, state) {
            if (state.getReelApiStatus == ApiStatus.success && state.reelsData != null) {
              final reelData = state.reelsData ?? [];
              if (_reelData.isEmpty) {
                _reelData = reelData;

                _videoUrls = reelData.map((reel) {
                  return (reel.mediaData?.isNotEmpty ?? false) ? reel.mediaData![0].mediaUrl ?? '' : '';
                }).toList();

                _controllerManager = ReelControllerManager(_videoUrls);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _controllerManager.handlePageChanged(0);

                  final firstController = _controllerManager.getControllerForIndex(0);
                  if (firstController != null) {
                    _playWhenInitialized(firstController, 0);
                  }
                });
              } else {
                _reelData = reelData;

                _videoUrls = _reelData.map((reel) {
                  return (reel.mediaData?.isNotEmpty ?? false) ? reel.mediaData![0].mediaUrl ?? '' : '';
                }).toList();

                _controllerManager = ReelControllerManager(_videoUrls);
              }
            }
          },
          builder: (context, state) {
            if (state.getReelApiStatus == ApiStatus.loading || _reelData.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              );
            }

            return PageView.builder(
              key: const PageStorageKey("reels_pageview"),
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: _reelData.length,
              physics: const ClampingScrollPhysics(),
              onPageChanged: _handlePageChanged,
              itemBuilder: (context, index) {
                if (!mounted) return const SizedBox();
                final reel = _reelData[index];
                final controller = _controllerManager.getControllerForIndex(index);
                return VisibilityDetector(
                    key: ValueKey('reel_${reel.id}_$index'),
                    onVisibilityChanged: (info) => _handleVisibilityChanged(info, index),
                    child: controller == null
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : SingleReelView(
                            key: ValueKey(reel.id),
                            controller: controller,
                            reel: reel,
                            reelControllerManager: _controllerManager,
                          ));
              },
            );
          },
        ),
      ),
    );
  }
}
