import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pictora/utils/extensions/build_context_extension.dart';
import 'package:pictora/utils/services/custom_logger.dart';

import '../../../router/router.dart';
import '../../../router/router_name.dart';
import '../../../utils/constants/app_assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    logDebug(message: "You reached hear");
    Timer(Duration(seconds: 2), () {
      checkAuthentication();
    });
  }

  Future<void> checkAuthentication() async {
    appRouter.go(RouterName.login.path);
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
