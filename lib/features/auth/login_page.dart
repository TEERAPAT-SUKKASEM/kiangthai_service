import 'package:flutter/material.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // เพิ่มบรรทัดนี้เพื่อเรียกใช้ Supabase

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

  // ---------------------------------------------------------
  // 🧠 [เพิ่มใหม่] ตัวรับข้อมูล (Controllers) ที่ดึงข้อความจากช่องพิมพ์
  // ---------------------------------------------------------
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ฟังก์ชันทำลายตัวรับข้อมูลเมื่อปิดหน้าจอ (กันแอปหน่วง)
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 🧠 [เพิ่มใหม่] ฟังก์ชันสำหรับสมัครสมาชิก
  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // เช็คว่ากรอกข้อมูลครบไหม
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกอีเมลและรหัสผ่าน')),
      );
      return;
    }
    // เช็คว่ารหัสผ่าน 2 ช่องตรงกันไหม
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('รหัสผ่านไม่ตรงกัน กรุณาตรวจสอบอีกครั้ง')),
      );
      return;
    }

    try {
      // 🚀 ส่งข้อมูลไปสร้างบัญชีใหม่ที่ Supabase
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      // ถ้าสำเร็จ แจ้งเตือนและสลับกลับไปหน้า Log in
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('สมัครสมาชิกสำเร็จ! กรุณาเข้าสู่ระบบ')),
        );
        setState(() {
          isLogin = true;
          _passwordController.clear(); // ล้างรหัสผ่านเก่าทิ้ง
          _confirmPasswordController.clear();
        });
      }
    } on AuthException catch (e) {
      // ถ้ามี Error จาก Supabase (เช่น รหัสสั้นไป, อีเมลซ้ำ)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.message}')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('เกิดข้อผิดพลาดบางอย่าง')));
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
              crossAxisAlignment: CrossAxisAlignment.center,
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

  // ==========================================
  // ส่วนประกอบย่อย (Widgets)
  // ==========================================

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

  // --- 1. ฟอร์ม Log in (เดี๋ยวเรามาฝังสมองให้ทีหลัง) ---
  Widget _buildLoginForm() {
    return Column(
      children: [
        TextField(
          controller: _emailController, // ใส่ตัวรับข้อมูล
          decoration: _modernInputDecoration(
            'Email Address',
            Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _passwordController, // ใส่ตัวรับข้อมูล
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
          onPressed: () {},
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

  // --- 2. ฟอร์ม Sign in (เชื่อมกับ Supabase แล้ว!) ---
  Widget _buildSignUpForm() {
    return Column(
      children: [
        TextField(
          controller: _emailController, // ใส่ตัวรับข้อมูลอีเมล
          decoration: _modernInputDecoration(
            'Email Address',
            Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _passwordController, // ใส่ตัวรับข้อมูลรหัสผ่าน
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
          controller:
              _confirmPasswordController, // ใส่ตัวรับข้อมูลยืนยันรหัสผ่าน
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
          onPressed: _handleSignUp, // 🚀 ผูกปุ่มเข้ากับฟังก์ชันสมัครสมาชิก
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

  // --- 3. ฟอร์มลืมรหัสผ่าน ---
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
