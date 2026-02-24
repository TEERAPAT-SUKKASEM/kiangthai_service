import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  // บรรทัดนี้สำคัญมากสำหรับการเริ่มระบบ
  WidgetsFlutterBinding.ensureInitialized();

  // เชื่อมต่อกับ Supabase
  await Supabase.initialize(
    url: 'https://oiuuosygqjsxzurldyrl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9pdXVvc3lncWpzeHp1cmxkeXJsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE5NDA2MzYsImV4cCI6MjA4NzUxNjYzNn0.5_4OC3FqHInlJSecH0qwanf8t0bKSvOdWHmX00hpNMI',
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
