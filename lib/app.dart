import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/services/connectivity_service.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoursightRX',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: AppRoutes.initial,
      getPages: AppPages.pages,
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            const Positioned(top: 0, left: 0, right: 0, child: _OfflineBanner()),
          ],
        );
      },
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isOffline = Get.find<ConnectivityService>().isOffline.value;
      if (!isOffline) {
        return const SizedBox.shrink();
      }

      return SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Material(
            color: const Color(0xFF111827),
            elevation: 8,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: const [
                  Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No internet connection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
