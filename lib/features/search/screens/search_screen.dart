import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/core/utils/constants/bloc_instances.dart';
import 'package:pictora/core/utils/extensions/string_extensions.dart';
import 'package:pictora/core/utils/extensions/widget_extension.dart';
import 'package:pictora/core/utils/widgets/custom_widget.dart';
import 'package:pictora/data/hiveModel/user_mapper.dart';
import 'package:pictora/features/search/bloc/search_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/database/hive_boxes.dart';
import '../../../core/database/hive_service.dart';
import '../../../data/hiveModel/user_hive_model.dart';
import '../../../data/model/user_model.dart';
import '../../../router/router.dart';
import '../../../router/router_name.dart';
import '../../../core/utils/constants/enums.dart';
import '../../post/bloc/post_bloc.dart';
import '../../post/models/post_data.dart';
import '../../post/screens/post_list_screen.dart';
import '../../profile/screens/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    super.initState();
    searchBloc.add(SearchUserEvent(query: ''));
    _searchSubject.stream.debounceTime(Duration(milliseconds: 500)).listen((searchText) {
      if (searchText.length >= 3) {
        searchBloc.add(SearchUserEvent(
          query: searchText.trim(),
        ));
      } else if (searchText.trim().isEmpty) {
        searchBloc.add(SearchUserEvent(
          query: '',
        ));
      }
    });
  }

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final BehaviorSubject<String> _searchSubject = BehaviorSubject<String>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 10),
          BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              return Row(
                children: [
                  if (state.showSearchUser)
                    InkWell(
                      onTap: () {
                        searchBloc.add(ShowSearchUserList(showSearchUser: false));
                        _searchController.clear();
                        FocusScope.of(context).unfocus();
                      },
                      child: const Icon(Icons.arrow_back, size: 26),
                    ),
                  if (state.showSearchUser) const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      hintText: "Search...",
                      prefixIcon: Icons.search,
                      controller: _searchController,
                      constraints: const BoxConstraints(maxHeight: 42, minHeight: 42),
                      contentPadding: EdgeInsets.zero,
                      textInputAction: TextInputAction.search,
                      onChanged: (value) => _searchSubject.add(value),
                      onTap: () => searchBloc.add(ShowSearchUserList(showSearchUser: true)),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              buildWhen: (previous, current) => previous.showSearchUser != current.showSearchUser,
              builder: (context, state) {
                return IndexedStack(
                  index: state.showSearchUser ? 1 : 0,
                  children: [
                    _buildPostGridContent(),
                    _searchUserList(),
                  ],
                );
              },
            ),
          ),
        ],
      ).withPadding(const EdgeInsets.symmetric(horizontal: 10)),
    );
  }

  Widget _buildPostGridContent() {
    return BlocBuilder<PostBloc, PostState>(
      buildWhen: (previous, current) => previous.getAllPostApiStatus != current.getAllPostApiStatus || previous.allPostData != current.allPostData,
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
                child: Container(color: Colors.white),
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
                Icon(Icons.photo_library_outlined, size: 64, color: Color(0xff9CA3AF)),
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
    );
  }

  Widget _searchUserList() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (_searchController.text.trim().isEmpty) {
          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 10),
            itemCount: state.cachedUserList?.length ?? 0,
            itemBuilder: (context, index) {
              final User? user = state.cachedUserList?[index];
              return InkWell(
                onTap: () async {
                  appRouter.push(RouterName.otherUserProfile.path, extra: ProfileScreenDataModel(userId: user?.id ?? ''));
                },
                child: _buildUserTile(user, FollowSectionTab.discover, true),
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 6);
            },
          );
        }
        return ListView.separated(
          padding: EdgeInsets.symmetric(vertical: 10),
          itemCount: state.searchUserList?.length ?? 0,
          itemBuilder: (context, index) {
            final User? user = state.searchUserList?[index];
            return InkWell(
              onTap: () async {
                final hiveUser = user?.toHiveModel();
                await cacheUser(hiveUser);
                appRouter.push(RouterName.otherUserProfile.path, extra: ProfileScreenDataModel(userId: user?.id ?? ''));
              },
              child: _buildUserTile(user, FollowSectionTab.discover),
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(height: 6);
          },
        );
      },
    );
  }

  Widget _buildUserTile(User? user, FollowSectionTab tab, [bool? isCachedUser]) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      child: Row(
        children: [
          RoundProfileAvatar(
            imageUrl: user?.profile?.profilePicture ?? '',
            radius: 23,
            userId: user?.id ?? '',
          ),
          SizedBox(width: 12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.userName ?? 'guest11',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  user?.fullName ?? 'guest',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isCachedUser ?? false)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                await deleteUser(user?.id ?? '');
              },
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostPreview(PostData? post) {
    String? firstMediaUrl = post?.mediaData?[0].mediaUrl;
    String? thumbnailUrl = post?.mediaData?[0].thumbnail;

    String displayUrl = (firstMediaUrl != null && firstMediaUrl.isVideoUrl) ? (thumbnailUrl ?? firstMediaUrl) : (firstMediaUrl ?? '');

    return Container(
      key: ValueKey("${post?.id}"),
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            cacheKey: post?.mediaData?[0].id,
            imageUrl: displayUrl,
            key: ValueKey(post?.mediaData?[0].id),
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

  Future<void> cacheUser(UserHiveModel? user) async {
    final box = await HiveService.openBox<UserHiveModel>(HiveBoxes.searchUsers);
    if (user == null) return;

    final alreadyExists = box.values.any((u) => u.id == user.id);

    if (!alreadyExists) {
      await box.add(user);
    }
  }

  Future<void> deleteUser(String userId) async {
    final box = await HiveService.openBox<UserHiveModel>(HiveBoxes.searchUsers);
    final key = box.keys.firstWhere(
      (k) => box.get(k)?.id == userId,
      orElse: () => null,
    );

    if (key != null) {
      await box.delete(key);
    }

    searchBloc.add(SearchUserEvent(query: ''));
  }
}
