import 'package:flutter/material.dart';

class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  // 🧠 0 = โชว์ Upcoming, 1 = โชว์ History
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

          // --- 💊 แถบสลับหน้า (Toggle) ---
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

          // --- 📋 ส่วนแสดงรายการ (Upcoming โชว์ Tracker / History โชว์ราคา) ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              children: _selectedTab == 0
                  ? _buildUpcomingList()
                  : _buildHistoryList(),
            ),
          ),
        ],
      ),
    );
  }

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
  // ⏳ รายการ: Upcoming (โชว์ Tracking Bar)
  // ==========================================
  List<Widget> _buildUpcomingList() {
    return [
      _buildBookingCard(
        title: 'AC Cleaning Service',
        date: 'Today, 10:00 AM',
        status: 'Arriving',
        statusColor: Colors.blueAccent,
        icon: Icons.ac_unit,
        price: '฿600',
        technician: 'Tech. Somchai',
        currentStep:
            2, // 👈 ลำดับขั้น (0=Request, 1=Accept, 2=Arrive, 3=Work, 4=Finish, 5=Pay)
      ),
      const SizedBox(height: 15),
      _buildBookingCard(
        title: 'Electrical Repair',
        date: 'Tomorrow, 14:00 PM',
        status: 'Requested',
        statusColor: Colors.amber.shade700,
        icon: Icons.electrical_services,
        price: 'Est. ฿1,200',
        technician: 'Pending',
        currentStep: 0, // 👈 แค่ส่งคำขอ (อยู่สเต็ปแรก)
      ),
    ];
  }

  // ==========================================
  // ✅ รายการ: History (โชว์ราคาและปุ่ม Rebook เหมือนเดิม)
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
    int? currentStep,
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

          // --- แถวล่าง 🧠: แยกเงื่อนไขการแสดงผล ---
          if (!isHistory && currentStep != null)
            _buildTrackerBar(
              currentStep,
            ) // ถ้าเป็น Upcoming ให้โชว์ Tracking Bar
          else
            // ถ้าเป็น History ให้โชว์ชื่อช่าง, ราคา, ปุ่ม Rebook เหมือนเดิม
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade300),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Rebook',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ==========================================
  // 📍 Widget: วาดเส้นและจุด Tracking 6 ขั้นตอน
  // ==========================================
  Widget _buildTrackerBar(int currentStep) {
    // 6 ขั้นตอนย่อเป็นภาษาอังกฤษเพื่อให้พอดีหน้าจอ
    final steps = ['Request', 'Accept', 'Arrive', 'Work', 'Finish', 'Pay'];

    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. เส้นพื้นหลังสีเทา (ทอดยาวตลอดแนว)
        Positioned(
          top: 10,
          left: 15,
          right: 15,
          child: Container(height: 2, color: Colors.grey.shade200),
        ),
        // 2. เส้นสีแสดงความคืบหน้า (วิ่งตาม % ของสเต็ป)
        Positioned(
          top: 10,
          left: 15,
          right: 15,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: currentStep / (steps.length - 1),
            child: Container(height: 2, color: Colors.amber),
          ),
        ),
        // 3. จุดวงกลมพร้อมเครื่องหมายถูก และ ข้อความด้านล่าง
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(steps.length, (index) {
            bool isCompleted =
                index <= currentStep; // ตรวจสอบว่าถึงขั้นตอนนี้หรือยัง
            return SizedBox(
              width: 42, // บีบความกว้างข้อความให้พอดี 6 อัน
              child: Column(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.amber : Colors.grey.shade200,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ), // ขอบขาวให้ป๊อปอัพขึ้นมา
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    steps[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9, // อักษรเล็กหน่อยเพื่อไม่ให้ชนกัน
                      fontWeight: isCompleted
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isCompleted
                          ? Colors.black87
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
