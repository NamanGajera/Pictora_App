import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/core/database/hive_service.dart';
import 'package:pictora/features/auth/bloc/auth_bloc.dart';
import 'package:pictora/features/post/bloc/post_bloc.dart';
import 'package:pictora/features/profile/bloc/profile_bloc/profile_bloc.dart';
import 'package:pictora/core/utils/services/app_env_manager.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'features/profile/bloc/follow_section_bloc/follow_section_bloc.dart';
import 'router/router.dart';
import 'core/utils/constants/colors.dart';
import 'core/utils/constants/enums.dart';
import 'core/di/dependency_injection.dart';
import 'core/utils/helper/date_formatter.dart';
import 'core/utils/helper/shared_prefs_helper.dart';
import 'core/utils/services/device_info_service.dart';

void main() async {
  AppEnvManager.currentEnv = AppEnv.local;
  AppEnvManager.setLocalBaseUrl("http://192.168.1.110:5000");

  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();
  await SharedPrefsHelper.init();
  await DeviceInfoService().init();
  await setupDependencies();
  timeago.setLocaleMessages('en_short_clean', ShortEnMessages());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<PostBloc>()),
        BlocProvider(create: (_) => getIt<ProfileBloc>()),
        BlocProvider(create: (_) => getIt<FollowSectionBloc>()),
      ],
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: MaterialApp.router(
          title: 'Pictora',
          theme: ThemeData(
            primaryColor: primaryColor,
            useMaterial3: true,
            scaffoldBackgroundColor: scaffoldBgColor,
            popupMenuTheme: const PopupMenuThemeData(
              color: Colors.white,
            ),
            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: Colors.white,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.black),
            ),
            progressIndicatorTheme: ProgressIndicatorThemeData(color: primaryColor),
          ),
          builder: (context, child) {
            return SafeArea(child: child ?? Container());
          },
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
