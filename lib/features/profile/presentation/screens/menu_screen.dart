// Flutter
import 'package:flutter/material.dart';

// Project
import 'package:pictora/core/config/router.dart';
import 'package:pictora/core/config/router_name.dart';
import 'package:pictora/core/utils/constants/colors.dart';
import 'package:pictora/core/utils/widgets/custom_widget.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool isPrivateAccount = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        titleSpacing: 10,
        title: const CustomText(
          'Settings and activity',
          fontWeight: FontWeight.w500,
          color: Colors.black87,
          fontSize: 18,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => appRouter.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menu Items Section
            const CustomText(
              'Your Activity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Menu Items
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.bookmark_outline,
                    title: 'Saved Posts',
                    subtitle: 'View your saved posts',
                    onTap: () {
                      appRouter.push(RouterName.savedPost.path);
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.archive_outlined,
                    title: 'Archived Posts',
                    subtitle: 'Posts you\'ve archived',
                    onTap: () {
                      appRouter.push(RouterName.archivedPost.path);
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.favorite_outline,
                    title: 'Liked Posts',
                    subtitle: 'Posts you\'ve liked',
                    onTap: () {
                      appRouter.push(RouterName.likedPost.path);
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.chat_bubble_outline,
                    title: 'Comments',
                    subtitle: 'Your comments and replies',
                    onTap: () {
                      appRouter.push(RouterName.userComments.path);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Settings Section
            const CustomText(
              'Settings & Support',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            const SizedBox(height: 12),

            // Additional Options
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Account Privacy',
                    subtitle: 'Choose who can see your profile',
                    onTap: () {
                      appRouter.push(RouterName.accountPrivacy.path);
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact support',
                    onTap: () {

                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    onTap: () {
                      _showLogoutDialog();
                    },
                    isDestructive: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive ? Colors.red.withValues(alpha: 0.1) : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? Colors.red : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  CustomText(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[200],
      indent: 72,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const CustomText(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: const CustomText(
            'Are you sure you want to logout from your account?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const CustomText(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Implement logout logic
              },
              child: const CustomText(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
