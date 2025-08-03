import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pictora/utils/extensions/build_context_extension.dart';
import 'package:pictora/utils/services/custom_logger.dart';

import '../../../router/router.dart';
import '../../../router/router_name.dart';
import '../../../utils/constants/app_assets.dart';
import '../../../utils/constants/constants.dart';
import '../../../utils/constants/shared_pref_keys.dart';
import '../../../utils/helper/shared_prefs_helper.dart';

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
    userProfilePic =
        SharedPrefsHelper().getString(SharedPrefKeys.userProfilePic);
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
