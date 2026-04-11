import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../home/home_controller.dart';
import 'edit_profile_controller.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final EditProfileController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<EditProfileController>()
        ? Get.find<EditProfileController>()
        : Get.put(EditProfileController(), permanent: true);
    controller.loadInitialValues();
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF334155)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Obx(() {
                  final selected = controller.selectedImage.value;
                  final profile = homeController.userProfile.value;
                  final imageUrl = selected != null
                      ? selected.path
                      : profile?.resolvedImagePath ?? '';

                  return Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: const Color(0xFFE2E8F0),
                        backgroundImage: selected != null
                            ? FileImage(selected)
                            : imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : null,
                        child: imageUrl.isEmpty
                            ? Text(
                                _buildInitials(
                                  controller.nameController.text.isNotEmpty
                                      ? controller.nameController.text
                                      : profile?.name ?? 'U',
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : null,
                      ),
                      GestureDetector(
                        onTap: _showImagePickerOptions,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0C4A6E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 28),
              _buildLabel('Name'),
              const SizedBox(height: 8),
              _buildInput(controller.nameController, 'Enter name'),
              const SizedBox(height: 18),
              _buildLabel('Specialty'),
              const SizedBox(height: 8),
              _buildInput(controller.specialtyController, 'Enter specialty'),
              const SizedBox(height: 18),
              _buildLabel('Hospital Name'),
              const SizedBox(height: 8),
              _buildInput(controller.hospitalController, 'Enter hospital name'),
              const SizedBox(height: 28),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C4A6E),
                      disabledBackgroundColor: const Color(
                        0xFF0C4A6E,
                      ).withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Update Profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage == null) {
      return;
    }

    controller.setSelectedImage(File(pickedImage.path));
  }

  Future<void> _pickCameraImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);
    if (pickedImage == null) {
      return;
    }

    controller.setSelectedImage(File(pickedImage.path));
  }

  Future<void> _showImagePickerOptions() async {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSheetOption(
                icon: Icons.photo_library_outlined,
                label: 'Choose from gallery',
                onTap: () {
                  Get.back();
                  _pickImage();
                },
              ),
              const SizedBox(height: 12),
              _buildSheetOption(
                icon: Icons.photo_camera_outlined,
                label: 'Take a photo',
                onTap: () {
                  Get.back();
                  _pickCameraImage();
                },
              ),
              const SizedBox(height: 12),
              _buildSheetOption(
                icon: Icons.delete_outline,
                label: 'Remove selected image',
                onTap: () {
                  Get.back();
                  controller.setSelectedImage(null);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF0C4A6E)),
      title: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInput(TextEditingController textController, String hint) {
    return TextField(
      controller: textController,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFF0C4A6E)),
        ),
      ),
    );
  }

  String _buildInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'U';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts[1].substring(0, 1)}'
        .toUpperCase();
  }
}
