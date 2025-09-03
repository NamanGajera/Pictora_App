// Flutter
import 'package:flutter/material.dart';

// Third-party
import 'package:video_player/video_player.dart';

class PlayableItem {
  final String videoUrl;
  VideoPlayerController? controller;
  bool isInitialized = false;
  Future<void>? initializeFuture;
  VoidCallback? _listener;

  PlayableItem({required this.videoUrl});

  void setListener(VoidCallback listener) {
    _listener = listener;
  }

  VoidCallback? get listener => _listener;

  void removeListener() {
    _listener = null;
  }
}
