import 'package:flutter/material.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
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

  bool _obscureLoginPass = true;
  bool _obscureSignUpPass = true;
  bool _obscureSignUpConfirm = true;
  bool _obscureResetPass = true;
  bool _obscureResetConfirm = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // 🧠 [เพิ่มใหม่] ตัวรับข้อมูลสำหรับ "รหัสประจำตัวช่าง"
  final _secretCodeController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _secretCodeController.dispose();
    super.dispose();
  }

  // --- 🧠 อัปเกรดระบบเข้าสู่ระบบ (ลอจิกใหม่ของคุณ Teerapat!) ---
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final secretCode = _secretCodeController.text.trim(); // ดึงรหัสช่างมาเช็ค

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกอีเมลและรหัสผ่าน')),
      );
      return;
    }

    // 🔐 กำหนดรหัสลับของช่าง (ตั้งค่าไว้ที่นี่ เช่น KIANGTHAI-999)
    const String correctSecretCode = 'KIANGTHAI-999';

    // เช็คก่อนว่า ถ้ายุ่งพิมพ์รหัสช่างมา แล้วมัน "ไม่ตรง" กับที่ตั้งไว้ ให้ด่าแล้วหยุดเลย
    if (secretCode.isNotEmpty && secretCode != correctSecretCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('รหัสประจำตัวช่างไม่ถูกต้อง!')),
      );
      return;
    }

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        // แยกร่างตามรหัสลับ!
        if (secretCode == correctSecretCode) {
          // ถ้าใส่รหัสช่างถูกเป๊ะ -> ไปหน้าช่าง
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TechnicianHomePage()),
          );
        } else {
          // ถ้าไม่ได้ใส่รหัสช่างมาเลย (ปล่อยว่าง) -> ไปหน้าลูกค้า
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CustomerHomePage()),
          );
        }
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เข้าสู่ระบบไม่สำเร็จ: ${e.message}')),
      );
    }
  }

  // --- ระบบสมัครสมาชิก (กลับมาเป็นแบบธรรมดา ไม่ต้องเลือกสถานะแล้ว) ---
  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;
    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('รหัสผ่านไม่ตรงกัน')));
      return;
    }

    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('สมัครสมาชิกสำเร็จ! กรุณาเข้าสู่ระบบ')),
        );
        setState(() {
          isLogin = true;
          _passwordController.clear();
          _confirmPasswordController.clear();
          _secretCodeController.clear();
        });
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.message}')));
    }
  }

  // ---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0,
              vertical: 20.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                    ),
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
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4.0,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Welcome to KiangThai Service",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),

                if (!isForgotPassword)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTabButton(
                          'Log in',
                          isLogin,
                          () => setState(() => isLogin = true),
                        ),
                        _buildTabButton(
                          'Sign in',
                          !isLogin,
                          () => setState(() => isLogin = false),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 30),

                if (isForgotPassword)
                  _buildForgotPasswordForm()
                else if (isLogin)
                  _buildLoginForm()
                else
                  _buildSignUpForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ]
              : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.black87 : Colors.grey,
          ),
        ),
      ),
    );
  }

  InputDecoration _modernInputDecoration(
    String label,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600),
      prefixIcon: Icon(icon, color: Colors.grey.shade600),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: _modernInputDecoration(
            'Email Address',
            Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _passwordController,
          obscureText: _obscureLoginPass,
          decoration: _modernInputDecoration(
            'Password',
            Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureLoginPass ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () =>
                  setState(() => _obscureLoginPass = !_obscureLoginPass),
            ),
          ),
        ),
        const SizedBox(height: 15),

        // 🚀 ช่องใส่รหัสลับช่าง (โผล่มาเฉพาะหน้า Log in)
        TextField(
          controller: _secretCodeController,
          decoration: _modernInputDecoration(
            'รหัสประจำตัวช่าง (เว้นว่างได้ถ้าเป็นลูกค้า)',
            Icons.badge,
          ),
        ),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => setState(() => isForgotPassword = true),
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _handleLogin,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 55),
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text(
            'Log in',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 30),
        _buildSocialDivider("Or log in with"),
        _buildSocialButtons(),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: _modernInputDecoration(
            'Email Address',
            Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _passwordController,
          obscureText: _obscureSignUpPass,
          decoration: _modernInputDecoration(
            'Password',
            Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureSignUpPass ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () =>
                  setState(() => _obscureSignUpPass = !_obscureSignUpPass),
            ),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureSignUpConfirm,
          decoration: _modernInputDecoration(
            'Confirm Password',
            Icons.lock_reset,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureSignUpConfirm ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () => setState(
                () => _obscureSignUpConfirm = !_obscureSignUpConfirm,
              ),
            ),
          ),
        ),
        const SizedBox(height: 25),
        ElevatedButton(
          onPressed: _handleSignUp,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 55),
            backgroundColor: Colors.amber,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text(
            'Sign in',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 30),
        _buildSocialDivider("Or sign in with"),
        _buildSocialButtons(),
      ],
    );
  }

  Widget _buildForgotPasswordForm() {
    return Column(
      children: [
        const Icon(
          Icons.lock_person_outlined,
          size: 60,
          color: Colors.blueAccent,
        ),
        const SizedBox(height: 10),
        const Text(
          "Reset Password",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextField(
          decoration: _modernInputDecoration(
            'Email Address',
            Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          obscureText: _obscureResetPass,
          decoration: _modernInputDecoration(
            'New Password',
            Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureResetPass ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () =>
                  setState(() => _obscureResetPass = !_obscureResetPass),
            ),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          obscureText: _obscureResetConfirm,
          decoration: _modernInputDecoration(
            'Confirm New Password',
            Icons.lock_reset,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureResetConfirm ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () =>
                  setState(() => _obscureResetConfirm = !_obscureResetConfirm),
            ),
          ),
        ),
        const SizedBox(height: 25),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 55),
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text(
            'Reset Password',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 15),
        TextButton(
          onPressed: () => setState(() => isForgotPassword = false),
          child: const Text(
            'Back to Log in',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialDivider(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialIcon(Icons.g_mobiledata, Colors.redAccent),
        const SizedBox(width: 20),
        _socialIcon(Icons.apple, Colors.black87),
      ],
    );
  }

  Widget _socialIcon(IconData icon, Color color) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, size: 35, color: color),
    );
  }
}
