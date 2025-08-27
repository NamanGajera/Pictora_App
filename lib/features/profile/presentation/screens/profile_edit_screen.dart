// Dart SDK
import 'dart:io';

// Flutter
import 'package:flutter/material.dart';

// Third-party
import 'package:flutter_bloc/flutter_bloc.dart';

// Project
import '../../../../core/utils/model/user_model.dart';
import '../../../../core/utils/widgets/custom_widget.dart';
import '../../../../core/config/router.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/helper/helper.dart';
import '../../../../core/utils/services/service.dart';
import '../../bloc/profile_bloc/profile_bloc.dart';

class ProfileEditScreen extends StatefulWidget {
  final User? userData;
  const ProfileEditScreen({super.key, required this.userData});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  // final _genderDropdownController = SingleValueDropDownController();

  // final List<DropDownValueModel> _genderOptions = [
  //   DropDownValueModel(name: "Male", value: "Male"),
  //   DropDownValueModel(name: "Female", value: "Female"),
  //   DropDownValueModel(name: "Other", value: "Other"),
  // ];

  @override
  void initState() {
    super.initState();
    _userNameController.text = widget.userData?.userName ?? '';
    _fullNameController.text = widget.userData?.fullName ?? '';
    _bioController.text = widget.userData?.profile?.bio ?? '';
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _fullNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => appRouter.pop(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                key: ValueKey(userProfilePic),
                child: Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[300]!, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: BlocBuilder<ProfileBloc, ProfileState>(
                        buildWhen: (previous, current) => previous.userData != current.userData,
                        builder: (context, state) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(65),
                            child: RoundProfileAvatar(
                              radius: 60,
                              imageUrl: userProfilePic,
                              userId: userId ?? '',
                              key: ValueKey(userProfilePic),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () async {
                          final File? selectedImage = await FilePickerHelper.showImageSourceDialog(context);

                          if (selectedImage != null) {
                            profileBloc.add(UpdateProfilePictureEvent(profilePicture: selectedImage));
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Form Fields
              CustomTextField(
                labelText: "Username",
                hintText: "Username",
                controller: _userNameController,
                prefixIcon: Icons.person,
                prefixIconColor: Colors.grey,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username is required';
                  }
                  if (value.length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),
              CustomTextField(
                labelText: "Full Name",
                hintText: "Enter full name",
                controller: _fullNameController,
                prefixIcon: Icons.person,
                prefixIconColor: Colors.grey,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Full name is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              CustomTextField(
                labelText: "Bio",
                hintText: "Enter bio",
                controller: _bioController,
                prefixIconColor: Colors.grey,
                maxLength: 200,
                maxLines: 4,
              ),

              const SizedBox(height: 20),

              // Gender Dropdown
              // CustomDropdownButton(
              //   hint: "Select gender",
              //   dropDownList: _genderOptions,
              //   controller: _genderDropdownController,
              //   label: "Gender",
              //   borderColor: Colors.grey,
              //   borderWidth: 1.5,
              //   borderRadius: 12,
              // ),

              const SizedBox(height: 90),
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  return CustomButton(
                    text: "Save",
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        final data = {
                          "userName": _userNameController.text.trim(),
                          "fullName": _fullNameController.text.trim(),
                          "bio": _bioController.text.trim(),
                        };
                        logDebug(message: "$data", tag: "User Data");

                        profileBloc.add(UpdateUserProfileDataEvent(body: data));
                      }
                    },
                    showLoader: state.updateUserDataApiStatus == ApiStatus.loading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileEditScreenDataModel {
  final User? userData;
  const ProfileEditScreenDataModel({required this.userData});
}
