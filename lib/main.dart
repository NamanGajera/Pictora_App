import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/features/auth/bloc/auth_bloc.dart';
import 'package:pictora/utils/Constants/enums.dart';
import 'package:pictora/utils/services/app_env_manager.dart';
import 'router/router.dart';
import 'utils/constants/colors.dart';
import 'utils/helper/shared_prefs_helper.dart';
import 'utils/services/device_info_service.dart';
import 'utils/di/dependency_injection.dart';

void main() async {
  AppEnvManager.currentEnv = AppEnv.local;
  AppEnvManager.setLocalBaseUrl("http://192.168.1.33:5000");

  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefsHelper.init();
  await DeviceInfoService().init();
  await setupDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthBloc>()),
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
              iconTheme: IconThemeData(color: Colors.white),
            ),
            progressIndicatorTheme:
                ProgressIndicatorThemeData(color: primaryColor),
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
