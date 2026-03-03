import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'features/splash/splash_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoursightRX',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashPage(),
    );
  }
}
