import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:pictora/router/router.dart';
import 'package:pictora/router/router_name.dart';
import 'package:pictora/utils/constants/colors.dart';
import 'package:pictora/utils/extensions/string_extensions.dart';
import '../../utils/constants/app_assets.dart';
import '../../utils/widgets/custom_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool _agreeToTerms = false;

  ValueNotifier<bool> registerLoading = ValueNotifier(false);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: fullNameController,
                        hintText: 'Enter your full name',
                        labelText: 'Full Name',
                        hintStyle: TextStyle(
                            color: textSecondary.withValues(alpha: 0.7)),
                        isRequired: true,
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                        prefixIcon: Icons.person_outline,
                        prefixIconColor: primaryColor,
                        fillColor: backgroundColor,
                        borderColor: primaryColor.withValues(alpha: 0.1),
                        enabledBorderColor: primaryColor.withValues(alpha: 0.1),
                        focusedBorderColor: primaryColor,
                        validator: (value) {
                          if (value!.isNullOrEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: userNameController,
                        hintText: 'Enter your username',
                        labelText: 'Username',
                        hintStyle: TextStyle(
                            color: textSecondary.withValues(alpha: 0.7)),
                        isRequired: true,
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                        prefixIcon: Icons.person_outline,
                        prefixIconColor: primaryColor,
                        fillColor: backgroundColor,
                        borderColor: primaryColor.withValues(alpha: 0.1),
                        enabledBorderColor: primaryColor.withValues(alpha: 0.1),
                        focusedBorderColor: primaryColor,
                        validator: (value) {
                          if (value!.isNullOrEmpty) {
                            return 'Please enter username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: emailController,
                        hintText: 'Enter your email',
                        labelText: 'Email',
                        isRequired: true,
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                        hintStyle: TextStyle(
                            color: textSecondary.withValues(alpha: 0.7)),
                        prefixIcon: Icons.email_outlined,
                        prefixIconColor: primaryColor,
                        fillColor: backgroundColor,
                        borderColor: primaryColor.withValues(alpha: 0.1),
                        enabledBorderColor: primaryColor.withValues(alpha: 0.1),
                        focusedBorderColor: primaryColor,
                        validator: (value) {
                          if (value!.isNullOrEmpty) {
                            return 'Please enter your email';
                          } else if (!value.trim().isValidEmail) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: passwordController,
                        hintText: 'Enter your password',
                        labelText: 'Password',
                        hintStyle: TextStyle(
                            color: textSecondary.withValues(alpha: 0.7)),
                        isRequired: true,
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                        showObscureToggle: true,
                        prefixIcon: Icons.email_outlined,
                        prefixIconColor: primaryColor,
                        fillColor: backgroundColor,
                        borderColor: primaryColor.withValues(alpha: 0.1),
                        enabledBorderColor: primaryColor.withValues(alpha: 0.1),
                        focusedBorderColor: primaryColor,
                        validator: (value) {
                          if (value!.isNullOrEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        maxLines: 1,
                        suffixIconColor: primaryColor,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: confirmPasswordController,
                        hintText: 'Confirm you password',
                        labelText: 'Confirm Password',
                        hintStyle: TextStyle(
                            color: textSecondary.withValues(alpha: 0.7)),
                        isRequired: true,
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                        showObscureToggle: true,
                        prefixIcon: Icons.email_outlined,
                        prefixIconColor: primaryColor,
                        fillColor: backgroundColor,
                        borderColor: primaryColor.withValues(alpha: 0.1),
                        enabledBorderColor: primaryColor.withValues(alpha: 0.1),
                        focusedBorderColor: primaryColor,
                        validator: (value) {
                          if (value!.isNullOrEmpty) {
                            return 'Please enter your password';
                          } else if (passwordController.text.trim() != value) {
                            return 'Confirm password is not match';
                          }
                          return null;
                        },
                        maxLines: 1,
                        suffixIconColor: primaryColor,
                      ),
                      const SizedBox(height: 20),
                      _buildTermsCheckbox(),
                      const SizedBox(height: 32),
                      CustomButton(
                        text: "Create Account",
                        onTap: () {},
                        height: 52,
                        backgroundColor:
                            _agreeToTerms ? primaryColor : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),

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

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: (value) {
            setState(() {
              _agreeToTerms = value ?? false;
            });
          },
          activeColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: RichText(
              text: TextSpan(
                text: 'I agree to the ',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
