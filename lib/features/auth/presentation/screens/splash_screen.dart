// Dart SDK
import 'dart:async';

// Flutter
import 'package:flutter/material.dart';

// Project
import '../../../../core/utils/extensions/extensions.dart';
import '../../../../core/utils/services/service.dart';
import '../../../../core/config/router.dart';
import '../../../../core/config/router_name.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/helper/helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      checkAuthentication();
    });
  }

  Future<void> checkAuthentication() async {
    accessToken = SharedPrefsHelper().getString(SharedPrefKeys.accessToken);
    logInfo(message: "$accessToken", tag: "User Access Token");
    if ((accessToken ?? '').isEmpty) {
      appRouter.go(RouterName.login.path);
    } else {
      await setUserData();
      appRouter.go(RouterName.home.path);
    }
  }

  Future<void> setUserData() async {
    userId = SharedPrefsHelper().getString(SharedPrefKeys.userId);
    userFullName = SharedPrefsHelper().getString(SharedPrefKeys.userEmail);
    userEmail = SharedPrefsHelper().getString(SharedPrefKeys.userFullName);
    userName = SharedPrefsHelper().getString(SharedPrefKeys.userName);
    userProfilePic = SharedPrefsHelper().getString(SharedPrefKeys.userProfilePic);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                AppAssets.appLogo,
                width: context.screenWidth * 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
