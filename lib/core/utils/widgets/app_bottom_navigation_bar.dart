// Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Third-party
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

// Project
import '../constants/constants.dart';
import 'custom_widget.dart';
import '../../config/router_name.dart';

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
      path: RouterName.reels.path,
      name: RouterName.reels.name,
      label: 'Reels',
      iconPath: AppAssets.reelFill,
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
        backgroundColor: widget.navigationShell.currentIndex == 3 ? Colors.black : Colors.white,
        bottomNavigationBar: SizedBox(
          height: 60, // enough height for 28px icons
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
              if (index == 3 && widget.navigationShell.currentIndex == 3) {
                reelScreenKey.currentState?.scrollToTop();
              }
            },
            selectedItemColor: widget.navigationShell.currentIndex == 3 ? Colors.white : primaryColor,
            unselectedItemColor: Colors.grey.shade500,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            backgroundColor: widget.navigationShell.currentIndex == 3 ? Colors.black : Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(fontSize: 0),
            unselectedLabelStyle: const TextStyle(fontSize: 0),
            items: screenList.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == widget.navigationShell.currentIndex;

              if (index == 4 && (userProfilePic ?? '').isNotEmpty) {
                return BottomNavigationBarItem(
                  icon: RoundProfileAvatar(
                    imageUrl: userProfilePic,
                    radius: 14,
                    userId: userId ?? '',
                  ),
                  label: "",
                );
              }

              return BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  item.iconPath,
                  height: 28,
                  width: 28,
                  colorFilter: ColorFilter.mode(
                    isSelected
                        ? widget.navigationShell.currentIndex == 3
                            ? Colors.white
                            : primaryColor
                        : Colors.grey.shade500,
                    BlendMode.srcIn,
                  ),
                ),
                label: "",
              );
            }).toList(),
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
