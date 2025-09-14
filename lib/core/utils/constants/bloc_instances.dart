// Project
import '../../../features/auth/auth.dart';
import '../../../features/profile/profile.dart';
import '../../../features/post/post.dart';
import '../../../features/search/search.dart';
import '../../../features/conversation/conversation.dart';
import '../../di/dependency_injection.dart';

final authBloc = getIt<AuthBloc>();

final postBloc = getIt<PostBloc>();

final profileBloc = getIt<ProfileBloc>();

final followSectionBloc = getIt<FollowSectionBloc>();

final searchBloc = getIt<SearchBloc>();

final conversationBloc = getIt<ConversationBloc>();
