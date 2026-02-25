import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/login_page.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  // 🧠 ฟังก์ชันออกจากระบบ (ย้ายมาไว้ตรงนี้)
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
      backgroundColor:
          Colors.grey.shade50, // พื้นหลังสีเทาอ่อนให้การ์ดดูโดดเด่น
      appBar: AppBar(
        title: const Text(
          'KiangThai Service',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.amber,
        elevation: 0,
        actions: [
          // 🚪 ปุ่มออกจากระบบมุมขวาบน
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: _signOut,
            tooltip: 'ออกจากระบบ',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 👋 ส่วนหัวต้อนรับ ---
              const Text(
                'สวัสดีครับ 👋',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'วันนี้ให้เราช่วยดูแลเรื่องอะไรดี?',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 30),

              // --- 🛠️ หมวดหมู่บริการ (Grid) ---
              const Text(
                'บริการของเรา',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              GridView.count(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // ปิดการเลื่อนซ้อนกัน
                crossAxisCount: 2, // 2 คอลัมน์
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1, // สัดส่วนความกว้าง:สูง ของกล่อง
                children: [
                  _buildServiceCard(
                    'ซ่อม/ล้างแอร์',
                    Icons.ac_unit,
                    Colors.blueAccent,
                  ),
                  _buildServiceCard(
                    'ติดตั้ง/เดินสายไฟ',
                    Icons.electrical_services,
                    Colors.orange,
                  ),
                  _buildServiceCard(
                    'เปลี่ยนหลอดไฟ',
                    Icons.lightbulb_outline,
                    Colors.amber,
                  ),
                  _buildServiceCard(
                    'ตรวจเช็คไฟรั่ว',
                    Icons.security,
                    Colors.redAccent,
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- 📋 สถานะงานซ่อมล่าสุด ---
              const Text(
                'งานซ่อมของคุณ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.assignment_ind_outlined,
                      size: 60,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'ยังไม่มีรายการแจ้งซ่อม',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // เดี๋ยวเรามาทำปุ่มนี้ให้เด้งไปหน้า "แบบฟอร์มจองช่าง" ทีหลังครับ
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ฟอร์มจองช่างกำลังตามมาเร็วๆ นี้!'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'จองช่างเลย',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 🧩 สร้าง Widget สำหรับปุ่มบริการแต่ละอัน (จะได้โค้ดไม่รก) ---
  Widget _buildServiceCard(String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        // ทดสอบกดปุ่ม
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('คุณเลือก: $title')));
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
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
