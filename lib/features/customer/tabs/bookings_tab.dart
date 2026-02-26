import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 🚀 นำเข้า Supabase

class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  // 🚀 ตัวแปรจัดการ Database
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;

  // 🧠 แยก List สำหรับ 2 แท็บ
  List<Map<String, dynamic>> _upcomingBookings = [];
  List<Map<String, dynamic>> _historyBookings = [];

  // 0 = โชว์ Upcoming, 1 = โชว์ History
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _fetchBookings(); // ดึงข้อมูลทันทีเมื่อเปิดหน้านี้
  }

  // ==========================================
  // 🚀 ฟังก์ชันดึงข้อมูลจาก Supabase
  // ==========================================
  Future<void> _fetchBookings() async {
    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('bookings')
          .select()
          .eq('customer_id', user.id)
          .order('created_at', ascending: false);

      final upcoming = <Map<String, dynamic>>[];
      final history = <Map<String, dynamic>>[];

      for (var booking in response) {
        final status = (booking['status'] ?? 'pending')
            .toString()
            .toLowerCase();
        // ถ้าเสร็จสิ้น หรือ ยกเลิก ให้ไปอยู่แท็บ History
        if (status == 'completed' || status == 'cancelled') {
          history.add(booking);
        } else {
          // นอกนั้น (pending, confirmed, etc.) ให้อยู่แท็บ Upcoming
          upcoming.add(booking);
        }
      }

      if (mounted) {
        setState(() {
          _upcomingBookings = upcoming;
          _historyBookings = history;
        });
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading bookings: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🎨 ตัวช่วยแปลงสถานะ เป็นตัวเลขสเต็ป (0-5) สำหรับ Tracker Bar
  int _getStepFromStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0; // Request
      case 'confirmed':
      case 'accepted':
        return 1; // Accept
      case 'arriving':
        return 2; // Arrive
      case 'working':
      case 'in_progress':
        return 3; // Work
      case 'finished':
        return 4; // Finish
      case 'completed':
      case 'paid':
        return 5; // Pay
      default:
        return 0;
    }
  }

  // 🎨 ตัวช่วยแปลงหมวดหมู่เป็น ไอคอน
  IconData _getServiceIcon(String category) {
    switch (category) {
      case 'AC Service':
        return Icons.ac_unit;
      case 'Electrical':
        return Icons.electrical_services;
      case 'Solar Cell':
        return Icons.solar_power;
      case 'CCTV':
        return Icons.videocam;
      case 'Water Pump':
        return Icons.water_drop;
      case 'Electronics':
        return Icons.tv;
      default:
        return Icons.build;
    }
  }

  // 🎨 ตัวช่วยแปลงสถานะเป็น สี
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.amber.shade700;
      case 'confirmed':
        return Colors.blueAccent;
      case 'arriving':
        return Colors.purple;
      case 'working':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

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

          // --- 📋 ส่วนแสดงรายการ พร้อม Pull to Refresh ---
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchBookings,
              color: Colors.blueAccent,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(), // บังคับเลื่อนได้เพื่อใช้ RefreshIndicator
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                      children: _selectedTab == 0
                          ? _buildUpcomingList()
                          : _buildHistoryList(),
                    ),
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
    if (_upcomingBookings.isEmpty) {
      return [
        _buildEmptyState(
          'No upcoming bookings',
          'Book a service to see it here.',
        ),
      ];
    }

    return _upcomingBookings.map((booking) {
      final status = booking['status']?.toString() ?? 'pending';
      return Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: _buildBookingCard(
          title: '${booking['service_category']} - ${booking['service_type']}',
          date: '${booking['booking_date']} | ${booking['booking_time']}',
          status: status.toUpperCase(),
          statusColor: _getStatusColor(status),
          icon: _getServiceIcon(booking['service_category']),
          price: 'Pending', // อนาคตช่างประเมินแล้วค่อยดึงมาใส่
          technician: 'Pending Tech.',
          currentStep: _getStepFromStatus(status),
          isHistory: false,
        ),
      );
    }).toList();
  }

  // ==========================================
  // ✅ รายการ: History
  // ==========================================
  List<Widget> _buildHistoryList() {
    if (_historyBookings.isEmpty) {
      return [
        _buildEmptyState(
          'No history yet',
          'Your completed services will appear here.',
        ),
      ];
    }

    return _historyBookings.map((booking) {
      final status = booking['status']?.toString() ?? 'completed';
      return Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: _buildBookingCard(
          title: '${booking['service_category']} - ${booking['service_type']}',
          date: '${booking['booking_date']} | ${booking['booking_time']}',
          status: status.toUpperCase(),
          statusColor: _getStatusColor(status),
          icon: _getServiceIcon(booking['service_category']),
          price: 'Est. ฿???', // อนาคตใส่ราคาจริง
          technician: 'Assigned Tech',
          isHistory: true,
        ),
      );
    }).toList();
  }

  // ==========================================
  // 📭 หน้าจอว่างเปล่า (Empty State)
  // ==========================================
  Widget _buildEmptyState(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 5),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  // ==========================================
  // 🃏 Widget: การ์ดรายการจอง (ดีไซน์เดิมของคุณ!)
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                    fontSize: 11,
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

          if (!isHistory && currentStep != null)
            _buildTrackerBar(currentStep)
          else
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
    final steps = ['Request', 'Accept', 'Arrive', 'Work', 'Finish', 'Pay'];
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 10,
          left: 15,
          right: 15,
          child: Container(height: 2, color: Colors.grey.shade200),
        ),
        Positioned(
          top: 10,
          left: 15,
          right: 15,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: steps.length > 1
                ? currentStep / (steps.length - 1)
                : 0, // ป้องกันบั๊กหารด้วย 0
            child: Container(height: 2, color: Colors.amber),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(steps.length, (index) {
            bool isCompleted = index <= currentStep;
            return SizedBox(
              width: 42,
              child: Column(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.amber : Colors.grey.shade200,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
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
                      fontSize: 9,
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
