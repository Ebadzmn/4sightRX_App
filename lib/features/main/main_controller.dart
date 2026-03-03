import 'package:get/get.dart';
import '../home/home_page.dart';
import '../patients/patients_page.dart';
import 'package:flutter/material.dart';

class MainController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  final List<Widget> pages = [
    const HomePage(),
    const PatientsPage(),
    const Center(child: Text('Profile Page')), // Placeholder for now
  ];

  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }
}
