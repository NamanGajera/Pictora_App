import 'package:flutter/material.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:pictora/router/router.dart';
import 'package:pictora/router/router_name.dart';
import 'package:pictora/core/utils/constants/constants.dart';
import 'package:pictora/core/utils/services/custom_logger.dart';
import 'package:video_player/video_player.dart';

import 'add_post_screen.dart';

class PostAssetPickerScreen extends StatefulWidget {
  const PostAssetPickerScreen({super.key});

  @override
  State<PostAssetPickerScreen> createState() => PostAssetPickerScreenState();
}

class PostAssetPickerScreenState extends State<PostAssetPickerScreen> with WidgetsBindingObserver {
  List<AssetEntity> selectedAssets = [];
  List<AssetEntity> assets = [];
  List<AssetPathEntity> albums = [];
  AssetPathEntity? selectedAlbum;
  AssetEntity? previewAsset;
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();
  double _previewHeight = 0.4;
  bool _isScrolling = false;
  VideoPlayerController? _videoController;
  bool _isVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAlbums();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void pauseVideo() {
    if (_videoController != null && _isVideoPlaying) {
      _videoController?.pause();
      if (mounted) {
        setState(() {
          _isVideoPlaying = false;
        });
      }
    }
  }

  void clearSelections() {
    logDebug(message: 'Clearing selections');
    selectedAssets.clear();
    setState(() {});
  }

  void _onScroll() {
    setState(() {
      _isScrolling = _scrollController.position.pixels > 0;
    });

    double maxScroll = _scrollController.position.maxScrollExtent;
    double currentScroll = _scrollController.position.pixels;
    double scrollProgress = maxScroll > 0 ? (currentScroll / maxScroll).clamp(0.0, 0.3) : 0.0;

    double newHeight = 0.4 - (scrollProgress * 0.8);
    newHeight = newHeight.clamp(0.2, 0.4);

    if ((_previewHeight - newHeight).abs() > 0.01) {
      setState(() {
        _previewHeight = newHeight;
      });
    }
  }

