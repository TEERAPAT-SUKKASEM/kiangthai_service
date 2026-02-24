import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../customer/customer_home.dart';
import '../technician/technician_home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true;
  bool isForgotPassword = false;
  bool _obscurePass = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // --- 🧠 ลอจิกเข้าสู่ระบบแบบถาม Database ---
  Future<void> _handleLogin() async {
    try {
      // 1. ล็อกอินเข้าระบบก่อน
      final AuthResponse res = await Supabase.instance.client.auth
          .signInWithPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      if (res.user != null) {
        // 2. ไปดึงข้อมูลจากตาราง profiles ว่าคนนี้มี Role อะไร
        final data = await Supabase.instance.client
            .from('profiles')
            .select('role')
            .eq('id', res.user!.id)
            .single();

        String role = data['role'] ?? 'customer';

        if (mounted) {
          if (role == 'technician') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const TechnicianHomePage(),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CustomerHomePage()),
            );
          }
        }
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  // --- ระบบสมัครสมาชิก (ค่าเริ่มต้นจะเป็น customer เสมอจาก SQL Trigger) ---
  Future<void> _handleSignUp() async {
    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('สมัครสำเร็จ! กรุณาล็อกอิน')),
        );
        setState(() => isLogin = true);
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                // Logo
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 45, fontWeight: FontWeight.w900),
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
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // Form
                TextField(
                  controller: _emailController,
                  decoration: _inputDecoration('Email', Icons.email_outlined),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePass,
                  decoration: _inputDecoration(
                    'Password',
                    Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePass ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: isLogin ? _handleLogin : _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: isLogin ? Colors.blueAccent : Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    isLogin ? 'Log in' : 'Sign in',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin
                        ? "Don't have an account? Sign in"
                        : "Already have an account? Log in",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }
}
