import 'package:flutter/material.dart';
import 'dart:async';
import '../forms/ac_service_form.dart';
import '../forms/electrical_form.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int _currentBannerIndex = 0;
  late PageController _pageController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
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
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- แถบด้านบน ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.amber,
                  child: Icon(Icons.person, color: Colors.white),
                ),
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

            // --- โลโก้ & คำทักทาย ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 24,
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
                    const Text(
                      'S E R V I C E',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            // --- Banner ---
            SizedBox(
              height: 150,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) =>
                    setState(() => _currentBannerIndex = index),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) => _buildDot(index: index)),
            ),
            const SizedBox(height: 30),

            // --- บริการ 6 อย่าง ---
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
              crossAxisCount: 3,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.85,
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
                _buildServiceCard('Solar Cell', Icons.solar_power, Colors.teal),
                _buildServiceCard('CCTV', Icons.videocam, Colors.indigo),
                _buildServiceCard('Water Pump', Icons.water_drop, Colors.cyan),
                _buildServiceCard('Electronics', Icons.tv, Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
          ),
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

  Widget _buildServiceCard(String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        // 🧠 ใช้ Switch แยกทางตามชื่อของบริการ
        Widget destinationPage;

        switch (title) {
          case 'AC Service':
            destinationPage = const AcServiceForm();
            break;
          case 'Electrical':
            destinationPage = const ElectricalForm();
            break;
          default:
            // ถ้ากดปุ่มที่ยังไม่ได้สร้างฟอร์ม ให้แจ้งเตือนไปก่อน
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Form for $title is coming soon!')),
            );
            return;
        }

        // พาเปลี่ยนหน้าไปตามไฟล์ที่เลือก
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationPage),
        );
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
}
