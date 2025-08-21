// Flutter
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/widgets/custom_widget.dart';
import '../../../../core/utils/extensions/extensions.dart';
import '../../auth.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool agreeToTerms = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
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
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: fullNameController,
              hintText: 'Enter your full name',
              labelText: 'Full Name',
              hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.7)),
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
              hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.7)),
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
              hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.7)),
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
              hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.7)),
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
              hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.7)),
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
            BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
              return CustomButton(
                text: "Create Account",
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    final body = {
                      "email": emailController.text.trim(),
                      "password": passwordController.text.trim(),
                      "fullName": fullNameController.text.trim(),
                      "userName": userNameController.text.trim(),
                    };

                    authBloc.add(RegisterUserEvent(body: body));
                  }
                },
                height: 52,
                showLoader: state.registerUserApiStatus == ApiStatus.loading,
                backgroundColor: agreeToTerms ? primaryColor : Colors.grey,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: agreeToTerms,
          onChanged: (value) {
            setState(() {
              agreeToTerms = value ?? false;
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
}
