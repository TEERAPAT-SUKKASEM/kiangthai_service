import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KiangThai Service'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'เข้าสู่ระบบในฐานะ',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // TODO: ไปหน้าลูกค้า
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
              child: const Text(
                'ลูกค้า (หาช่าง)',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                // TODO: ไปหน้าช่าง
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                backgroundColor: Colors.orange.shade100, // แยกสีให้ช่าง
              ),
              child: const Text(
                'ช่างไฟฟ้า (รับงาน)',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
