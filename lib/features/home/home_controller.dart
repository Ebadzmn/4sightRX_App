import 'package:get/get.dart';

import '../../core/network/network_exception.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/login_response.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/activity_model.dart';
import '../../data/repositories/analytics_repository.dart';

class HomeController extends GetxController {
  final RxBool isProfileLoading = false.obs;
  final Rxn<UserModel> userProfile = Rxn<UserModel>();

  final RxList<ActivityModel> activityList = <ActivityModel>[].obs;
  final RxBool isActivityLoading = false.obs;

  final AuthRepository _authRepository = AuthRepository();
  final StorageService _storageService = StorageService();
  final AnalyticsRepository _analyticsRepository = AnalyticsRepository();

  @override
  void onInit() {
    super.onInit();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    await _loadCachedProfile();
    await Future.wait([
      getProfile(),
      fetchActivities(),
    ]);
  }

  Future<void> _loadCachedProfile() async {
    final name = await _storageService.getUserName();
    final email = await _storageService.getUserEmail();
    final role = await _storageService.getUserRole();
    final image = await _storageService.getUserImage();
    final specialty = await _storageService.getUserSpecialty();
    final hospitalName = await _storageService.getUserHospitalName();
    final status = await _storageService.getUserStatus();
    final verified = await _storageService.getUserVerified();

    if ((name ?? '').isEmpty && (email ?? '').isEmpty) {
      return;
    }

    userProfile.value = UserModel(
      id: '',
      name: name ?? '',
      email: email ?? '',
      role: role ?? '',
      image: image ?? '',
      specialty: specialty ?? '',
      hospitalName: hospitalName ?? '',
      status: status ?? '',
      verified: verified ?? false,
    );
  }

  Future<void> getProfile() async {
    isProfileLoading.value = true;
    try {
      final profile = await _authRepository.getProfile();
      userProfile.value = profile;
    } on NetworkException catch (error) {
      if (error.statusCode != 401) {
        Get.snackbar(
          'Profile',
          _mapErrorMessage(error),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      Get.snackbar(
        'Profile',
        'Something went wrong. Try again',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProfileLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    await Future.wait([
      getProfile(),
      fetchActivities(),
    ]);
  }

  Future<void> fetchActivities() async {
    isActivityLoading.value = true;
    try {
      final activities = await _analyticsRepository.fetchRecentActivities();
      activityList.assignAll(activities);
    } catch (e) {
      Get.snackbar(
        'Activities',
        'Failed to load activities',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isActivityLoading.value = false;
    }
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

    if (message.contains('internet') || message.contains('connection')) {
      return 'No internet connection';
    }

    return 'Something went wrong. Try again';
  }
}
