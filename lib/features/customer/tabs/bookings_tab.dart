import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  int _selectedTab = 0; // 0 = Upcoming (กำลังดำเนินการ), 1 = History (ประวัติ)
  final _supabase = Supabase.instance.client;

  // 🗑️ ฟังก์ชันยกเลิกงาน
  Future<void> _cancelBooking(String id) async {
    // แสดง Dialog ยืนยันก่อนลบ
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยกเลิกการจอง?'),
        content: const Text('คุณแน่ใจหรือไม่ว่าต้องการยกเลิกงานนี้?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ไม่'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ยกเลิกงาน'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // อัปเดตสถานะเป็น cancelled แทนการลบทิ้ง เพื่อเก็บเป็นประวัติได้
        await _supabase
            .from('bookings')
            .update({'status': 'cancelled'})
            .eq('id', id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ยกเลิกงานเรียบร้อยแล้ว')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================
          // 1. Header (หัวข้อหน้า)
          // ==========================================
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
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // ==========================================
          // 2. Toggle Bar (สลับแท็บ Upcoming / History)
          // ==========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
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

          // ==========================================
          // 3. Content List (ดึงข้อมูลแบบ Real-time Stream!)
          // ==========================================
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              // 📡 ดักฟังตาราง bookings แบบสดๆ เรียงจากใหม่ไปเก่า
              stream: _supabase
                  .from('bookings')
                  .stream(primaryKey: ['id'])
                  .order('created_at'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                // กรองข้อมูลตามแท็บ (Upcoming โชว์งานที่ยังไม่เสร็จ/ไม่ยกเลิก)
                final bookings = snapshot.data!.where((job) {
                  final status = (job['status'] ?? 'pending')
                      .toString()
                      .toLowerCase();
                  bool isDone =
                      status == 'completed' ||
                      status == 'paid' ||
                      status == 'cancelled';
                  return _selectedTab == 0 ? !isDone : isDone;
                }).toList();

                if (bookings.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    return _buildBookingCard(bookings[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET HELPER FUNCTIONS
  // ==========================================

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          Text(
            _selectedTab == 0 ? 'No upcoming bookings' : 'No booking history',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
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

  // แปลงสถานะจาก Database เป็นตัวเลข Step (0-5)
  int _getStepIndex(String status) {
    switch (status) {
      case 'pending':
        return 0; // Request (รอช่างรับงาน)
      case 'confirmed':
        return 1; // Accept (ช่างรับงานแล้ว)
      case 'traveling':
        return 2; // Heading (กำลังเดินทาง)
      case 'arrived':
        return 3; // Arrive (ถึงหน้างานแล้ว) - 🌟 สถานะใหม่!
      case 'working':
        return 4; // Work (กำลังซ่อม)
      case 'completed':
        return 5; // Finish (ซ่อมเสร็จ/จบงาน)
      default:
        return 0;
    }
  }

  // สร้างแถบ Progress Bar โชว์สถานะ
  Widget _buildTracker(String status) {
    if (status == 'cancelled') {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            '❌ ยกเลิกบริการแล้ว',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    int currentStep = _getStepIndex(status);
    List<String> steps = [
      'Request',
      'Accept',
      'Arrive',
      'Work',
      'Finish',
      'Pay',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length, (index) {
          bool isCompleted = index <= currentStep;
          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    // เส้นซ้าย (ซ่อนถ้าเป็นอันแรก)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index == 0
                            ? Colors.transparent
                            : (isCompleted
                                  ? Colors.amber
                                  : Colors.grey.shade300),
                      ),
                    ),
                    // วงกลมสถานะ
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.amber
                            : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    // เส้นขวา (ซ่อนถ้าเป็นอันสุดท้าย)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index == steps.length - 1
                            ? Colors.transparent
                            : (index < currentStep
                                  ? Colors.amber
                                  : Colors.grey.shade300),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  steps[index],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isCompleted
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isCompleted ? Colors.black87 : Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  maxLines: 1,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // 🌟 การ์ดงาน 1 ใบ
  Widget _buildBookingCard(Map<String, dynamic> job) {
    String jobId = job['id'].toString();
    String title = job['service_type'] ?? 'Unknown Service';
    String dateStr = job['selected_date'] ?? 'ไม่ระบุวันที่';
    String timeStr = job['selected_time'] ?? '';
    String displayDate = timeStr.isNotEmpty ? '$dateStr | $timeStr' : dateStr;
    String address = job['address'] ?? 'ไม่ระบุที่อยู่';
    String details = job['details'] ?? '-';
    String status = (job['status'] ?? 'pending').toString().toLowerCase();

    bool isPending = status == 'pending';

    // สีป้ายสถานะ
    Color statusBgColor;
    Color statusTextColor;
    if (status == 'cancelled') {
      statusBgColor = Colors.red.shade50;
      statusTextColor = Colors.red;
    } else if (isPending) {
      statusBgColor = Colors.amber.shade50;
      statusTextColor = Colors.amber.shade700;
    } else {
      statusBgColor = Colors.blue.shade50;
      statusTextColor = Colors.blueAccent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1️⃣ Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.ac_unit,
                  color: Colors.black87,
                  size: 28,
                ), // ไอคอนปรับตามประเภททีหลังได้
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayDate,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 2️⃣ Tracker (จุดสีเหลืองขยับได้!)
          _buildTracker(status),

          Divider(color: Colors.grey.shade200, thickness: 1),
          const SizedBox(height: 10),

          // 3️⃣ Service Details
          const Text(
            'Service Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            details,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 15),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ),
            ],
          ),

          // 4️⃣ Action Buttons (โชว์เฉพาะตอน pending หรือ confirmed)
          if (status == 'pending' || status == 'confirmed') ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {}, // ไว้ทำปุ่มแก้ไขทีหลัง
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                      side: BorderSide(color: Colors.blueAccent.shade100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Edit Info',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _cancelBooking(jobId), // เรียกฟังก์ชันยกเลิก
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
