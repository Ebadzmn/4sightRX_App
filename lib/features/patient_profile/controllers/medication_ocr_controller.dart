import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../../../core/network/network_exception.dart';
import '../../../data/models/medication_model.dart';
import '../../../data/repositories/medication_repository.dart';

class MedicationOcrController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool hasStartedExtraction = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString patientId = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxList<File> selectedFiles = <File>[].obs;
  final RxList<MedicationModel> medicationList = <MedicationModel>[].obs;
  
  final RxInt activePreviewIndex = 0.obs;
  late PageController pageController;

  final ImagePicker _imagePicker = ImagePicker();
  final MedicationRepository _medicationRepository = MedicationRepository();

  bool get hasSelectedFile => selectedFiles.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onThumbnailTapped(int index) {
    if (index >= 0 && index < selectedFiles.length) {
      activePreviewIndex.value = index;
      if (pageController.hasClients) {
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void configureForPatient(String value) {
    final trimmedValue = value.trim();
    if (patientId.value == trimmedValue) {
      return;
    }

    patientId.value = trimmedValue;
    selectedFiles.clear();
    activePreviewIndex.value = 0;
    isLoading.value = false;
    isSubmitting.value = false;
    hasStartedExtraction.value = false;
    clearResults();
  }

  void clearResults() {
    medicationList.clear();
    errorMessage.value = '';
  }

  void addFiles(List<File> files) {
    // Avoid duplicates based on path
    bool hasNewFiles = false;
    for (final file in files) {
      if (!selectedFiles.any((f) => f.path == file.path)) {
        selectedFiles.add(file);
        hasNewFiles = true;
      }
    }
    
    if (hasNewFiles && selectedFiles.isNotEmpty) {
      activePreviewIndex.value = selectedFiles.length - 1;
      Future.delayed(const Duration(milliseconds: 50), () {
        if (pageController.hasClients) {
          pageController.jumpToPage(activePreviewIndex.value);
        }
      });
    }
    
    clearResults();
  }

  void removeFile(int index) {
    if (index >= 0 && index < selectedFiles.length) {
      selectedFiles.removeAt(index);
      
      if (selectedFiles.isEmpty) {
        activePreviewIndex.value = 0;
      } else if (activePreviewIndex.value >= selectedFiles.length) {
        activePreviewIndex.value = selectedFiles.length - 1;
      }
    }
  }

  void appendMedication(MedicationModel medication) {
    medicationList.add(medication);
  }

  void updateMedicationField(int index, String field, String value) {
    if (index < 0 || index >= medicationList.length) return;
    
    final current = medicationList[index];
    MedicationModel updated;
    
    switch (field) {
      case 'dose':
        updated = current.copyWith(dose: value);
        break;
      case 'route':
        updated = current.copyWith(route: value);
        break;
      case 'duration':
        updated = current.copyWith(duration: value);
        break;
      default:
        return;
    }
    
    medicationList[index] = updated;
  }

  void clearReviewedMedications() {
    medicationList.clear();
  }

  Future<bool> pickImageFromGallery() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        addFiles(pickedFiles.map((p) => File(p.path)).toList());
        return true;
      }
    } catch (e) {
      _showError('Failed to pick images');
    }
    return false;
  }

  Future<bool> captureImageFromCamera() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // Compression as requested
      );
      if (picked != null) {
        addFiles([File(picked.path)]);
        return true;
      }
    } on PlatformException catch (e) {
      if (e.code == 'camera_access_denied') {
        _showError('Camera permission denied');
      } else {
        _showError('Failed to capture image');
      }
    } catch (e) {
      _showError('Failed to capture image');
    }
    return false;
  }

  Future<void> pickPdfDocument() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final files = result.files
            .where((f) => f.path != null)
            .map((f) => File(f.path!))
            .toList();
        addFiles(files);
      }
    } on MissingPluginException {
      errorMessage.value =
          'File picker is not ready. Stop the app and run it again.';
      _showError(errorMessage.value);
    } catch (_) {
      errorMessage.value = 'Upload failed';
      _showError('Upload failed');
    }
  }

  Future<bool> extractMedications() async {
    if (isLoading.value) {
      return false;
    }

    if (selectedFiles.isEmpty) {
      errorMessage.value = 'No files selected';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _medicationRepository.extractMedications(selectedFiles);
      medicationList.assignAll(result);
      if (result.isEmpty) {
        throw NetworkException(message: 'No medications detected');
      }
      return true;
    } on NetworkException catch (error) {
      if (error.statusCode == 401) {
        return false;
      }

      final mappedMessage = _mapErrorMessage(error);
      errorMessage.value = mappedMessage;
      medicationList.clear();
      return false;
    } catch (_) {
      const fallback = 'Failed to extract medications';
      errorMessage.value = fallback;
      medicationList.clear();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<String>> submitReviewedMedications() async {
    if (isSubmitting.value) {
      return <String>[];
    }

    if (medicationList.isEmpty) {
      errorMessage.value = 'No medications to save';
      _showError('No medications to save');
      return <String>[];
    }

    isSubmitting.value = true;
    errorMessage.value = '';

    try {
      final medicationIds = await _medicationRepository
          .submitReviewedMedications(medicationList);
      clearReviewedMedications();
      selectedFiles.clear();
      hasStartedExtraction.value = false;
      return medicationIds;
    } on NetworkException catch (error) {
      if (error.statusCode == 401) {
        return <String>[];
      }

      final mappedMessage = _mapSaveErrorMessage(error);
      errorMessage.value = mappedMessage;
      _showError(mappedMessage);
      return <String>[];
    } catch (_) {
      const fallback = 'Failed to save medications';
      errorMessage.value = fallback;
      _showError(fallback);
      return <String>[];
    } finally {
      isSubmitting.value = false;
    }
  }

  String _mapSaveErrorMessage(NetworkException error) {
    final message = error.message.toLowerCase();

    if (message.contains('internet') || message.contains('connection')) {
      return 'No internet connection';
    }

    if (error.statusCode == 500 || message.contains('server error')) {
      return 'Server error. Please try again';
    }

    if (message.contains('already exists') || message.contains('duplicate')) {
      return 'Medication already exists';
    }

    return 'Failed to save medications';
  }

  String get selectedFileType {
    if (selectedFiles.isEmpty) return '';
    final path = selectedFiles.last.path.toLowerCase();
    if (path.endsWith('.pdf')) return 'PDF Document';
    if (path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png')) return 'Image File';
    return 'Unknown';
  }

  String _mapErrorMessage(NetworkException error) {
    final message = error.message.toLowerCase();

    if (message.contains('no medications detected') ||
        message.contains('no data') ||
        message.contains('not found') ||
        message.contains('empty')) {
      return 'No medications detected';
    }

    if (message.contains('internet') || message.contains('connection')) {
      return 'No internet connection';
    }

    if (error.statusCode == 500 || message.contains('server error')) {
      return 'Failed to extract medications';
    }

    return 'Failed to extract medications';
  }

  void _showError(String message) {
    Get.snackbar(
      'Medication OCR',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
