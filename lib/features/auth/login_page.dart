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
  // สถานะหน้าจอ
  bool isLogin = true;
  bool isForgotPassword = false;

  // สถานะดวงตาเปิดปิดรหัส
  bool _obscureLoginPass = true;
  bool _obscureSignUpPass = true;
  bool _obscureSignUpConfirm = true;
  bool _obscureResetPass = true;
  bool _obscureResetConfirm = true;

  // ตัวรับข้อมูลเดิม (ห้ามยุ่ง)
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // 🧠 [เพิ่มใหม่เฉพาะลืมรหัส] ตัวแปรและตัวรับข้อมูลสำหรับระบบลืมรหัสผ่าน
  bool _isOtpSent = false;
  final _resetEmailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    // เคลียร์ตัวรับข้อมูลใหม่
    _resetEmailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  // --- 🧠 ลอจิกเข้าสู่ระบบ (เหมือนเดิม 100%) ---
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกอีเมลและรหัสผ่าน')),
      );
      return;
    }

    try {
      final AuthResponse res = await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);
      if (res.user != null) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เข้าสู่ระบบไม่สำเร็จ: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการดึงข้อมูลผู้ใช้')),
      );
    }
  }

  // --- 🧠 ลอจิกสมัครสมาชิก (เหมือนเดิม 100%) ---
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
        });
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.message}')));
    }
  }

  // --- 🧠 [เพิ่มใหม่] ลอจิกส่ง OTP ลืมรหัสผ่าน ---
  Future<void> _sendResetCode() async {
    final email = _resetEmailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณากรอกอีเมลก่อนครับ')));
      return;
    }
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      setState(() => _isOtpSent = true); // สลับโชว์ช่องกรอก OTP
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'ระบบส่งรหัส OTP ไปยังอีเมลของคุณแล้ว (โปรดเช็คกล่องจดหมาย)',
            ),
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เกิดข้อผิดพลาดในการส่งอีเมล')),
        );
    }
  }

  // --- 🧠 [เพิ่มใหม่] ลอจิกยืนยัน OTP และเปลี่ยนรหัส ---
  Future<void> _updatePassword() async {
    final email = _resetEmailController.text.trim();
    final otp = _otpController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmNewPasswordController.text.trim();

    if (otp.isEmpty || newPass.isEmpty) return;
    if (newPass != confirmPass) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('รหัสผ่านใหม่ไม่ตรงกัน!')));
      return;
    }

    try {
      // 1. ยืนยัน OTP (เอา OTP ไปเทียบกับฐานข้อมูล)
      await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.recovery,
        email: email,
        token: otp,
      );

      // 2. ถ้า OTP ถูก ต้องสั่งเปลี่ยนรหัสผ่านทันที
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPass),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เปลี่ยนรหัสผ่านสำเร็จ! กรุณาล็อกอินด้วยรหัสใหม่'),
          ),
        );
        setState(() {
          isForgotPassword = false; // กลับไปหน้าล็อกอิน
          _isOtpSent = false; // ล้างสถานะ OTP
          _otpController.clear();
          _newPasswordController.clear();
          _confirmNewPasswordController.clear();
        });
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('รหัส OTP ไม่ถูกต้อง หรือหมดอายุแล้ว')),
        );
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
                // --- โลโก้ (เหมือนเดิม 100%) ---
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

                // --- แถบสลับหน้า Log in / Sign in (เหมือนเดิม 100%) ---
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

                // --- แสดงฟอร์ม ---
                if (isForgotPassword)
                  _buildForgotPasswordForm() // <--- แก้ไขสมองและ UI เฉพาะก้อนนี้
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
  // Widgets ย่อย
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

  // --- ฟอร์ม Log in (เหมือนเดิม 100%) ---
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

  // --- ฟอร์ม Sign in (เหมือนเดิม 100%) ---
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

  // --- 🎨 [แก้ไขเฉพาะส่วนนี้] ฟอร์มลืมรหัสผ่าน ---
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

        // จังหวะที่ 1: โชว์แค่ช่องอีเมล เพื่อรับรหัส
        if (!_isOtpSent) ...[
          TextField(
            controller: _resetEmailController,
            decoration: _modernInputDecoration(
              'Email Address',
              Icons.email_outlined,
            ),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: _sendResetCode,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 55),
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'Send Reset Code',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ]
        // จังหวะที่ 2: โชว์ช่องใส่ OTP และเปลี่ยนรหัสผ่าน (UI เหมือนเดิมเป๊ะ!)
        else ...[
          TextField(
            controller: _resetEmailController,
            enabled: false,
            decoration: _modernInputDecoration(
              'Email Address',
              Icons.email_outlined,
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _otpController,
            decoration: _modernInputDecoration(
              '6-Digit OTP Code',
              Icons.message_outlined,
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _newPasswordController,
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
            controller: _confirmNewPasswordController,
            obscureText: _obscureResetConfirm,
            decoration: _modernInputDecoration(
              'Confirm New Password',
              Icons.lock_reset,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureResetConfirm
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(
                  () => _obscureResetConfirm = !_obscureResetConfirm,
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: _updatePassword,
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
        ],

        const SizedBox(height: 15),
        TextButton(
          onPressed: () => setState(() {
            isForgotPassword = false;
            _isOtpSent = false;
          }),
          child: const Text(
            'Back to Log in',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // --- เส้นคั่นและปุ่ม Social (เหมือนเดิม 100%) ---
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
