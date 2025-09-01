import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/router.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/widgets/custom_widget.dart';
import '../../bloc/profile_bloc/profile_bloc.dart';

class AccountPrivacyScreen extends StatefulWidget {
  const AccountPrivacyScreen({super.key});

  @override
  State<AccountPrivacyScreen> createState() => _AccountPrivacyScreenState();
}

class _AccountPrivacyScreenState extends State<AccountPrivacyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 10,
        title: const CustomText(
          'Account privacy',
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
      body: BlocBuilder<ProfileBloc, ProfileState>(
        buildWhen: (previous, current) =>
            previous.changeAccountPrivacyApiStatus != current.changeAccountPrivacyApiStatus ||
            previous.userData?.profile?.isPrivate != current.userData?.profile?.isPrivate,
        builder: (context, state) {
          final isLoading = state.changeAccountPrivacyApiStatus == ApiStatus.loading;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Private account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (state.userData?.profile?.isPrivate ?? false)
                                  ? 'Only followers you approve can see your posts'
                                  : 'Anyone can see your posts on your profile',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 50,
                        height: 30,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Visibility(
                              visible: !isLoading,
                              child: Transform.scale(
                                scale: 0.8,
                                child: Switch(
                                  value: (state.userData?.profile?.isPrivate ?? false),
                                  onChanged: isLoading
                                      ? null
                                      : (bool value) {
                                          profileBloc.add(
                                            ChangeAccountPrivacyEvent(isPrivate: !(state.userData?.profile?.isPrivate ?? false)),
                                          );
                                        },
                                  activeColor: Colors.white,
                                  activeTrackColor: primaryColor,
                                  inactiveThumbColor: Colors.white,
                                  inactiveTrackColor: Colors.grey[300],
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  splashRadius: 0,
                                ),
                              ),
                            ),
                            if (isLoading)
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    primaryColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'About account privacy',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        (state.userData?.profile?.isPrivate ?? false)
                            ? '• Only followers you approve can see your posts\n'
                                '• Your followers can still share your posts to their stories\n'
                                '• People can still see posts you\'re tagged in on other accounts'
                            : '• Anyone on Instagram can see your profile and posts\n'
                                '• Your posts may appear in hashtag and location pages\n'
                                '• Your posts can be shared and seen by anyone',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
