// Third-party
import 'package:get_it/get_it.dart';

// Project
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../features/post/bloc/post_bloc.dart';
import '../../features/post/repository/post_repository.dart';
import '../../features/profile/bloc/follow_section_bloc/follow_section_bloc.dart';
import '../../features/profile/bloc/profile_bloc/profile_bloc.dart';
import '../../features/search/bloc/search_bloc.dart';
import '../../features/search/repository/search_repository.dart';
import '../../features/profile/repository/profile_repository.dart';
import '../../features/conversation/conversation.dart';
import '../network/api_client.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  /// API Service
  getIt.registerSingleton<ApiClient>(ApiClient());

  /// Repositories

  getIt.registerSingleton<AuthRepository>(AuthRepository(getIt<ApiClient>()));

  getIt.registerSingleton<PostRepository>(PostRepository(getIt<ApiClient>()));

  getIt.registerSingleton<ProfileRepository>(ProfileRepository(getIt<ApiClient>()));

  getIt.registerSingleton<SearchRepository>(SearchRepository(getIt<ApiClient>()));

  getIt.registerSingleton<ConversationRepository>(ConversationRepository(getIt<ApiClient>()));

  /// Blocs
  getIt.registerSingleton<AuthBloc>(AuthBloc(getIt<AuthRepository>()));

  getIt.registerSingleton<PostBloc>(PostBloc(getIt<PostRepository>()));

  getIt.registerSingleton<ProfileBloc>(ProfileBloc(getIt<ProfileRepository>()));

  getIt.registerSingleton<FollowSectionBloc>(FollowSectionBloc(getIt<ProfileRepository>()));

  getIt.registerSingleton<SearchBloc>(SearchBloc(getIt<SearchRepository>()));

  getIt.registerSingleton<ConversationBloc>(ConversationBloc(getIt<ConversationRepository>()));
}
