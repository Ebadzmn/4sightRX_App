import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_controller.dart';
import '../patient_profile/pages/patient_profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: homeController.refreshProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Obx(() {
                  final profile = homeController.userProfile.value;

                  if (homeController.isProfileLoading.value) {
                    return Container(
                      width: double.infinity,
                      height: 160,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF38B6FF), Color(0xFF0C3064)],
                          begin: Alignment(-1.0, -0.5),
                          end: Alignment(1.0, 0.40),
                          stops: [0.0115, 0.4009],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  }

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF38B6FF), Color(0xFF0C3064)],
                        begin: Alignment(-1.0, -0.5),
                        end: Alignment(1.0, 0.40),
                        stops: [0.0115, 0.4009],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, ${profile?.name.isNotEmpty == true ? profile!.name : 'Dr. Johnson'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          profile?.email.isNotEmpty == true
                              ? '${profile!.role} • ${profile.email}'
                              : "St. Mary's General Hospital • Feb 8, 2026",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Colors.white30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Start New Reconciliation →'),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
                // Stats Row
                Row(
                  children: [
                    _buildStatCard(
                      '24',
                      'Active Patients',
                      Icons.people_outline,
                      const Color(0xFF3B82F6),
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      '16',
                      'Completed',
                      Icons.check_circle_outline,
                      const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      '\$8.4K',
                      'Monthly Savings',
                      Icons.trending_up,
                      const Color(0xFF10B981),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Search Bar
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search patients...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF94A3B8),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Recent Activity Header
                Row(
                  children: const [
                    Icon(Icons.access_time, color: Color(0xFF64748B), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Activity List
                _buildActivityItem(
                  'Margaret Thompson',
                  'Reconciliation completed',
                  '2 hours ago',
                  'Done',
                  const Color(0xFF10B981),
                ),
                _buildActivityItem(
                  'Robert Chen',
                  'Awaiting formulary review',
                  '4 hours ago',
                  'Pending',
                  const Color(0xFFF59E0B),
                ),
                _buildActivityItem(
                  'Sarah Williams',
                  'Uploaded med list',
                  '5 hours ago',
                  'In Progress',
                  const Color(0xFF3B82F6),
                ),
                const SizedBox(height: 24),
                // Quick Actions Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildActionItem(
                        'Start New Reconciliation',
                        const Color(0xFFF0F7FF),
                        const Color(0xFF2196F3),
                      ),
                      const SizedBox(height: 12),
                      _buildActionItem(
                        'View All Patients',
                        const Color(0xFFF8F9FB),
                        const Color(0xFF475569),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(08, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String name,
    String sub,
    String time,
    String status,
    Color statusColor,
  ) {
    return GestureDetector(
      onTap: () => Get.to(() => const PatientProfilePage()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      if (status == 'Done')
                        const Icon(
                          Icons.check,
                          size: 12,
                          color: Color(0xFF10B981),
                        ),
                      if (status == 'Pending')
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: Color(0xFFF59E0B),
                        ),
                      if (status == 'In Progress')
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                          ),
                        ),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 2),
            Text(
              time,
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(String title, Color bgColor, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: 16,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
