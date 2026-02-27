import 'package:flutter/material.dart';

// นำเข้าหน้าของช่าง (เดี๋ยวเราจะสร้างไฟล์นี้ในสเต็ป 2)
import 'tech_job_board_tab.dart';

class TechnicianHomePage extends StatefulWidget {
  const TechnicianHomePage({super.key});

  @override
  State<TechnicianHomePage> createState() => _TechnicianHomePageState();
}

class _TechnicianHomePageState extends State<TechnicianHomePage> {
  int _currentNavIndex = 0;

  // 🧠 หน้าต่างทั้งหมดของช่าง
  final List<Widget> _pages = [
    const TechJobBoardTab(), // หน้ากระดานงาน (มี Toggle รับงาน/ที่ต้องทำ)
    const Center(child: Text('My Jobs (ประวัติงาน/รายได้)')), // เดี๋ยวทำต่อ
    const Center(child: Text('Settings (ตั้งค่าบัญชีช่าง)')), // เดี๋ยวทำต่อ
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // สีพื้นหลังแอปช่าง
      body: Stack(
        children: [
          // 1. เลเยอร์เนื้อหาหลัก
          _pages[_currentNavIndex],

          // 2. เลเยอร์ Floating Bottom Bar (สไตล์เดียวกับฝั่งลูกค้า)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade900, // ใช้สีเข้ม ดุดัน สไตล์ช่าง
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.assignment, 'Job Board', 0),
                  _buildNavItem(Icons.handyman, 'My Jobs', 1),
                  _buildNavItem(Icons.settings, 'Settings', 2),
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
    return GestureDetector(
      onTap: () => setState(() => _currentNavIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.amber.shade400
              : Colors.transparent, // ไฮไลท์สีเหลืองช่าง
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.blueGrey.shade900 : Colors.grey.shade400,
              size: 24,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.blueGrey.shade900,
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
