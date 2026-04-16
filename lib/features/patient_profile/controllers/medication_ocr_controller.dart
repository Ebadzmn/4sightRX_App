import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

import '../../../core/network/network_exception.dart';
import '../../../data/models/medication_model.dart';
import '../../../data/repositories/medication_repository.dart';

class MedicationOcrController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool hasStartedExtraction = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString patientId = ''.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<File> selectedFile = Rxn<File>();
  final RxString selectedFileName = ''.obs;
  final RxString selectedFileType = ''.obs;
  final RxList<MedicationModel> medicationList = <MedicationModel>[].obs;

  final ImagePicker _imagePicker = ImagePicker();
  final MedicationRepository _medicationRepository = MedicationRepository();

  bool get hasSelectedFile => selectedFile.value != null;

  void configureForPatient(String value) {
    final trimmedValue = value.trim();
    if (patientId.value == trimmedValue) {
      return;
    }

    patientId.value = trimmedValue;
    selectedFile.value = null;
    selectedFileName.value = '';
    selectedFileType.value = '';
    isLoading.value = false;
    isSubmitting.value = false;
    hasStartedExtraction.value = false;
    clearResults();
  }

  void clearResults() {
    medicationList.clear();
    errorMessage.value = '';
  }

  void setSelectedFile(File file, {String? fileType}) {
    selectedFile.value = file;
    selectedFileName.value = _fileName(file);
    selectedFileType.value = fileType ?? _inferFileType(file);
    clearResults();
  }

  void appendMedication(MedicationModel medication) {
    medicationList.add(medication);
  }

  void clearReviewedMedications() {
    medicationList.clear();
  }

  Future<void> pickImageFromGallery() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return;
    }

    setSelectedFile(File(picked.path), fileType: 'Image');
  }

  Future<void> captureImageFromCamera() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.camera);
    if (picked == null) {
      return;
    }

    setSelectedFile(File(picked.path), fileType: 'Image');
  }

  Future<void> pickPdfDocument() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );

      final path = result?.files.single.path;
      if (path == null || path.isEmpty) {
        return;
      }

      setSelectedFile(File(path), fileType: 'PDF');
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

    final file = selectedFile.value;
    if (file == null) {
      errorMessage.value = 'Upload failed';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _medicationRepository.extractMedications(file);
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
      selectedFile.value = null;
      selectedFileName.value = '';
      selectedFileType.value = '';
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

  String _fileName(File file) {
    return file.path.split(Platform.pathSeparator).last;
  }

  String _inferFileType(File file) {
    final lower = file.path.toLowerCase();
    if (lower.endsWith('.pdf')) {
      return 'PDF';
    }

    return 'Image';
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
