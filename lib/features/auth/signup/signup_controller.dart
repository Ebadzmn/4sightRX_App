import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/network_exception.dart';
import '../../../data/models/organization_model.dart';
import '../../../data/models/sign_up_request.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/organization_repository.dart';
import '../../../routes/app_routes.dart';

enum OrganizationLoadStatus { idle, loading, success, empty, error }

class SignupController extends GetxController {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxList<OrganizationModel> organizations = <OrganizationModel>[].obs;
  final Rx<OrganizationLoadStatus> organizationLoadStatus =
      OrganizationLoadStatus.idle.obs;
  final RxString selectedOrganizationId = ''.obs;

  final AuthRepository _authRepository = AuthRepository();
  final OrganizationRepository _organizationRepository =
      OrganizationRepository();

  @override
  void onInit() {
    super.onInit();
    fetchOrganizations();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void resetForm() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    isPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
    selectedOrganizationId.value = '';
  }

  Future<void> fetchOrganizations({bool force = false}) async {
    if (organizationLoadStatus.value == OrganizationLoadStatus.loading) {
      return;
    }

    if (!force &&
        organizationLoadStatus.value == OrganizationLoadStatus.success &&
        organizations.isNotEmpty) {
      return;
    }

    organizationLoadStatus.value = OrganizationLoadStatus.loading;
    organizations.clear();
    selectedOrganizationId.value = '';

    try {
      final fetchedOrganizations = await _organizationRepository
          .getOrganizations();
      organizations.assignAll(fetchedOrganizations);
      organizationLoadStatus.value = fetchedOrganizations.isEmpty
          ? OrganizationLoadStatus.empty
          : OrganizationLoadStatus.success;
    } on NetworkException catch (error) {
      organizationLoadStatus.value = OrganizationLoadStatus.error;
      _showOrganizationError(error);
    } catch (_) {
      organizationLoadStatus.value = OrganizationLoadStatus.error;
      Get.snackbar(
        'Organizations failed',
        'Something went wrong. Try again',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> signUp(GlobalKey<FormState> formKey) async {
    if (!_validate(formKey) || isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      await _authRepository.signUp(
        request: SignUpRequest(
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          email: emailController.text.trim(),
          organizationId: selectedOrganizationId.value.trim(),
          password: passwordController.text,
        ),
      );
      Get.snackbar(
        'Success',
        'Account created successfully 🎉',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed(
        AppRoutes.login,
        arguments: {'email': emailController.text.trim()},
      );
    } on NetworkException catch (error) {
      Get.snackbar(
        'Sign up failed',
        _mapErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Sign up failed',
        'Something went wrong. Try again',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validate(GlobalKey<FormState> formKey) {
    if (organizationLoadStatus.value == OrganizationLoadStatus.loading) {
      Get.snackbar(
        'Sign up failed',
        'Organizations are still loading. Please wait.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (organizationLoadStatus.value == OrganizationLoadStatus.error) {
      Get.snackbar(
        'Sign up failed',
        'Unable to load organizations. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (organizationLoadStatus.value == OrganizationLoadStatus.empty ||
        organizations.isEmpty) {
      Get.snackbar(
        'Sign up failed',
        'No organizations are available.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (selectedOrganizationId.value.trim().isEmpty ||
        !organizations.any(
          (organization) => organization.id == selectedOrganizationId.value,
        )) {
      Get.snackbar(
        'Sign up failed',
        'Please select an organization',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final formState = formKey.currentState;
    if (formState == null) {
      return false;
    }

    final isValid = formState.validate();
    if (!isValid) {
      Get.snackbar(
        'Sign up failed',
        'Please fill all fields correctly',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    return isValid;
  }

  void _showOrganizationError(NetworkException error) {
    final message = error.message.toLowerCase();
    String errorMessage = 'Unable to load organizations. Please try again.';

    if (error.statusCode == 500 || message.contains('server error')) {
      errorMessage = 'Server error. Please try again';
    } else if (message.contains('internet') || message.contains('connection')) {
      errorMessage = 'No internet connection';
    } else if (message.contains('unauthorized') ||
        message.contains('forbidden')) {
      errorMessage = 'You are not authorized to load organizations';
    } else if (error.message.isNotEmpty) {
      errorMessage = error.message;
    }

    Get.snackbar(
      'Organizations failed',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String _mapErrorMessage(NetworkException error) {
    final message = error.message.toLowerCase();

    if (error.statusCode == 500 || message.contains('server error')) {
      return 'Server error. Please try again';
    }

    if (message.contains('already') || message.contains('exists')) {
      return 'This email is already registered';
    }

    if (message.contains('invalid') ||
        message.contains('required') ||
        message.contains('missing') ||
        message.contains('fill')) {
      return 'Please fill all fields correctly';
    }

    if (message.contains('internet') || message.contains('connection')) {
      return 'No internet connection';
    }

    return 'Something went wrong. Try again';
  }
}
