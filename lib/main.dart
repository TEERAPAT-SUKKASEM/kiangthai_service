import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  // บรรทัดนี้สำคัญมากสำหรับการเริ่มระบบ
  WidgetsFlutterBinding.ensureInitialized();

  // เชื่อมต่อกับ Supabase
  await Supabase.initialize(
    url: 'ใส่ URL จาก Supabase ของคุณที่นี่',
    anonKey: 'ใส่ Anon Key จาก Supabase ของคุณที่นี่',
  );

  runApp(const KiangThaiServiceApp());
}

class KiangThaiServiceApp extends StatelessWidget {
  const KiangThaiServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KiangThai Service',
      debugShowCheckedModeBanner: false, // ปิดแถบ Debug
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
        textTheme: GoogleFonts.kanitTextTheme(), // ใช้ฟอนต์ไทยสวยๆ
      ),
      home: const Scaffold(
        body: Center(child: Text('KiangThai Service: พร้อมลุย!')),
      ),
    );
  }
}
