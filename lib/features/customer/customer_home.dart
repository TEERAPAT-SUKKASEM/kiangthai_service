import 'package:flutter/material.dart';
import 'dart:async'; // สำหรับทำระบบ Banner เลื่อนอัตโนมัติ
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/login_page.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  // --- ตัวแปรสำหรับ Banner ---
  int _currentBannerIndex = 0;
  late PageController _pageController;
  Timer? _timer;

  // --- ตัวแปรสำหรับ Floating Bottom Bar ---
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    // 🧠 ตั้งเวลาให้ Banner เลื่อนอัตโนมัติทุกๆ 3 วินาที
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentBannerIndex < 2) {
        _currentBannerIndex++;
      } else {
        _currentBannerIndex = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // ปิด Timer เมื่อออกจากหน้า
    _pageController.dispose();
    super.dispose();
  }

  // 🧠 ฟังก์ชันออกจากระบบ (เอาไปผูกกับปุ่ม Settings)
  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          // ==========================================
          // 1. เลเยอร์เนื้อหาหลัก (อยู่ด้านล่าง)
          // ==========================================
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                100,
              ), // เผื่อที่ด้านล่างให้ Floating Bar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 📍 แถบด้านบน: Profile (L), Address (C), Notification (R) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ซ้าย: Profile
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.amber,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      // กลาง: Address
                      Column(
                        children: [
                          Text(
                            'Current Location',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.blueAccent,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Chiang Rai, TH',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // ขวา: Notification
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.notifications_none,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // --- 👋 โลโก้ & คำทักทาย ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hello, User 👋',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'How can we help you today?',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      // โลโก้ขนาดเล็กดึงมาจากดีไซน์หน้า Login
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                          children: [
                            TextSpan(
                              text: 'Kiang',
                              style: TextStyle(color: Colors.amber),
                            ),
                            TextSpan(
                              text: 'Thai',
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // --- 🏷️ Banner โฆษณา (เลื่อนอัตโนมัติ / เลื่อนมือได้) ---
                  SizedBox(
                    height: 150,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentBannerIndex = index);
                      },
                      children: [
                        _buildBannerCard(
                          'Summer Sale!',
                          '20% Off AC Cleaning',
                          Colors.blueAccent,
                          Icons.ac_unit,
                        ),
                        _buildBannerCard(
                          'Stay Safe',
                          'Free Electrical Checkup',
                          Colors.amber,
                          Icons.security,
                        ),
                        _buildBannerCard(
                          'Go Green',
                          'Special Solar Cell Packages',
                          Colors.teal,
                          Icons.solar_power,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // จุดไข่ปลาบอกตำแหน่ง Banner
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => _buildDot(index: index),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- 🛠️ หมวดหมู่บริการ (6 บริการ) ---
                  const Text(
                    'Our Services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3, // 3 คอลัมน์
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.85, // ปรับสัดส่วนให้กล่องสวยพอดี
                    children: [
                      _buildServiceCard(
                        'AC Service',
                        Icons.ac_unit,
                        Colors.blueAccent,
                      ),
                      _buildServiceCard(
                        'Electrical',
                        Icons.electrical_services,
                        Colors.orange,
                      ),
                      _buildServiceCard(
                        'Solar Cell',
                        Icons.solar_power,
                        Colors.teal,
                      ),
                      _buildServiceCard('CCTV', Icons.videocam, Colors.indigo),
                      _buildServiceCard(
                        'Water Pump',
                        Icons.water_drop,
                        Colors.cyan,
                      ),
                      _buildServiceCard('Electronics', Icons.tv, Colors.purple),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ==========================================
          // 2. เลเยอร์ Floating Bottom Bar (ลอยอยู่ด้านบนสุด)
          // ==========================================
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
                  _buildNavItem(Icons.settings, 'Settings', 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Widgets ย่อยเสริมความงาม
  // ==========================================

  // การ์ด Banner
  Widget _buildBannerCard(
    String title,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: const NetworkImage(
            'https://www.transparenttextures.com/patterns/cubes.png',
          ), // ใส่ลาย Texture บางๆ
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.1),
            BlendMode.dstIn,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, size: 60, color: Colors.white.withOpacity(0.8)),
        ],
      ),
    );
  }

  // จุดไข่ปลาใต้ Banner
  Widget _buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      width: _currentBannerIndex == index ? 20 : 8,
      decoration: BoxDecoration(
        color: _currentBannerIndex == index
            ? Colors.amber
            : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  // การ์ดบริการ 6 เมนู
  Widget _buildServiceCard(String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Selected: $title')));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ปุ่มใน Floating Bottom Bar
  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _currentNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentNavIndex = index);
        // 🧠 พิเศษ: ถ้ากด Settings (index == 3) ให้โชว์ Dialog ออกจากระบบ
        if (index == 3) {
          _showSettingsDialog();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.blueAccent.withOpacity(0.1)
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
            if (isActive) ...[
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

  // 🚪 ป๊อปอัปเมนู Settings (สำหรับกดออกจากระบบ)
  void _showSettingsDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  'Log out',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // ปิดป๊อปอัปก่อน
                  _signOut(); // เรียกใช้ฟังก์ชันออกจากระบบ
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
