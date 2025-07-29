import 'package:pictora/features/auth/bloc/auth_bloc.dart';

import '../../features/post/bloc/post_bloc.dart';
import '../di/dependency_injection.dart';

final authBloc = getIt<AuthBloc>();

final postBloc = getIt<PostBloc>();
