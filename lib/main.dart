import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app.dart';
import 'core/services/connectivity_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync<ConnectivityService>(() async => ConnectivityService().init(), permanent: true);
  runApp(const MyApp());
}
