import 'package:flutter/material.dart';

class TechnicianHomePage extends StatelessWidget {
  const TechnicianHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KiangThai Service (สำหรับช่าง)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.handyman, size: 100, color: Colors.blueAccent),
            const SizedBox(height: 20),
            const Text(
              'เข้าสู่ระบบสำเร็จ!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('ยินดีต้อนรับสู่หน้ารับงานของช่างไฟฟ้า'),
            const SizedBox(height: 40),
            ElevatedButton(onPressed: () {}, child: const Text('ออกจากระบบ')),
          ],
        ),
      ),
    );
  }
}
