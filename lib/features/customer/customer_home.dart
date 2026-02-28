import 'package:flutter/material.dart';

import 'tabs/home_tab.dart';
import 'tabs/bookings_tab.dart';
import 'tabs/promos_tab.dart';
import 'tabs/setting_tab.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _currentNavIndex = 0;

  // 🗂️ แก๊งค์หน้าจอทั้ง 4 (เพิ่ม SettingTab เข้ามาต่อท้ายเป็นหน้าที่ 4 เรียบร้อย!)
  final List<Widget> _screens = [
    const HomeTab(), // Index 0
    const BookingsTab(), // Index 1
    const PromosTab(), // Index 2
    const SettingTab(), // Index 3 👈 อยู่ตรงนี้แล้ว!
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      // 📱 ส่วนแสดงผลหน้าจอหลัก (กดปุ่มไหน โชว์หน้านั้น)
      body: _screens[_currentNavIndex],

      // 🔘 แถบเมนูด้านล่าง (Bottom Navigation Bar)
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          margin: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home_rounded, 'Home', 0),
              _buildNavItem(Icons.assignment_rounded, 'Bookings', 1),
              _buildNavItem(Icons.local_offer_rounded, 'Promos', 2),
              _buildNavItem(Icons.settings_rounded, 'Settings', 3),
            ],
          ),
        ),
      ),
    );
  }

  // 🎨 ฟังก์ชันวาดปุ่มเมนูแต่ละอัน (ปรับให้เหมือนกันทุกปุ่มแล้ว!)
  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _currentNavIndex == index;

    return GestureDetector(
      onTap: () {
        // 🔄 กดปุ่มไหน ก็แค่สลับไปหน้านั้นตรงๆ ไม่ต้องเด้ง Pop-up แล้ว
        setState(() => _currentNavIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.blueAccent.withAlpha(25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.blueAccent : Colors.grey.shade400,
              size: 26,
            ),
            // โชว์ข้อความเฉพาะตอนที่ปุ่มนั้นถูกเลือก
            if (isActive) ...[
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
