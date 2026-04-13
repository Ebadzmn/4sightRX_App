import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../core/network/network_exception.dart';
import '../../data/models/patient_model.dart';
import '../../data/repositories/patient_repository.dart';

class PatientListController extends GetxController {
  static const int _pageSize = 10;

  final RxString searchQuery = ''.obs;
  final RxString selectedTab = 'ALL'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<PatientModel> allPatientList = <PatientModel>[].obs;
  final RxList<PatientModel> filteredList = <PatientModel>[].obs;

  final ScrollController scrollController = ScrollController();

  final PatientRepository _patientRepository = PatientRepository();

  final List<String> tabs = ['ALL', 'PENDING', 'ACTIVE', 'COMPLETED'];

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    getPatients();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void onTabChanged(String tab) {
    selectedTab.value = tab;
    filterByTab();
  }

  void onSearch(String query) {
    searchQuery.value = query;
    filterByTab();
  }

  Future<void> getPatients() async {
    currentPage = 1;
    totalPage = 1;
    hasMore = true;
    allPatientList.clear();
    filteredList.clear();
    errorMessage.value = '';

    await _fetchPage(page: currentPage, isInitialLoad: true);
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasMore) {
      return;
    }

    currentPage += 1;
    await _fetchPage(page: currentPage, isInitialLoad: false);
  }

  Future<void> onRefresh() async {
    await getPatients();
  }

  Future<void> _fetchPage({
    required int page,
    required bool isInitialLoad,
  }) async {
    if (isInitialLoad) {
      isLoading.value = true;
      errorMessage.value = '';
    } else {
      isLoadingMore.value = true;
    }

    try {
      final result = await _patientRepository.fetchPatients(
        page: page,
        limit: _pageSize,
      );

      if (result.patients.isNotEmpty) {
        allPatientList.addAll(result.patients);
      }

      currentPage = result.currentPage;
      totalPage = result.totalPages;
      hasMore = result.hasExplicitTotalPages
          ? currentPage < totalPage
          : result.hasMorePages;

      filterByTab();
    } on NetworkException catch (error) {
      errorMessage.value = _mapErrorMessage(error);
      allPatientList.clear();
      filteredList.clear();
      hasMore = false;
    } catch (_) {
      errorMessage.value = 'Something went wrong. Try again';
      allPatientList.clear();
      filteredList.clear();
      hasMore = false;
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void filterByTab() {
    Iterable<PatientModel> workingList = allPatientList;

    final search = searchQuery.value.trim().toLowerCase();
    if (search.isNotEmpty) {
      workingList = workingList.where((patient) {
        final fullName = '${patient.firstName} ${patient.lastName}'
            .toLowerCase();
        return fullName.contains(search) ||
            patient.patientIdMrn.toLowerCase().contains(search);
      });
    }

    switch (selectedTab.value) {
      case 'PENDING':
        workingList = workingList.where(
          (patient) => _matchesStatus(patient.status, 'PENDING'),
        );
        break;
      case 'ACTIVE':
        workingList = workingList.where(
          (patient) => _matchesStatus(patient.status, 'ACTIVE'),
        );
        break;
      case 'COMPLETED':
        workingList = workingList.where(
          (patient) => _matchesStatus(patient.status, 'COMPLETED'),
        );
        break;
      case 'ALL':
      default:
        break;
    }

    filteredList.assignAll(workingList);
  }

  void _onScroll() {
    if (!scrollController.hasClients ||
        isLoadingMore.value ||
        isLoading.value) {
      return;
    }

    if (scrollController.position.extentAfter < 200) {
      loadMore();
    }
  }

  bool _matchesStatus(String status, String target) {
    return status.trim().toUpperCase() == target.toUpperCase();
  }

  String _mapErrorMessage(NetworkException error) {
    final message = error.message.toLowerCase();

    if (error.statusCode == 500 || message.contains('server error')) {
      return 'Server error. Please try again';
    }

    if (message.contains('internet') || message.contains('connection')) {
      return 'No internet connection';
    }

    return message.isNotEmpty
        ? error.message
        : 'Something went wrong. Try again';
  }

  int currentPage = 0;
  int totalPage = 1;
  bool hasMore = true;
}
