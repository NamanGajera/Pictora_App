import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/features/post/bloc/post_bloc.dart';
import 'package:pictora/features/post/models/post_data.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../utils/constants/enums.dart';
import 'widgets/post_widget.dart';

class PostListScreen extends StatefulWidget {
  final PostListNavigation postListNavigation;
  final int? index;
  const PostListScreen({
    super.key,
    required this.postListNavigation,
    this.index,
  });

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Text(
          "Posts",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          List<PostData> postsData = widget.postListNavigation == PostListNavigation.myProfile
              ? state.myPostData ?? []
              : widget.postListNavigation == PostListNavigation.otherProfile
                  ? state.otherUserPostData ?? []
                  : state.allPostData ?? [];
          return ScrollablePositionedList.builder(
            itemPositionsListener: _itemPositionsListener,
            initialScrollIndex: widget.index ?? 0,
            itemCount: postsData.length,
            physics: state.isBlockScroll ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 6),
            itemBuilder: (context, index) {
              return PostWidget(
                // key: ValueKey(posts[index].id),
                post: postsData[index],
              );
            },
          );
        },
      ),
    );
  }
}

class PostListScreenDataModel {
  final PostListNavigation postListNavigation;
  final int? index;
  const PostListScreenDataModel({
    required this.postListNavigation,
    this.index,
  });
}
