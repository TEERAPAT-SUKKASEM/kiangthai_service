import 'package:flutter/material.dart';

class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  // 🧠 0 = โชว์ Upcoming (กำลังจะมาถึง), 1 = โชว์ History (เสร็จสิ้น)
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 📌 ส่วนหัวของหน้า ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Bookings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Track your service status here',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // --- 💊 แถบสลับหน้า (Toggle) สไตล์แคปซูล ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(5),
              child: Row(
                children: [
                  Expanded(child: _buildTabButton('Upcoming', 0)),
                  Expanded(child: _buildTabButton('History', 1)),
                ],
              ),
            ),
          ),

          // --- 📋 ส่วนแสดงรายการ (เปลี่ยนตาม Tab ที่เลือก) ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                100,
              ), // เผื่อที่ด้านล่างให้ Floating Bar
              children: _selectedTab == 0
                  ? _buildUpcomingList()
                  : _buildHistoryList(),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 🔘 Widget ปุ่มแคปซูล
  // ==========================================
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
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              color: isActive ? Colors.black87 : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // ⏳ รายการ: Upcoming (กำลังดำเนินการ)
  // ==========================================
  List<Widget> _buildUpcomingList() {
    return [
      _buildBookingCard(
        title: 'AC Cleaning Service',
        date: 'Tomorrow, 10:00 AM',
        status: 'Confirmed',
        statusColor: Colors.blueAccent,
        icon: Icons.ac_unit,
        price: '฿600',
        technician: 'Tech. Somchai (Assigned)',
      ),
      const SizedBox(height: 15),
      _buildBookingCard(
        title: 'Electrical Repair',
        date: 'Oct 25, 14:00 PM',
        status: 'Pending',
        statusColor: Colors.amber.shade700,
        icon: Icons.electrical_services,
        price: 'Est. ฿1,200',
        technician: 'Looking for technician...',
      ),
    ];
  }

  // ==========================================
  // ✅ รายการ: History (ประวัติที่เสร็จสิ้น/ยกเลิก)
  // ==========================================
  List<Widget> _buildHistoryList() {
    return [
      _buildBookingCard(
        title: 'Water Pump Fixing',
        date: 'Oct 10, 09:30 AM',
        status: 'Completed',
        statusColor: Colors.green,
        icon: Icons.water_drop,
        price: '฿850',
        technician: 'Tech. Prasert',
        isHistory: true,
      ),
      const SizedBox(height: 15),
      _buildBookingCard(
        title: 'CCTV Installation',
        date: 'Sep 28, 13:00 PM',
        status: 'Cancelled',
        statusColor: Colors.redAccent,
        icon: Icons.videocam,
        price: '฿0',
        technician: 'Cancelled by user',
        isHistory: true,
      ),
    ];
  }

  // ==========================================
  // 🃏 Widget: การ์ดรายการจอง
  // ==========================================
  Widget _buildBookingCard({
    required String title,
    required String date,
    required String status,
    required Color statusColor,
    required IconData icon,
    required String price,
    required String technician,
    bool isHistory = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // --- แถวบน: ไอคอน + ชื่อ + สถานะ ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: Colors.black87, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // ป้ายสถานะ (Badge)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
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

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(height: 1, thickness: 1),
          ),

          // --- แถวล่าง: ช่าง + ราคา + ปุ่ม ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ข้อมูลช่าง & ราคา
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        technician,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // ปุ่มกด (ถ้า History เป็น Rebook, ถ้า Upcoming เป็น Details)
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: isHistory ? Colors.white : Colors.amber,
                  foregroundColor: isHistory ? Colors.black87 : Colors.black87,
                  side: isHistory
                      ? BorderSide(color: Colors.grey.shade300)
                      : BorderSide.none,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  isHistory ? 'Rebook' : 'Details',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
