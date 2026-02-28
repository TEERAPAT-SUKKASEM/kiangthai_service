import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/auth_gate.dart'; // 👈 นำเข้า AuthGate เพื่อให้เตะกลับหน้าล็อกอินได้ชัวร์ๆ

class SettingTab extends StatelessWidget {
  const SettingTab({super.key});

  // 🚪 ฟังก์ชันออกจากระบบ (Sign Out) แบบกวาดหน้าจบทิ้ง 100%
  Future<void> _signOut(BuildContext context) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out of your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // 1. บอก Supabase ให้เตะ User นี้ออกจากระบบ
      await Supabase.instance.client.auth.signOut();

      // 2. ถ้าหน้าจอยังเปิดอยู่ บังคับวาร์ปกลับ AuthGate และกวาดประวัติทิ้งให้เกลี้ยง!
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthGate()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔍 ดึงข้อมูลผู้ใช้ "ของจริง" จากระบบ Supabase
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'Unknown Email';

    // ⚙️ สร้างชื่อจาก Email จริง (เช่น test@gmail.com -> จะได้ชื่อ "Test")
    String displayName = 'User';
    String initial = 'U';

    if (email != 'Unknown Email' && email.contains('@')) {
      displayName = email.split('@')[0]; // ตัดเอาข้อความหน้า @
      if (displayName.isNotEmpty) {
        // ทำตัวอักษรตัวแรกให้เป็นตัวใหญ่ (เช่น test -> Test)
        displayName = displayName[0].toUpperCase() + displayName.substring(1);
        initial = displayName[0].toUpperCase(); // เอาตัวแรกมาทำเป็นรูปโปรไฟล์
      }
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1️⃣ Header
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            // 2️⃣ Profile Card (ดึงข้อมูลจริงมาโชว์ 100%)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  // 🖼️ รูปโปรไฟล์ของจริง (ใช้ตัวอักษรแรกของอีเมล แทนรูปม็อคอัพ)
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.blueAccent.shade100,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // โชว์ชื่อที่ดึงจากอีเมลจริง
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // โชว์อีเมลจริง
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3️⃣ Options Menu (Account)
            _buildSectionTitle('Account'),
            _buildListTile(
              Icons.location_on_outlined,
              'Saved Addresses',
              'Manage your service locations',
            ),
            _buildListTile(
              Icons.payment_outlined,
              'Payment Methods',
              'Manage your cards and PromptPay',
            ),
            _buildListTile(
              Icons.notifications_outlined,
              'Notifications',
              'Alerts and updates',
            ),

            const SizedBox(height: 10),

            // 4️⃣ Options Menu (Support)
            _buildSectionTitle('Support & About'),
            _buildListTile(
              Icons.help_outline,
              'Help Center',
              'FAQ and customer support',
            ),
            _buildListTile(
              Icons.info_outline,
              'About KiangThai',
              'App version 1.0.0',
            ),

            const SizedBox(height: 30),

            // 5️⃣ Sign Out Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _signOut(context),
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.redAccent,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // 🛠️ Widget Helper
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // 🛠️ Widget Helper
  Widget _buildListTile(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: () {},
    );
  }
}
