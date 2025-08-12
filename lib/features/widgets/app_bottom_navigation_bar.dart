import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pictora/utils/constants/screens_keys.dart';

import '../../router/router_name.dart';
import '../../utils/constants/app_assets.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/constants.dart';

class AppBottomNavigationBar extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppBottomNavigationBar({
    super.key,
    required this.navigationShell,
  });

  @override
  State<AppBottomNavigationBar> createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  final List<BottomBarItem> screenList = [
    BottomBarItem(
      path: RouterName.home.path,
      name: RouterName.home.name,
      label: 'Home',
      iconPath: AppAssets.home,
    ),
    BottomBarItem(
      path: RouterName.search.path,
      name: RouterName.search.name,
      label: 'Search',
      iconPath: AppAssets.search,
    ),
    BottomBarItem(
      path: RouterName.postAssetPicker.path,
      name: RouterName.postAssetPicker.name,
      label: 'Add Post',
      iconPath: AppAssets.addPost,
    ),
    BottomBarItem(
      path: RouterName.profile.path,
      name: RouterName.profile.name,
      label: 'Profile',
      iconPath: AppAssets.profile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    bottomBarContext = context;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        assetPickerScreenKey.currentState?.pauseVideo();
        assetPickerScreenKey.currentState?.clearSelections();
        if (widget.navigationShell.currentIndex != 0) {
          widget.navigationShell.goBranch(0);
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: Container(
          color: scaffoldBgColor,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: BottomNavigationBar(
              currentIndex: widget.navigationShell.currentIndex,
              onTap: (index) {
                if (widget.navigationShell.currentIndex != index) {
                  assetPickerScreenKey.currentState?.pauseVideo();
                  assetPickerScreenKey.currentState?.clearSelections();
                  widget.navigationShell.goBranch(
                    index,
                    initialLocation: index == widget.navigationShell.currentIndex,
                  );
                }
              },
              selectedItemColor: primaryColor,
              unselectedItemColor: Colors.grey.shade500,
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              items: screenList.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = index == widget.navigationShell.currentIndex;

                return BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    item.iconPath,
                    height: 26,
                    width: 26,
                    colorFilter: ColorFilter.mode(
                      isSelected ? primaryColor : Colors.grey.shade500,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: item.label,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class BottomBarItem {
  final String path;
  final String name;
  final String label;
  final String iconPath;

  BottomBarItem({
    required this.label,
    required this.iconPath,
    required this.path,
    required this.name,
  });
}
