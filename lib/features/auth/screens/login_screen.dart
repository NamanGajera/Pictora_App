import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:pictora/features/auth/bloc/auth_bloc.dart';
import 'package:pictora/router/router.dart';
import 'package:pictora/router/router_name.dart';
import 'package:pictora/utils/constants/app_assets.dart';
import 'package:pictora/utils/constants/bloc_instances.dart';
import 'package:pictora/utils/extensions/string_extensions.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/widgets/custom_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: mainLoginScreen(),
    );
  }

  Widget mainLoginScreen() {
    return KeyboardDismissOnTap(
      dismissOnCapturedTaps: true,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 50),

              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.asset(AppAssets.appLogo),
              ),

              const SizedBox(height: 28),

              // Welcome Text
              Text(
                'Welcome Back!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
              ),

              const SizedBox(height: 8),

              Text(
                'Sign in to continue your journey',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: textSecondary,
                    ),
              ),

              const SizedBox(height: 48),

              // Login Form Card
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
                      const SizedBox(height: 24),
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
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                        return CustomButton(
                          text: "Sign In",
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              final body = {
                                "email": emailController.text.trim(),
                                "password": passwordController.text.trim(),
                              };

                              authBloc.add(LoginUserEvent(body: body));
                            }
                          },
                          height: 52,
                          showLoader:
                              state.loginUserApiStatus == ApiStatus.loading,
                        );
                      }),
                      const SizedBox(height: 10),
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

              const SizedBox(height: 48),

              // Sign Up Link
              _buildSignUpLink(),

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
            onTap: () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSocialButton(
            icon: Icons.facebook,
            label: 'Facebook',
            onTap: () {},
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

  Widget _buildSignUpLink() {
    return RichText(
      text: TextSpan(
        text: 'Don\'t have an account? ',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: textSecondary,
            ),
        children: [
          TextSpan(
            text: 'Sign Up',
            style: const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                appRouter.replace(RouterName.register.path);
              },
          ),
        ],
      ),
    );
  }
}
