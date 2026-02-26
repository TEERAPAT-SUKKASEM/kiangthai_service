import 'package:flutter/material.dart';

class TechnicianHomePage extends StatefulWidget {
  const TechnicianHomePage({super.key});

  @override
  State<TechnicianHomePage> createState() => _TechnicianHomePageState();
}

class _TechnicianHomePageState extends State<TechnicianHomePage> {
  int _currentNavIndex = 0;

  // 🧠 รายการหน้าต่างทั้งหมดของช่าง
  final List<Widget> _pages = [
    const Center(
      child: Text('Job Board (รอดึงข้อมูลงานใหม่)'),
    ), // เดี๋ยวเรามาสร้างหน้านี้
    const Center(
      child: Text('My Jobs (งานที่กำลังทำ)'),
    ), // เดี๋ยวเรามาสร้างหน้านี้
    const Center(
      child: Text('Settings (ตั้งค่าของช่าง)'),
    ), // เดี๋ยวเรามาสร้างหน้านี้
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey.shade100, // สีพื้นหลังช่างจะเข้มขึ้นนิดนึงให้ดูดิบๆ
      appBar: AppBar(
        title: const Text(
          'Technician Portal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey.shade900, // ธีมช่างใช้สีเข้มดูโปรฯ
        elevation: 0,
        centerTitle: true,
      ),
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
                color: Colors.blueGrey.shade900, // พื้นหลังบาร์สีเข้ม
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
              : Colors.transparent, // ถ้าเลือก ให้เป็นสีเหลืองช่าง
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
