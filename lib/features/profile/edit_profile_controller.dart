import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/network/network_exception.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/login_response.dart';
import '../../data/repositories/auth_repository.dart';
import '../home/home_controller.dart';

class EditProfileController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController specialtyController = TextEditingController();
  final TextEditingController hospitalController = TextEditingController();
  final RxBool isLoading = false.obs;
  final Rxn<File> selectedImage = Rxn<File>();

  final AuthRepository _authRepository = AuthRepository();
  final StorageService _storageService = StorageService();

  UserModel? currentProfile;

  @override
  void onInit() {
    super.onInit();
    loadInitialValues();
  }

  Future<void> loadInitialValues() async {
    final homeController = Get.find<HomeController>();
    currentProfile = homeController.userProfile.value;
    selectedImage.value = null;

    nameController.text = currentProfile?.name.isNotEmpty == true
        ? currentProfile!.name
        : (await _storageService.getUserName()) ?? '';
    specialtyController.text = currentProfile?.specialty.isNotEmpty == true
        ? currentProfile!.specialty
        : (await _storageService.getUserSpecialty()) ?? '';
    hospitalController.text = currentProfile?.hospitalName.isNotEmpty == true
        ? currentProfile!.hospitalName
        : (await _storageService.getUserHospitalName()) ?? '';
  }

  @override
  void onClose() {
    nameController.dispose();
    specialtyController.dispose();
    hospitalController.dispose();
    super.onClose();
  }

  Future<void> updateProfile() async {
    final name = _fieldIfChanged(
      nameController.text,
      currentProfile?.name ?? '',
    );
    final specialty = _fieldIfChanged(
      specialtyController.text,
      currentProfile?.specialty ?? '',
    );
    final hospitalName = _fieldIfChanged(
      hospitalController.text,
      currentProfile?.hospitalName ?? '',
    );

    if (!_validate(
      name: name,
      specialty: specialty,
      hospitalName: hospitalName,
    )) {
      return;
    }

    isLoading.value = true;
    try {
      await _authRepository.updateProfile(
        name: name,
        specialty: specialty,
        hospitalName: hospitalName,
        imageFile: selectedImage.value,
      );

      await Get.find<HomeController>().getProfile();
      Get.back();

      Future.delayed(const Duration(milliseconds: 250), () {
        Get.snackbar(
          'Success',
          'Profile updated successfully ✅',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    } on NetworkException catch (error) {
      Get.snackbar(
        'Update failed',
        _mapErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Update failed',
        'Something went wrong. Try again',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validate({
    required String? name,
    required String? specialty,
    required String? hospitalName,
  }) {
    if (name == null &&
        specialty == null &&
        hospitalName == null &&
        selectedImage.value == null) {
      Get.snackbar(
        'Update failed',
        'No changes to update',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final imageFile = selectedImage.value;
    if (imageFile != null) {
      final lowerPath = imageFile.path.toLowerCase();
      final isValidImage =
          lowerPath.endsWith('.jpg') ||
          lowerPath.endsWith('.jpeg') ||
          lowerPath.endsWith('.png');
      if (!isValidImage) {
        Get.snackbar(
          'Update failed',
          'Please select a valid image',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final sizeInBytes = imageFile.lengthSync();
      if (sizeInBytes > 5 * 1024 * 1024) {
        Get.snackbar(
          'Update failed',
          'Image size too large',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    }

    return true;
  }

  String? _fieldIfChanged(String value, String originalValue) {
    final trimmedValue = value.trim();
    final trimmedOriginal = originalValue.trim();

    if (trimmedValue.isEmpty || trimmedValue == trimmedOriginal) {
      return null;
    }

    return trimmedValue;
  }

  void setSelectedImage(File? image) {
    selectedImage.value = image;
  }

  String _mapErrorMessage(NetworkException error) {
    final message = error.message.toLowerCase();

    if (error.statusCode == 500 || message.contains('server error')) {
      return 'Server error. Please try again';
    }

    if (message.contains('profile not found') ||
        message.contains('not found')) {
      return 'Profile not found';
    }

    if (message.contains('valid image')) {
      return 'Please select a valid image';
    }

    if (message.contains('large')) {
      return 'Image size too large';
    }

    if (message.contains('internet') || message.contains('connection')) {
      return 'No internet connection';
    }

    return 'Something went wrong. Try again';
  }
}
