// Flutter
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Third-party
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

// Project
import '../../../../core/config/router.dart';
import '../../../../core/config/router_name.dart';
import '../../../../core/utils/constants/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: mainRegisterScreen(),
    );
  }

  Widget mainRegisterScreen() {
    return KeyboardDismissOnTap(
      dismissOnCapturedTaps: true,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.asset(AppAssets.appLogo),
              ),

              const SizedBox(height: 24),

              // Welcome Text
              Text(
                'Let\'s Get Started!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
              ),

              const SizedBox(height: 8),

              Text(
                'Create an account to explore all features',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: textSecondary,
                    ),
              ),

              const SizedBox(height: 32),

              // Register Form Card

              const SizedBox(height: 32),

              // OR Divider
              _buildOrDivider(),

              const SizedBox(height: 32),

              // Social Login Buttons
              _buildSocialButtons(),

              const SizedBox(height: 32),

              // Sign In Link
              _buildSignInLink(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: textSecondary.withValues(alpha: 0.3),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: textSecondary.withValues(alpha: 0.3),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildSocialButton(
            icon: Icons.g_mobiledata,
            label: 'Google',
            onTap: () {
              // Handle Google signup
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSocialButton(
            icon: Icons.facebook,
            label: 'Facebook',
            onTap: () {
              // Handle Facebook signup
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: primaryColor.withValues(alpha: 0.2)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildSignInLink() {
  return RichText(
    text: TextSpan(
      text: 'Already have an account? ',
      style: TextStyle(color: textSecondary),
      children: [
        TextSpan(
          text: 'Sign In',
          style: const TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w600,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              appRouter.replace(RouterName.login.path);
            },
        ),
      ],
    ),
  );
}
