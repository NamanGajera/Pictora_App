import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:pictora/core/utils/extensions/extensions.dart';

import '../../models/post_data.dart';

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
  VideoPlayerController? _videoController;
  final ValueNotifier<bool> _isInitialized = ValueNotifier(false);
  final ValueNotifier<bool> _isPlaying = ValueNotifier(false);
  final ValueNotifier<Duration> _position = ValueNotifier(Duration.zero);

  bool _isDisposed = false;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(ReelsMediaDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaData != widget.mediaData) {
      _initializeVideo();
    }
  }

  void _initializeVideo() async {
    final videoUrl = widget.mediaData
        ?.firstWhere(
          (media) => (media.mediaUrl ?? '').isVideoUrl,
          orElse: () => MediaData(),
        )
        .mediaUrl;

    if (videoUrl == null || videoUrl.isEmpty) {
      _isInitialized.value = false;
      return;
    }

    if (_videoController != null && _videoController!.dataSource == videoUrl) {
      return;
    }

    await _videoController?.dispose();
    _videoController = null;

    _isInitialized.value = false;
    _isPlaying.value = false;
    _position.value = Duration.zero;

    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    try {
      await _videoController!.initialize();
      if (_isDisposed) return;

      _videoController!.setLooping(true);
      _videoController!.removeListener(_updateVideoState);
      _videoController!.addListener(_updateVideoState);

      _isInitialized.value = true;

      if (_isVisible) {
        _playVideo();
      }
    } catch (e) {
      if (!_isDisposed) {
        _isInitialized.value = false;
        _position.value = Duration.zero;
        _isPlaying.value = false;
      }
    }
  }

  void _updateVideoState() {
    if (_isDisposed || !_videoController!.value.isInitialized) return;

    final value = _videoController!.value;

    if (_position.value != value.position) {
      _position.value = value.position;
    }
    if (_isPlaying.value != value.isPlaying) {
      _isPlaying.value = value.isPlaying;
    }
  }

  void _playVideo() {
    if (_isInitialized.value && _videoController != null && !_videoController!.value.isPlaying) {
      final pos = _videoController!.value.position;
      final dur = _videoController!.value.duration;

      if (pos >= dur && dur != Duration.zero) {
        _videoController!.seekTo(Duration.zero);
        _position.value = Duration.zero;
      } else if (_position.value != pos) {
        _videoController!.seekTo(_position.value);
      }

      _videoController!.play();
      _isPlaying.value = true;
    }
  }

  void _pauseVideo() {
    if (_isInitialized.value && _videoController != null && _videoController!.value.isPlaying) {
      final currentPosition = _videoController!.value.position;
      _position.value = currentPosition;
      _videoController!.pause();
      _isPlaying.value = false;
    }
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    final visible = info.visibleFraction > 0.8;

    if (visible != _isVisible) {
      _isVisible = visible;
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_isDisposed) return;
        if (visible && _isInitialized.value) {
          _playVideo();
        } else {
          _pauseVideo();
        }
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _videoController?.removeListener(_updateVideoState);
    _videoController?.dispose();
    _isInitialized.dispose();
    _isPlaying.dispose();
    _position.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final hasVideo = widget.mediaData?.any((m) => (m.mediaUrl ?? '').isVideoUrl) ?? false;
    final thumbnailUrl = widget.mediaData?.first.thumbnail;

    if (!hasVideo) {
      return _buildFallbackImage();
    }

    return VisibilityDetector(
      key: Key(widget.postId),
      onVisibilityChanged: _handleVisibilityChanged,
      child: GestureDetector(
        onTap: () {
          if (_videoController != null && _isInitialized.value) {
            if (_videoController!.value.isPlaying) {
              _pauseVideo();
            } else {
              _playVideo();
            }
          }
        },
        child: Stack(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: _isInitialized,
              builder: (context, initialized, child) {
                if (!initialized) {
                  return CachedNetworkImage(
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
                  );
                }

                return Center(
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                );
              },
            ),
            if (_videoController != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VideoProgressIndicator(
                  _videoController!,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    backgroundColor: Colors.grey,
                    playedColor: Colors.white,
                    bufferedColor: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.white54,
          size: 40,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
