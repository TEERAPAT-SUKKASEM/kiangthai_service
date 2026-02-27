import 'package:flutter/material.dart';

class TechJobBoardTab extends StatefulWidget {
  const TechJobBoardTab({super.key});

  @override
  State<TechJobBoardTab> createState() => _TechJobBoardTabState();
}

class _TechJobBoardTabState extends State<TechJobBoardTab> {
  // 🧠 0 = คำขอ (Requests), 1 = ที่ต้องทำ (To Do)
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================
          // 1. Top Bar: โปรไฟล์ (ซ้าย) | โลโก้ (กลาง) | แจ้งเตือน (ขวา)
          // ==========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ซ้าย: รูปโปรไฟล์
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.amber.shade100,
                  backgroundImage: const NetworkImage(
                    'https://i.pravatar.cc/150?img=11',
                  ), // รูปช่างจำลอง
                ),

                // กลาง: โลโก้ / ชื่อแอป
                Row(
                  children: [
                    const Icon(
                      Icons.build_circle,
                      color: Colors.blueGrey,
                      size: 28,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'KIANGTHAI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.blueGrey.shade900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),

                // ขวา: กระดิ่งแจ้งเตือน
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.black87,
                        size: 28,
                      ),
                      onPressed: () {},
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          '2',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ==========================================
          // 2. Greeting: ทักทาย และขอให้ปลอดภัย
          // ==========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hello, Technician!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Wishing you a safe and successful day at work! 🛠️',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ==========================================
          // 3. Toggle Bar: สลับ Requests / To Do
          // ==========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(5),
              child: Row(
                children: [
                  Expanded(child: _buildTabButton('Requests (คำขอ)', 0)),
                  Expanded(child: _buildTabButton('To Do (ที่ต้องทำ)', 1)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ==========================================
          // 4. เนื้อหาของรายการ (เดี๋ยวเราค่อยดึง DB มาใส่)
          // ==========================================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                100,
              ), // เว้นที่ล่างเผื่อ Bottom Bar
              children: [
                if (_selectedTab == 0) ...[
                  // --- หน้าตาจำลองของแท็บ "คำขอ" ---
                  _buildMockCard(
                    'AC Cleaning',
                    'Bangkok, 10km away',
                    'Pending',
                    Colors.amber.shade700,
                  ),
                  _buildMockCard(
                    'CCTV Repair',
                    'Nonthaburi, 5km away',
                    'Pending',
                    Colors.amber.shade700,
                  ),
                ] else ...[
                  // --- หน้าตาจำลองของแท็บ "ที่ต้องทำ" ---
                  _buildMockCard(
                    'Water Pump Install',
                    'Today, 14:00 PM',
                    'Confirmed',
                    Colors.blueAccent,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ตัวช่วยสร้างปุ่ม Toggle
  Widget _buildTabButton(String title, int index) {
    bool isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
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
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              color: isActive ? Colors.black87 : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }

  // ตัวช่วยสร้างการ์ดจำลอง (เดี๋ยวรอบหน้าเรามาต่อ Database กัน)
  Widget _buildMockCard(
    String title,
    String subtitle,
    String status,
    Color statusColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
