import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// นำเข้าไฟล์หน้าจอต่างๆ (Path ตรงตาม File Tree ของคุณเป๊ะๆ)
import 'login_page.dart';
import '../customer/customer_home.dart';
import '../technician/technician_home.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    // ⏳ สั่งให้ Flutter รอวาดหน้าจอ Loading เสร็จก่อน แล้วค่อยไปรันคำสั่งสับราง
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndRole();
    });
  }

  Future<void> _checkAuthAndRole() async {
    // 1. เช็คว่ามีคนล็อกอินค้างไว้ไหม
    final user = _supabase.auth.currentUser;

    if (user == null) {
      // ❌ ไม่มีคนล็อกอิน -> เตะไปหน้า Login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
      return;
    }

    try {
      // 2. 🔍 มีคนล็อกอิน! วิ่งไปดึง 'role' จากตาราง profiles
      final response = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      final String role = response['role'] ?? 'customer';

      // 3. 🛤️ สับรางตามยศ!
      if (mounted) {
        if (role == 'technician') {
          // ถ้าเป็น technician -> ไปหน้าช่าง
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TechnicianHomePage()),
          );
        } else {
          // ถ้าเป็น customer หรืออื่นๆ -> ไปหน้าลูกค้า
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CustomerHomePage()),
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching role: $e');
      // ถ้าเน็ตหลุดหรือมี Error ให้เข้าหน้าลูกค้าไว้ก่อนปลอดภัยสุด
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CustomerHomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // โลโก้ KiangThai เอามาโชว์ตอนโหลดคัดกรอง
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Kiang',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.amber.shade600,
                      ),
                    ),
                    const Text(
                      'Thai',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'S E R V I C E',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 4.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.blueAccent),
            const SizedBox(height: 15),
            const Text(
              'Verifying account...',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
