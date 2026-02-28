import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/auth_gate.dart';

class SettingTab extends StatelessWidget {
  const SettingTab({super.key});

  // 🚪 ฟังก์ชันออกจากระบบ (Sign Out) แบบบังคับเด้งกลับ
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
      // 1. สั่ง Supabase ลบเซสชัน (Session) ออกจากเครื่อง
      await Supabase.instance.client.auth.signOut();

      // 2. บังคับเตะผู้ใช้กลับไปหน้า AuthGate และ "ล้างประวัติหน้าจอเก่าทิ้งทั้งหมด"
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthGate()),
          (Route<dynamic> route) =>
              false, // false คือกวาดหน้าต่างเก่าทิ้งเกลี้ยง!
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูลอีเมลผู้ใช้ที่ล็อกอินอยู่มาโชว์
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'user@example.com';

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

            // 2️⃣ Profile Card
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
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.amber.shade100,
                    backgroundImage: const NetworkImage(
                      'https://i.pravatar.cc/150?img=32',
                    ), // รูปลูกค้าชั่วคราว
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customer User',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
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
                  IconButton(
                    icon: const Icon(
                      Icons.edit_square,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {},
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

            const SizedBox(height: 50), // เว้นระยะด้านล่างให้ไม่ชิดขอบเกินไป
          ],
        ),
      ),
    );
  }

  // 🛠️ Widget Helper สำหรับหัวข้อ
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

  // 🛠️ Widget Helper สำหรับปุ่มเมนูแต่ละอัน
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
      onTap: () {
        // อนาคตค่อยลิงก์ไปหน้าย่อยๆ
      },
    );
  }
}
