import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/features/post/bloc/post_bloc.dart';
import 'package:pictora/utils/constants/bloc_instances.dart';
import 'package:pictora/utils/constants/constants.dart';
import 'package:pictora/utils/constants/enums.dart';
import 'package:pictora/utils/extensions/build_context_extension.dart';
import 'package:pictora/utils/widgets/custom_widget.dart';

import '../../../utils/constants/colors.dart';
import '../../post/screens/widgets/post_widget.dart';

class HomeScreen extends StatefulWidget {
  final File fileImage;
  const HomeScreen({super.key, required this.fileImage});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    postBloc.add(GetAllPostEvent(body: postBody));
    _scrollController.addListener(_scrollListener);
  }

  final postBody = {"skip": 0, "take": 10};
  final ScrollController _scrollController = ScrollController();

  void _scrollListener() {
    if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 100) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    final currentState = postBloc.state;
    if (currentState.hasMorePost) {
      postBody["skip"] = (currentState.allPostData?.length ?? 0);
      postBloc.add(LoadMorePostEvent(body: postBody));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        color: primaryColor,
        onRefresh: () async {
          postBloc.add(GetAllPostEvent(body: postBody));
        },
        child: Column(
          children: [
            const SizedBox(height: 15),
            BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                if (state.createPostApiStatus == ApiStatus.loading) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          color: Colors.grey.withValues(alpha: 0.2),
                          offset: Offset(0, 2),
                          spreadRadius: 1,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            widget.fileImage,
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText("Posting..."),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: context.screenWidth * 0.68,
                              child: LinearProgressIndicator(
                                borderRadius: BorderRadius.circular(8),
                                backgroundColor: Colors.grey.shade300,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),
            BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                if (state.getAllPostApiStatus == ApiStatus.loading) {
                  return Expanded(
                      child: ListView.builder(
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      return ShimmerPostWidget();
                    },
                  ));
                }

                return Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: (state.allPostData?.length ?? 0) + (state.isLoadMorePost && state.hasMorePost ? 1 : 0),
                    physics: state.isBlockScroll ? NeverScrollableScrollPhysics() : ClampingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    itemBuilder: (context, index) {
                      if (index == state.allPostData?.length) {
                        return const Center(
                            child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ));
                      }
                      return PostWidget(
                        key: ValueKey("post_$index"),
                        post: state.allPostData?[index],
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        "@$userName",
        style: TextStyle(
          color: primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class HomeScreenDataModel {
  final File fileImage;
  HomeScreenDataModel({required this.fileImage});
}
