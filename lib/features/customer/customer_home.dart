import 'package:flutter/material.dart';

// นำเข้าไฟล์ Tab ต่างๆ ที่เราสร้างไว้ (ดูจากโครงสร้างไฟล์ของหัวหน้า)
import 'tabs/home_tab.dart';
import 'tabs/bookings_tab.dart';
import 'tabs/promos_tab.dart';
import 'tabs/setting_tab.dart'; // 👈 นำเข้าไฟล์ Settings ที่เพิ่งทำเสร็จ

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _currentNavIndex = 0;

  // 🗂️ หน้าย่อยที่จะแสดงตามที่กดเมนูด้านล่าง (ยกเว้น Settings เพราะเราจะให้มันเด้งขึ้นมา)
  final List<Widget> _screens = [
    const HomeTab(), // Index 0
    const BookingsTab(), // Index 1
    const PromosTab(), // Index 2
  ];

  // 🛠️ ฟังก์ชันเรียกหน้า Settings ให้เด้งขึ้นมาจากขอบล่าง
  void _showSettingBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ยอมให้ Bottom Sheet สูงได้
      backgroundColor: Colors.transparent, // ให้พื้นหลังโปร่งใสเพื่อทำขอบมน
      builder: (context) {
        return Container(
          height:
              MediaQuery.of(context).size.height * 0.85, // สูง 85% ของหน้าจอ
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: const SettingTab(), // 👈 เรียกหน้า SettingTab มาแสดงตรงนี้
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      // 📱 ส่วนแสดงผลหน้าจอหลัก
      body: _screens[_currentNavIndex],

      // 🔘 แถบเมนูด้านล่าง (Bottom Navigation Bar แบบ Custom สวยๆ)
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          margin: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(
                  15,
                ), // แก้จาก withOpacity เพื่อลบเส้นเหลือง
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
              _buildNavItem(
                Icons.settings_rounded,
                'Settings',
                3,
              ), // ปุ่มที่ 4 สำหรับ Settings
            ],
          ),
        ),
      ),
    );
  }

  // 🎨 ฟังก์ชันวาดปุ่มเมนูแต่ละอัน
  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _currentNavIndex == index;
    bool isSettingsBtn =
        index == 3; // เช็คว่าเป็นปุ่ม Settings (อันที่ 4) หรือเปล่า

    return GestureDetector(
      onTap: () {
        if (isSettingsBtn) {
          // ถ้ากดปุ่ม Settings ให้เรียก Bottom Sheet เด้งขึ้นมา
          _showSettingBottomSheet(context);
        } else {
          // ถ้ากดปุ่มอื่น ให้สลับหน้าปกติ
          setState(() => _currentNavIndex = index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          // ถ้าปุ่มนี้ถูกเลือก และไม่ใช่ปุ่ม Settings ให้มีพื้นหลังสีฟ้าอ่อน
          color: (isActive && !isSettingsBtn)
              ? Colors.blueAccent.withAlpha(
                  25,
                ) // ใช้ withAlpha(25) แทน withOpacity(0.1) ตามที่ระบบแนะนำ
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: (isActive && !isSettingsBtn)
                  ? Colors.blueAccent
                  : Colors.grey.shade400,
              size: 26,
            ),
            // โชว์ข้อความเฉพาะตอนที่ปุ่มนั้นถูกเลือก (และต้องไม่ใช่ปุ่ม Settings)
            if (isActive && !isSettingsBtn) ...[
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