  Future<void> _loadAlbums() async {
    setState(() {
      isLoading = true;
    });

    final PermissionState result = await PhotoManager.requestPermissionExtend();
    final bool hasAccess = result.hasAccess;

    if (hasAccess) {
      final List<AssetPathEntity> albumList = await PhotoManager.getAssetPathList(
        type: RequestType.common,
      );

      setState(() {
        albums = albumList;
        if (albumList.isNotEmpty) {
          selectedAlbum = albumList.firstWhere(
            (album) => album.name == 'Recent',
            orElse: () => albumList.first,
          );
          _loadAssets();
        } else {
          isLoading = false;
        }
      });
    } else {
      setState(() {
        isLoading = false;
      });

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission Needed'),
          content: const Text('Please grant photo access to select media.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                PhotoManager.openSetting();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _loadAssets() async {
    if (selectedAlbum == null) return;

    setState(() {
      isLoading = true;
    });

    final List<AssetEntity> assetList = await selectedAlbum!.getAssetListRange(
      start: 0,
      end: 1000,
    );

    setState(() {
      assets = assetList;
      if (assetList.isNotEmpty && previewAsset == null) {
        previewAsset = assetList[0];
        _initializeVideoControllerIfNeeded(assetList[0]);
      }
      isLoading = false;
    });
  }

  Future<void> _initializeVideoControllerIfNeeded(AssetEntity asset) async {
    if (asset.type == AssetType.video) {
      _videoController?.dispose();
      final file = await asset.file;
      if (file != null) {
        _videoController = VideoPlayerController.file(file)
          ..initialize().then((_) {
            if (mounted) {
              setState(() {});
              // Don't auto-play videos, let user decide
              // _videoController?.play();
              // _isVideoPlaying = true;
            }
          });
      }
    } else {
      _videoController?.dispose();
      _videoController = null;
      _isVideoPlaying = false;
    }
  }

  void _onAssetTap(AssetEntity asset) {
    setState(() {
      if (selectedAssets.contains(asset)) {
        selectedAssets.remove(asset);
        // If we're removing the preview asset, update preview to first selected or first asset
        if (previewAsset == asset) {
          previewAsset = selectedAssets.isNotEmpty
              ? selectedAssets.first
              : assets.isNotEmpty
                  ? assets[0]
                  : null;
          if (previewAsset != null) {
            _initializeVideoControllerIfNeeded(previewAsset!);
          } else {
            _videoController?.dispose();
            _videoController = null;
          }
        }
      } else {
        selectedAssets.add(asset);
        previewAsset = asset;
        _initializeVideoControllerIfNeeded(asset);
      }
    });
  }

  void _onAssetLongPress(AssetEntity asset) {
    setState(() {
      if (selectedAssets.contains(asset)) {
        selectedAssets.remove(asset);
        // Update preview if we're removing the current preview asset
        if (previewAsset == asset) {
          previewAsset = selectedAssets.isNotEmpty
              ? selectedAssets.first
              : assets.isNotEmpty
                  ? assets[0]
                  : null;
          if (previewAsset != null) {
            _initializeVideoControllerIfNeeded(previewAsset!);
          } else {
            _videoController?.dispose();
            _videoController = null;
          }
        }
      } else {
        selectedAssets.add(asset);
      }
    });
  }

  void _toggleVideoPlayback() {
    if (_videoController != null) {
      setState(() {
        if (_isVideoPlaying) {
          _videoController?.pause();
        } else {
          _videoController?.play();
        }
        _isVideoPlaying = !_isVideoPlaying;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'New Post',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: selectedAssets.isNotEmpty
                ? () {
                    // Pause video before navigating
                    pauseVideo();
                    appRouter.push(RouterName.addPost.path, extra: AddPostScreenDataModel(selectedAssets: selectedAssets));
                  }
                : null,
            child: Text(
              'Next',
              style: TextStyle(
                color: selectedAssets.isNotEmpty ? Colors.blue : Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? _buildLoadingView()
          : Column(
              children: [
                _buildAlbumDropdown(),
                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const ClampingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          height: MediaQuery.of(context).size.height * _previewHeight,
                          child: _buildPreviewSection(),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Divider(height: 1, color: Colors.grey[200]),
                      ),
                      _buildAssetsGrid(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAlbumDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          _showAlbumSelectionDialog();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              const Icon(Icons.photo_album, size: 20, color: Colors.black87),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  selectedAlbum?.name ?? 'Select Album',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.arrow_drop_down, size: 24, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }

  void _showAlbumSelectionDialog() {
    showModalBottomSheet(
      context: bottomBarContext!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Album',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Divider(height: 1, color: Colors.grey[300]),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: albums.length,
                  itemBuilder: (context, index) {
                    final album = albums[index];
                    return ListTile(
                      leading: const Icon(Icons.photo_album, color: Colors.black87),
                      title: Text(
                        album.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: album == selectedAlbum ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      trailing: album == selectedAlbum ? const Icon(Icons.check, color: Colors.blue) : null,
                      onTap: () {
                        Navigator.pop(context);
                        if (album != selectedAlbum) {
                          setState(() {
                            selectedAlbum = album;
                            selectedAssets.clear();
                            previewAsset = null;
                            _videoController?.dispose();
                            _videoController = null;
                            _isVideoPlaying = false;
                          });
                          _loadAssets();
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingView() {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: _buildShimmerBox(double.infinity, double.infinity),
        ),
        const SizedBox(height: 2),
        Expanded(
          flex: 3,
          child: GridView.builder(
            padding: const EdgeInsets.all(2),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: 20,
            itemBuilder: (context, index) {
              return _buildShimmerBox(double.infinity, double.infinity);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerBox(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildPreviewSection() {
    if (previewAsset == null) {
      return Container(
        color: Colors.grey[100],
        child: Center(
          child: Icon(Icons.photo, size: 64, color: Colors.grey[400]),
        ),
      );
    }

    // Only show the preview if the asset is in selectedAssets or if no assets are selected
    final shouldShowPreview = selectedAssets.isEmpty || selectedAssets.contains(previewAsset);

    if (!shouldShowPreview) {
      return Container(
        color: Colors.grey[100],
        child: Center(
          child: Icon(Icons.photo, size: 64, color: Colors.grey[400]),
        ),
      );
    }

    return Hero(
      tag: 'preview-${previewAsset!.id}',
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: _isScrolling
              ? [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            if (previewAsset!.type == AssetType.video && _videoController != null)
              GestureDetector(
                onTap: _toggleVideoPlayback,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
              )
            else
              AssetEntityImage(
                previewAsset!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                isOriginal: true,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _ShimmerWidget(
                    child: Container(
                      color: Colors.grey[300],
                    ),
                  );
                },
              ),
            if (previewAsset!.type == AssetType.video && _videoController != null)
              Center(
                child: IconButton(
                  icon: Icon(
                    _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                    size: 50,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  onPressed: _toggleVideoPlayback,
                ),
              ),
            if (selectedAssets.isNotEmpty)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    '${selectedAssets.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            if (selectedAssets.length > 1)
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: Colors.grey[700],
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetsGrid() {
    if (assets.isEmpty) {
      return SliverFillRemaining(
        child: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No media found',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final asset = assets[index];
          final isSelected = selectedAssets.contains(asset);
          final isPreview = previewAsset == asset;
          final selectionIndex = selectedAssets.indexOf(asset);

          return GestureDetector(
            onTap: () => _onAssetTap(asset),
            onLongPress: () => _onAssetLongPress(asset),
            child: Hero(
              tag: 'thumbnail-${asset.id}',
              child: Material(
                color: Colors.transparent,
                child: Stack(
                  children: [
                    AssetEntityImage(
                      asset,
                      key: ValueKey(asset.id),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      isOriginal: false,
                      thumbnailSize: const ThumbnailSize.square(200),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _ShimmerWidget(
                          child: Container(
                            color: Colors.grey[300],
                          ),
                        );
                      },
                    ),
                    if (isPreview && (selectedAssets.isEmpty || isSelected))
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 3),
                          ),
                        ),
                      ),
                    if (isSelected)
                      Positioned.fill(
                        child: Container(
                          color: Colors.blue.withValues(alpha: 0.2),
                        ),
                      ),
                    if (isSelected)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${selectionIndex + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (asset.type == AssetType.video)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _formatDuration(asset.duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: assets.length,
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class _ShimmerWidget extends StatefulWidget {
  final Widget child;

  const _ShimmerWidget({required this.child});

  @override
  _ShimmerWidgetState createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<_ShimmerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
