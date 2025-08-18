import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/utils/extensions/string_extensions.dart';
import 'package:pictora/utils/extensions/widget_extension.dart';
import 'package:pictora/utils/widgets/custom_widget.dart';
import 'package:shimmer/shimmer.dart';

import '../../../router/router.dart';
import '../../../router/router_name.dart';
import '../../../utils/constants/enums.dart';
import '../../post/bloc/post_bloc.dart';
import '../../post/models/post_data.dart';
import '../../post/screens/post_list_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 10),
          CustomTextField(
            hintText: "Search...",
            prefixIcon: Icons.search,
            constraints: BoxConstraints(maxHeight: 42, minHeight: 42),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                if (state.getAllPostApiStatus == ApiStatus.loading) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(1),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                    ),
                    itemCount: 21,
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          color: Colors.white,
                        ),
                      );
                    },
                  );
                }

                final postData = state.allPostData;

                if (postData?.isEmpty == true || postData == null) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 64,
                          color: Color(0xff9CA3AF),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No posts yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(1),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                  ),
                  itemCount: postData.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        appRouter.push(
                          RouterName.postLists.path,
                          extra: PostListScreenDataModel(
                            postListNavigation: PostListNavigation.search,
                            index: index,
                          ),
                        );
                      },
                      child: _buildPostPreview(postData[index]).withAutomaticKeepAlive(),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ).withPadding(const EdgeInsets.symmetric(horizontal: 10)),
    );
  }

  Widget _buildPostPreview(PostData? post) {
    String? firstMediaUrl = post?.mediaData?[0].mediaUrl;
    String? thumbnailUrl = post?.mediaData?[0].thumbnail;

    String displayUrl = (firstMediaUrl != null && firstMediaUrl.isVideoUrl) ? (thumbnailUrl ?? firstMediaUrl) : (firstMediaUrl ?? '');

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            cacheKey: displayUrl,
            imageUrl: displayUrl,
            key: ValueKey(displayUrl),
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
          if ((post?.mediaData?.length ?? 0) > 1)
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
      ),
    );
  }
}
