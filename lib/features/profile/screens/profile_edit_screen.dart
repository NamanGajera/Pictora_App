import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:pictora/core/utils/constants/colors.dart';
import 'package:pictora/core/utils/constants/constants.dart';
import 'package:pictora/core/utils/widgets/custom_widget.dart';
import 'package:pictora/router/router.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _genderDropdownController = SingleValueDropDownController();

  String? _profileImagePath;

  final List<DropDownValueModel> _genderOptions = [
    DropDownValueModel(name: "Male", value: "Male"),
    DropDownValueModel(name: "Female", value: "Female"),
    DropDownValueModel(name: "Other", value: "Other"),
  ];

  @override
  void initState() {
    super.initState();
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(65),
                        child: _profileImagePath != null
                            ? Image.asset(
                                _profileImagePath!,
                                fit: BoxFit.cover,
                              )
                            : RoundProfileAvatar(
                                radius: 60,
                                imageUrl: userProfilePic,
                                userId: userId ?? '',
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () {},
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
                labelText: "Bio",
                hintText: "Enter bio",
                prefixIconColor: Colors.grey,
                maxLength: 150,
                maxLines: 4,
              ),

              const SizedBox(height: 20),

              // Gender Dropdown
              CustomDropdownButton(
                hint: "Select gender",
                dropDownList: _genderOptions,
                controller: _genderDropdownController,
                label: "Gender",
                borderColor: Colors.grey,
                borderWidth: 1.5,
                borderRadius: 12,
              ),

              const SizedBox(height: 90),
              CustomButton(
                text: "Save",
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
