import 'package:get_it/get_it.dart';
import 'package:pictora/features/auth/bloc/auth_bloc.dart';

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
}
