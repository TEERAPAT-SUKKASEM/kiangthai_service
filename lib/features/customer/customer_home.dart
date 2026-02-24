import 'package:flutter/material.dart';

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KiangThai Service',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            const Text(
              'เข้าสู่ระบบสำเร็จ!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('ยินดีต้อนรับสู่หน้าหลักของลูกค้า'),
            const SizedBox(height: 40),
            // ปุ่มออกจากระบบ (ทำเผื่อไว้เลย)
            ElevatedButton(
              onPressed: () {
                // เดี๋ยวเรามาเขียนโค้ดออกจากระบบทีหลัง
              },
              child: const Text('ออกจากระบบ'),
            ),
          ],
        ),
      ),
    );
  }
}
