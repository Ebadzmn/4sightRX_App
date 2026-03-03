import 'package:get/get.dart';

class PatientsController extends GetxController {
  final RxString searchQuery = ''.obs;
  final RxInt selectedFilterIndex = 0.obs;

  final List<String> filters = ['All Patients', 'Recent', 'Pending Review'];

  final RxList<Map<String, dynamic>> patients = <Map<String, dynamic>>[
    {
      'name': 'Margaret Thompson',
      'id': 'MRN-45678',
      'room': '302A',
      'admittedDate': 'Jan 28, 2026',
    },
    {
      'name': 'Robert Chen',
      'id': 'MRN-45679',
      'room': '105B',
      'admittedDate': 'Feb 1, 2026',
    },
    {
      'name': 'Sarah Williams',
      'id': 'MRN-45680',
      'room': '212C',
      'admittedDate': 'Jan 28, 2026',
    },
    {
      'name': 'James Martinez',
      'id': 'MRN-45681',
      'room': '408A',
      'admittedDate': 'Jan 28, 2026',
    },
    {
      'name': 'Linda Johnson',
      'id': 'MRN-45682',
      'room': '301B',
      'admittedDate': 'Feb 5, 2026',
    },
  ].obs;

  void changeFilter(int index) {
    selectedFilterIndex.value = index;
  }

  void onSearch(String query) {
    searchQuery.value = query;
  }
}
