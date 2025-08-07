import 'dart:async';

import 'package:flutter/material.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:pictora/features/post/bloc/post_bloc.dart';
import 'package:pictora/utils/constants/bloc_instances.dart';
import 'package:pictora/utils/constants/colors.dart';
import 'package:pictora/utils/extensions/widget_extension.dart';
import 'package:pictora/utils/services/custom_logger.dart';
import 'package:pictora/utils/widgets/custom_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';

import '../../../router/router.dart';
import '../../../router/router_name.dart';
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
    if (assets.isEmpty) return; // Guard against empty assets

    setState(() => _isGeneratingThumbnails = true);

    try {
      // Only generate thumbnails for videos
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

      // Add timeout for thumbnail generation
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: file.path,
        thumbnailPath: (await getTemporaryDirectory()).path,
        quality: 50,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 300,
        timeMs: 0,
      ).timeout(const Duration(seconds: 5)); // Add timeout

      if (thumbnailPath == null) return null;

      // Verify the file exists
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

    // Generate 5 thumbnails at different points in the video
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
        // Update the main thumbnail if this is the current asset
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
        quality: 30, // Very low quality for quick generation
        imageFormat: ImageFormat.JPEG,
        maxWidth: 200,
        timeMs: percent * 1000, // Assuming video is ~10s for demo
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
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        titleSpacing: 0,
        title: const CustomText(
          "Add Post",
          fontSize: 20,
        ),
        backgroundColor: scaffoldBgColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_isGeneratingThumbnails) const LinearProgressIndicator(minHeight: 2) else const SizedBox(height: 2),
            _buildMediaCarousel(),
            const SizedBox(height: 16),
            _buildCaptionField(),
          ],
        ),
      ),
      bottomNavigationBar: CustomButton(
        text: "Post",
        onTap: () async {
          final List<File> mediaFiles = await _getAllAssetFiles();
          final List<File> thumbnailFiles = [];

          // Generate thumbnails for videos
          for (int i = 0; i < assets.length; i++) {
            if (assets[i].type == AssetType.video) {
              if (selectedVideoCovers.containsKey(i)) {
                thumbnailFiles.add(selectedVideoCovers[i]!);
              } else if (videoThumbnails[i] != null) {
                thumbnailFiles.add(videoThumbnails[i]!);
              } else {
                // Fallback: generate thumbnail if none exists
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

          postBloc.add(CreatePostEvent(
            caption: captionController.text.trim(),
            mediaData: mediaFiles,
            thumbnailData: thumbnailFiles,
            previewFile: previewFileImage,
          ));
        },
      ).withPadding(const EdgeInsets.symmetric(horizontal: 14, vertical: 14)),
    );
  }

  Widget _buildMediaCarousel() {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: assets.length,
          options: CarouselOptions(
            height: 300,
            reverse: false,
            autoPlay: false,
            enableInfiniteScroll: false,
            padEnds: false,
            enlargeFactor: 0,
            viewportFraction: 0.59,
            onPageChanged: (index, reason) {
              setState(() => _currentIndex = index);
            },
          ),
          itemBuilder: (context, index, realIndex) {
            return GestureDetector(
              onTap: () {
                if (assets[index].type == AssetType.video) {
                  _selectVideoCover(index);
                }
              },
              child: _buildMediaItem(index),
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: assets.asMap().entries.map((entry) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == entry.key ? Colors.blue : Colors.grey[300],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMediaItem(int index) {
    if (index >= assets.length) return Container();

    final asset = assets[index];

    if (asset.type == AssetType.image) {
      if (_imageFileCache.containsKey(index)) {
        return Image.file(
          _imageFileCache[index]!,
          fit: BoxFit.contain,
        );
      }

      // If not in cache, load it
      return FutureBuilder<File?>(
        future: asset.file.then((file) {
          if (file != null) {
            _imageFileCache[index] = file; // Cache the file
          }
          return file;
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(child: Icon(Icons.error));
            }
            if (snapshot.hasData && snapshot.data != null) {
              return Image.file(
                snapshot.data!,
                fit: BoxFit.contain,
              );
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      );
    } else {
      // Video handling remains the same
      final thumbnail = selectedVideoCovers[index] ?? videoThumbnails[index];
      return Stack(
        fit: StackFit.expand,
        children: [
          if (thumbnail != null) Image.file(thumbnail, fit: BoxFit.contain) else const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.videocam, color: Colors.white),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildCaptionField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomTextField(
        controller: captionController,
        hintText: 'Enter caption',
        hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.7)),
        isRequired: true,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
        fillColor: backgroundColor,
        borderColor: primaryColor.withValues(alpha: 0.1),
        enabledBorderColor: primaryColor.withValues(alpha: 0.1),
        focusedBorderColor: primaryColor,
        maxLines: 5,
      ),
    );
  }
}

class AddPostScreenDataModel {
  final List<AssetEntity> selectedAssets;
  AddPostScreenDataModel({required this.selectedAssets});
}
