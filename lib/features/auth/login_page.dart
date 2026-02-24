import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ตัวแปรควบคุมว่าตอนนี้เรากำลังโชว์หน้าไหนอยู่
  bool isLogin = true;
  bool isForgotPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // ป้องกันคีย์บอร์ดเด้งมาบังหน้าจอ
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- 1. โลโก้ KiangThai Service ---
              Column(
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'Kiang',
                          style: TextStyle(color: Colors.amber),
                        ),
                        TextSpan(
                          text: 'Thai',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'Service',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // --- 2. ข้อความต้อนรับ ---
              const Text(
                "Welcome to KiangThai Service",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // --- 3. แถบเลือก Log in / Sign in (ซ่อนไว้ถ้าอยู่หน้าลืมรหัส) ---
              if (!isForgotPassword)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => setState(() => isLogin = true),
                      child: Text(
                        'Log in',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: isLogin
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isLogin ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ),
                    const Text(
                      '|',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () => setState(() => isLogin = false),
                      child: Text(
                        'Sign in', // ตรงนี้คือส่วนสมัครสมาชิกตามที่คุณออกแบบ
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: !isLogin
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: !isLogin ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),

              // --- 4. แสดงฟอร์มตามสถานะที่เลือก ---
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
    );
  }

  // ==========================================
  // ส่วนประกอบย่อย (Widgets) แยกไว้ให้อ่านง่าย
  // ==========================================

  // ฟอร์มเข้าสู่ระบบ (Log in)
  Widget _buildLoginForm() {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
        ),

        // ปุ่มลืมรหัสผ่าน
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => setState(() => isForgotPassword = true),
            child: const Text('Forgot Password?'),
          ),
        ),

        // ปุ่ม Log in
        ElevatedButton(
          onPressed: () {}, // เดี๋ยวเรามาใส่โค้ดเชื่อมฐานข้อมูลทีหลัง
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.blue,
          ),
          child: const Text(
            'Log in',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        const SizedBox(height: 15),

        // ปุ่มไปหน้า Sign in (สมัครใหม่)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account?"),
            TextButton(
              onPressed: () => setState(() => isLogin = false),
              child: const Text('Sign in'),
            ),
          ],
        ),

        _buildSocialDivider("Log in with"),
        _buildSocialButtons(),
      ],
    );
  }

  // ฟอร์มสมัครสมาชิก (Sign in ตามที่คุณเรียก)
  Widget _buildSignUpForm() {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Confirm Password',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 25),

        // ปุ่ม Sign in
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.amber,
          ),
          child: const Text(
            'Sign in',
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
        ),
        const SizedBox(height: 20),

        _buildSocialDivider("Sign in with"),
        _buildSocialButtons(),
      ],
    );
  }

  // ฟอร์มลืมรหัสผ่าน (Forgot Password)
  Widget _buildForgotPasswordForm() {
    return Column(
      children: [
        const Text(
          "Reset Your Password",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'New Password',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Confirm New Password',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 25),

        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.blue,
          ),
          child: const Text(
            'Reset Password',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),

        // ปุ่มกลับไปหน้า Login
        TextButton(
          onPressed: () => setState(() => isForgotPassword = false),
          child: const Text('Back to Log in'),
        ),
      ],
    );
  }

  // เส้นคั่นพร้อมข้อความตรงกลาง
  Widget _buildSocialDivider(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(text, style: const TextStyle(color: Colors.grey)),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  // ปุ่ม Google และ Apple
  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.red),
          label: const Text('Google', style: TextStyle(color: Colors.black)),
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.apple, size: 30, color: Colors.black),
          label: const Text('Apple', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
