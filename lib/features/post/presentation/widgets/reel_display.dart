import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pictora/core/utils/services/custom_logger.dart';
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
  final ValueNotifier<VideoPlayerController?> _controllerNotifier = ValueNotifier(null);

  bool _isDisposed = false;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final videoUrl = widget.mediaData
        ?.firstWhere(
          (m) => (m.mediaUrl ?? '').isVideoUrl,
          orElse: () => MediaData(),
        )
        .mediaUrl;

    if (videoUrl == null || videoUrl.isEmpty) return;

    final controller = await VideoControllerManager.getController(videoUrl);

    if (_isDisposed) return;

    controller.addListener(() {
      if (controller.value.isInitialized) {
        // Even if duration == 0, force update to trigger rebuild
        _controllerNotifier.value = controller;
      }
    });

    if (controller.value.isInitialized) {
      _controllerNotifier.value = controller;
    }
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    final visible = info.visibleFraction > 0.8;
    if (visible != _isVisible) {
      _isVisible = visible;
      final controller = _controllerNotifier.value;
      if (controller != null && controller.value.isInitialized) {
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
    _controllerNotifier.value?.dispose();
    _controllerNotifier.dispose();
    VideoControllerManager.clearAll();
    super.dispose();
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
              onTap: () {
                logDebug(message: "controller ==>>> $controller");
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
            if (controller.value.isInitialized && controller.value.duration > Duration.zero)
              VideoProgressIndicator(
                controller,
                allowScrubbing: true,
                colors: VideoProgressColors(
                  playedColor: Colors.white,
                  backgroundColor: Colors.grey,
                  bufferedColor: Colors.grey,
                ),
              )
            else
              const LinearProgressIndicator(
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFallbackImage() {
    final thumbnailUrl = widget.mediaData?.first.thumbnail;
    return Center(
      child: CachedNetworkImage(
        imageUrl: thumbnailUrl ?? '',
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[100],
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.black,
          child: const Icon(Icons.image, color: Colors.white54, size: 40),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class VideoControllerManager {
  static final Map<String, VideoPlayerController> _controllers = {};

  static Future<VideoPlayerController> getController(String url) async {
    if (_controllers.containsKey(url)) {
      return _controllers[url]!;
    }
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await controller.initialize();
    controller.setLooping(true);
    _controllers[url] = controller;
    return controller;
  }

  static void disposeController(String url) {
    _controllers[url]?.dispose();
    _controllers.remove(url);
  }

  static void clearAll() {
    _controllers.forEach((_, c) => c.dispose());
    _controllers.clear();
  }
}
