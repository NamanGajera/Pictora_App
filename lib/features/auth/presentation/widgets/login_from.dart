// Flutter
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project
import '../../../../core/utils/extensions/extensions.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/widgets/custom_widget.dart';
import '../../bloc/auth_bloc.dart';

class LoginFrom extends StatelessWidget {
  const LoginFrom({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
              controller: emailController,
              hintText: 'Enter your email',
              labelText: 'Email',
              keyboardType: TextInputType.emailAddress,
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
            const SizedBox(height: 24),
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
            BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
              return CustomButton(
                text: "Sign In",
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    final body = {
                      "email": emailController.text.trim(),
                      "password": passwordController.text.trim(),
                    };

                    authBloc.add(LoginUserEvent(body: body));
                  }
                },
                height: 52,
                showLoader: state.loginUserApiStatus == ApiStatus.loading,
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
