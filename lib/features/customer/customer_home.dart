import 'package:flutter/material.dart';

// --- นำเข้าไฟล์ Tabs ---
import 'tabs/home_tab.dart';
import 'tabs/promos_tab.dart';
import 'tabs/bookings_tab.dart';
// 🚀 นำเข้าไฟล์ setting ที่เราเพิ่งสร้าง
import 'tabs/setting_tab.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _currentNavIndex = 0;

  // 🧠 รายการหน้าต่างทั้งหมด (มีแค่ 3 หน้า)
  final List<Widget> _pages = [
    const HomeTab(),
    const PromosTab(),
    const BookingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          // 1. เลเยอร์เนื้อหา
          _pages[_currentNavIndex],

          // 2. เลเยอร์ Floating Bottom Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(Icons.home_filled, 'Home', 0),
                  _buildNavItem(Icons.local_offer, 'Promos', 1),
                  _buildNavItem(Icons.receipt_long, 'Bookings', 2),
                  _buildNavItem(
                    Icons.settings,
                    'Settings',
                    3,
                  ), // ปุ่มนี้เอาไว้เรียก BottomSheet
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _currentNavIndex == index;
    bool isSettingsBtn = index == 3;

    return GestureDetector(
      onTap: () {
        if (isSettingsBtn) {
          // 🚀 เรียกใช้งานฟังก์ชันที่นำเข้าจาก setting.dart
          showSettingBottomSheet(context);
        } else {
          setState(() => _currentNavIndex = index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: (isActive && !isSettingsBtn)
              ? Colors.blueAccent.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: (isActive && !isSettingsBtn)
                  ? Colors.blueAccent
                  : Colors.grey.shade500,
              size: 26,
            ),
            if (isActive && !isSettingsBtn) ...[
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
