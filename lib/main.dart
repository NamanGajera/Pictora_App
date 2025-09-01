// Flutter
import 'package:flutter/material.dart';

// Third-party
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

// Project
import 'features/profile/profile.dart';
import 'features/auth/auth.dart';
import 'features/post/post.dart';
import 'features/search/search.dart';
import 'core/database/hive/hive_service.dart';
import 'core/utils/services/service.dart';
import 'core/utils/constants/constants.dart';
import 'core/config/router.dart';
import 'core/di/dependency_injection.dart';
import 'core/utils/helper/helper.dart';

void main() async {
  AppEnvManager.currentEnv = AppEnv.local;
  AppEnvManager.setLocalBaseUrl("http://192.168.1.34:5000");

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
        BlocProvider(create: (_) => getIt<SearchBloc>()),
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
            textSelectionTheme: const TextSelectionThemeData(cursorColor: primaryColor, selectionHandleColor: primaryColor),
          ),
          builder: (context, child) {
            return SafeArea(
                child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(overscroll: false),
                child: child ?? Container(),
              ),
            ));
          },
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
