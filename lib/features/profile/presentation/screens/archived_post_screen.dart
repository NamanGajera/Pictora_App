// Flutter
import 'package:flutter/material.dart';

// Third-Party
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

// Project
import '../../../../core/config/router.dart';
import '../../../../core/config/router_name.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/helper/helper.dart';
import '../../../../core/utils/widgets/custom_widget.dart';
import '../../../post/post.dart';
import '../widgets/post_preview.dart';

class ArchivedPostScreen extends StatefulWidget {
  const ArchivedPostScreen({super.key});

  @override
  State<ArchivedPostScreen> createState() => _ArchivedPostScreenState();
}

class _ArchivedPostScreenState extends State<ArchivedPostScreen> {
  @override
  void initState() {
    postBloc.add(GetArchivedPostEvent(body: {"skip": 0, "take": 27}));
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  final postBody = {"skip": 0, "take": 21};
  final ScrollController _scrollController = ScrollController();

  void _scrollListener() {
    if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 100) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    final currentState = postBloc.state;
    if (currentState.hasMoreArchivedPost) {
      postBody["skip"] = (currentState.archivedPostData?.length ?? 0);
      postBloc.add(LoadMoreArchivedPostEvent(body: postBody));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        titleSpacing: 10,
        title: const CustomText(
          'Archived',
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
            previous.archivedPostData != current.archivedPostData || previous.getArchivedPostApiStatus != current.getArchivedPostApiStatus,
        builder: (context, state) {
          if (state.getArchivedPostApiStatus == ApiStatus.loading) {
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

          final postData = onlyArchivedPosts(state.archivedPostData ?? []);

          if (postData.isEmpty) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  InkWell(
                    onTap: () {
                      postBloc.add(GetArchivedPostEvent(body: {"skip": 0, "take": 27}));
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
                key: ValueKey(postData[index].id),
                onTap: () {
                  appRouter.push(
                    RouterName.postLists.path,
                    extra: PostListScreenDataModel(
                      postListNavigation: PostListNavigation.archive,
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
