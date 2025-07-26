import 'package:flutter/material.dart';
import 'router/router.dart';
import 'utils/constants/colors.dart';
import 'utils/helper/shared_prefs_helper.dart';
import 'utils/services/device_info_service.dart';
import 'utils/di/dependency_injection.dart';

void main() async {
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
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: MaterialApp.router(
        title: 'Pictora',
        theme: ThemeData(
          primaryColor: primaryColor,
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
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
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
      ),
    );
  }
}
