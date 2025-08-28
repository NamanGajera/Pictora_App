import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pictora/core/utils/extensions/extensions.dart';

import '../../../post/post.dart';

class PostPreview extends StatefulWidget {
  final PostData? post;
  const PostPreview({
    super.key,
    required this.post,
  });

  @override
  State<PostPreview> createState() => _PostPreviewState();
}

class _PostPreviewState extends State<PostPreview> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    String? firstMediaUrl = widget.post?.mediaData?[0].mediaUrl;
    String? thumbnailUrl = widget.post?.mediaData?[0].thumbnail;

    String displayUrl = (firstMediaUrl != null && firstMediaUrl.isVideoUrl) ? (thumbnailUrl ?? firstMediaUrl) : (firstMediaUrl ?? '');
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: displayUrl,
          cacheKey: widget.post?.mediaData?[0].id,
          key: ValueKey(widget.post?.mediaData?[0].id),
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
        if ((widget.post?.mediaData?.length ?? 0) > 1)
          const Positioned(
            top: 8,
            right: 8,
            child: Icon(
              Icons.copy_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
