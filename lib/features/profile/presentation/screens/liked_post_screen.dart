import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/config/router.dart';
import '../../../../core/config/router_name.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/widgets/custom_widget.dart';
import '../../../post/post.dart';
import '../widgets/post_preview.dart';

class LikedPostScreen extends StatefulWidget {
  const LikedPostScreen({super.key});

  @override
  State<LikedPostScreen> createState() => _LikedPostScreenState();
}

class _LikedPostScreenState extends State<LikedPostScreen> {
  @override
  void initState() {
    postBloc.add(GetLikedPostEvent(body: {"skip": 0, "take": 24}));
    super.initState();
  }

  final postBody = {"skip": 0, "take": 24};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        titleSpacing: 10,
        title: const CustomText(
          'Likes',
          fontWeight: FontWeight.w500,
          color: Colors.black87,
          fontSize: 18,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => appRouter.pop(),
        ),
      ),
      body: BlocBuilder<PostBloc, PostState>(
        buildWhen: (previous, current) =>
            previous.likedPostData != current.likedPostData || previous.getLikedPostApiStatus != current.getLikedPostApiStatus,
        builder: (context, state) {
          if (state.getLikedPostApiStatus == ApiStatus.loading) {
            return GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
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

          final postData = state.likedPostData;

          if (postData?.isEmpty == true || postData == null) {
            return Column(
              children: [
                const SizedBox(height: 180),
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
                InkWell(
                  onTap: () {
                    postBloc.add(GetLikedPostEvent(body: {"skip": 0, "take": 24}));
                  },
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Refresh',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(1),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
            ),
            itemCount: postData.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                key: ValueKey(postData[index].id),
                onTap: () {
                  appRouter.push(
                    RouterName.postLists.path,
                    extra: PostListScreenDataModel(
                      postListNavigation: PostListNavigation.like,
                      index: index,
                    ),
                  );
                },
                child: PostPreview(post: postData[index]),
              );
            },
          );
        },
      ),
    );
  }
}
