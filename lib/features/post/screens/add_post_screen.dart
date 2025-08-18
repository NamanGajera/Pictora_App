import 'dart:async';

import 'package:flutter/material.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:pictora/features/post/bloc/post_bloc.dart';
import 'package:pictora/utils/constants/bloc_instances.dart';
import 'package:pictora/utils/services/custom_logger.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';

import '../../../router/router.dart';
import '../../../router/router_name.dart';
import '../../../utils/constants/screens_keys.dart';
import 'video_cover_selector_screen.dart';

class AddPostScreen extends StatefulWidget {
  final List<AssetEntity> selectedAssets;
  const AddPostScreen({super.key, required this.selectedAssets});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  late List<AssetEntity> assets;
  List<File?> videoThumbnails = [];
  Map<int, File> selectedVideoCovers = {};
  int _currentIndex = 0;
  bool _isGeneratingThumbnails = false;
  final Map<int, File> _imageFileCache = {};

  final TextEditingController captionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    assets = widget.selectedAssets;
    videoThumbnails = List.filled(assets.length, null);
    _initializeAssets();
    _preloadImages();
  }

  Future<void> _preloadImages() async {
    for (int i = 0; i < assets.length; i++) {
      if (assets[i].type == AssetType.image) {
        final file = await assets[i].file;
        if (file != null) {
          _imageFileCache[i] = file;
        }
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _initializeAssets() async {
    if (assets.isEmpty) return;

    setState(() => _isGeneratingThumbnails = true);

    try {
      for (int i = 0; i < assets.length; i++) {
        if (assets[i].type == AssetType.video) {
          videoThumbnails[i] = await _generateVideoThumbnail(assets[i]);
        }
      }
    } catch (e) {
      debugPrint('Error initializing assets: $e');
    } finally {
      setState(() {
        _isGeneratingThumbnails = false;
      });
    }
  }

  Future<File?> _generateVideoThumbnail(AssetEntity video) async {
    try {
      final file = await video.file;
      if (file == null) return null;

      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: file.path,
        thumbnailPath: (await getTemporaryDirectory()).path,
        quality: 80,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 300,
        timeMs: 0,
      ).timeout(const Duration(seconds: 5));

      if (thumbnailPath == null) return null;

      final thumbnailFile = File(thumbnailPath);
      if (await thumbnailFile.exists()) {
        return thumbnailFile;
      }
      return null;
    } on TimeoutException {
      debugPrint('Thumbnail generation timed out');
      return null;
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
      return null;
    }
  }

  Future<void> _selectVideoCover(int assetIndex) async {
    if (assets[assetIndex].type != AssetType.video) return;

    final videoFile = await assets[assetIndex].file;
    if (videoFile == null) return;

    final covers = await Future.wait([
      _generateCoverAtTime(videoFile.path, 0),
      _generateCoverAtTime(videoFile.path, 25),
      _generateCoverAtTime(videoFile.path, 50),
      _generateCoverAtTime(videoFile.path, 75),
      _generateCoverAtTime(videoFile.path, 100),
    ]);

    final selectedCover = await appRouter.push<File>(RouterName.videoCoverSelector.path,
        extra: VideoCoverSelectorDataModel(
          covers: covers.whereType<File>().toList(),
          videoFile: videoFile,
        ));

    if (selectedCover != null && mounted) {
      setState(() {
        selectedVideoCovers[assetIndex] = selectedCover;
        if (_currentIndex == assetIndex) {
          videoThumbnails[assetIndex] = selectedCover;
        }
      });
    }
  }

  Future<File?> _generateCoverAtTime(String videoPath, int percent) async {
    try {
      final duration = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        quality: 30,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 200,
        timeMs: percent * 1000,
      );
      return duration != null ? File(duration) : null;
    } catch (e) {
      debugPrint('Error generating cover at $percent%: $e');
      return null;
    }
  }

  Future<List<File>> _getAllAssetFiles() async {
    List<File> files = [];
    for (int i = 0; i < assets.length; i++) {
      final file = await assets[i].file;
      if (file != null) {
        files.add(file);
      }
    }
    return files;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "New Post",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () async {
              final List<File> mediaFiles = await _getAllAssetFiles();
              final List<File> thumbnailFiles = [];

              for (int i = 0; i < assets.length; i++) {
                if (assets[i].type == AssetType.video) {
                  if (selectedVideoCovers.containsKey(i)) {
                    thumbnailFiles.add(selectedVideoCovers[i]!);
                  } else if (videoThumbnails[i] != null) {
                    thumbnailFiles.add(videoThumbnails[i]!);
                  } else {
                    final thumbnail = await _generateVideoThumbnail(assets[i]);
                    if (thumbnail != null) {
                      thumbnailFiles.add(thumbnail);
                    }
                  }
                }
              }

              File previewFileImage;
              if (assets[0].type == AssetType.video) {
                previewFileImage = thumbnailFiles.isNotEmpty ? thumbnailFiles[0] : mediaFiles[0];
              } else {
                previewFileImage = mediaFiles[0];
              }

              final postData = {
                "caption": captionController.text.trim(),
                "media": mediaFiles,
                "thumbnails": thumbnailFiles,
              };

              logInfo(message: "Post Data: $postData");
              assetPickerScreenKey.currentState?.clearSelections();
              postBloc.add(CreatePostEvent(
                caption: captionController.text.trim(),
                mediaData: mediaFiles,
                thumbnailData: thumbnailFiles,
                previewFile: previewFileImage,
              ));
            },
            child: const Text(
              "Share",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isGeneratingThumbnails)
            LinearProgressIndicator(
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 2,
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMediaSection(),
                  const SizedBox(height: 20),
                  _buildCaptionSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection() {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          _buildMediaDisplay(),
          if (assets.length > 1) ...[
            const SizedBox(height: 16),
            _buildMediaIndicators(),
            const SizedBox(height: 16),
          ] else
            const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMediaDisplay() {
    if (assets.length == 1) {
      // Single image/video - full width display
      return SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.5,
        child: _buildMediaItem(0, isFullWidth: true),
      );
    } else {
      // Multiple items - carousel
      return CarouselSlider.builder(
        itemCount: assets.length,
        options: CarouselOptions(
          height: MediaQuery.of(context).size.height * 0.45,
          reverse: false,
          autoPlay: false,
          enableInfiniteScroll: false,
          padEnds: false,
          enlargeFactor: 0,
          viewportFraction: 0.85,
          onPageChanged: (index, reason) {
            setState(() => _currentIndex = index);
          },
        ),
        itemBuilder: (context, index, realIndex) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () {
                if (assets[index].type == AssetType.video) {
                  _selectVideoCover(index);
                }
              },
              child: _buildMediaItem(index),
            ),
          );
        },
      );
    }
  }

  Widget _buildMediaItem(int index, {bool isFullWidth = false}) {
    if (index >= assets.length) return Container();

    final asset = assets[index];
    final borderRadius = isFullWidth ? 0.0 : 16.0;

    Widget mediaWidget;

    if (asset.type == AssetType.image) {
      if (_imageFileCache.containsKey(index)) {
        mediaWidget = Image.file(
          _imageFileCache[index]!,
          fit: isFullWidth ? BoxFit.cover : BoxFit.contain,
        );
      } else {
        mediaWidget = FutureBuilder<File?>(
          future: asset.file.then((file) {
            if (file != null) {
              _imageFileCache[index] = file;
            }
            return file;
          }),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: const Center(
                    child: Icon(Icons.error_outline, color: Colors.grey, size: 48),
                  ),
                );
              }
              if (snapshot.hasData && snapshot.data != null) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Image.file(
                    snapshot.data!,
                    fit: isFullWidth ? BoxFit.cover : BoxFit.contain,
                  ),
                );
              }
            }
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            );
          },
        );
      }
    } else {
      final thumbnail = selectedVideoCovers[index] ?? videoThumbnails[index];
      mediaWidget = Stack(
        fit: StackFit.expand,
        children: [
          if (thumbnail != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Image.file(
                thumbnail,
                fit: isFullWidth ? BoxFit.cover : BoxFit.contain,
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "Video",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (assets[index].type == AssetType.video)
            Positioned(
              bottom: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => _selectVideoCover(index),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.black87,
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return isFullWidth
        ? mediaWidget
        : ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: mediaWidget,
          );
  }

  Widget _buildMediaIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: assets.asMap().entries.map((entry) {
        final isActive = _currentIndex == entry.key;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isActive ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive ? Colors.blue : Colors.grey[300],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCaptionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Write a caption",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: captionController,
              maxLines: 4,
              minLines: 3,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }
}

class AddPostScreenDataModel {
  final List<AssetEntity> selectedAssets;
  AddPostScreenDataModel({required this.selectedAssets});
}
