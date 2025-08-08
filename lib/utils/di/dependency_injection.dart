import 'package:get_it/get_it.dart';
import 'package:pictora/features/auth/bloc/auth_bloc.dart';
import 'package:pictora/features/post/bloc/post_bloc.dart';
import 'package:pictora/features/profile/bloc/follow_section_bloc/follow_section_bloc.dart';
import 'package:pictora/features/profile/bloc/profile_bloc/profile_bloc.dart';

import '../../network/api_client.dart';
import '../../network/repository.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  /// API Service
  getIt.registerSingleton<ApiClient>(ApiClient());

  /// Repositories
  getIt.registerSingleton<Repository>(Repository(getIt<ApiClient>()));

  /// Blocs
  getIt.registerSingleton<AuthBloc>(AuthBloc(getIt<Repository>()));

  getIt.registerSingleton<PostBloc>(PostBloc(getIt<Repository>()));

  getIt.registerSingleton<ProfileBloc>(ProfileBloc(getIt<Repository>()));

  getIt.registerSingleton<FollowSectionBloc>(FollowSectionBloc(getIt<Repository>()));
}
