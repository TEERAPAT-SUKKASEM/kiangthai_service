import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;

  List<Map<String, dynamic>> _upcomingBookings = [];
  List<Map<String, dynamic>> _historyBookings = [];

  int _selectedTab = 0;

  // 🧠 ตัวแปรเก็บ ID ของการ์ดที่ถูก "กางออก" อยู่
  final Set<String> _expandedIds = {};

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

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
        if (status == 'completed' || status == 'cancelled') {
          history.add(booking);
        } else {
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
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🔄 ฟังก์ชันสลับการกาง/หุบ การ์ด
  void _toggleExpand(String id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  // 🚀 ฟังก์ชันยกเลิกงาน (Cancel Booking)
  Future<void> _cancelBooking(String bookingId) async {
    // โชว์ Dialog ถามความแน่ใจก่อน
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cancel Booking?'),
            content: const Text(
              'Are you sure you want to cancel this service?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Yes, Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      // อัปเดตสถานะใน DB เป็น cancelled
      await _supabase
          .from('bookings')
          .update({'status': 'cancelled'})
          .eq('id', bookingId);
      _fetchBookings(); // รีเฟรชหน้าจอ
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Booking Cancelled.')));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  int _getStepFromStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0;
      case 'confirmed':
      case 'accepted':
        return 1;
      case 'arriving':
        return 2;
      case 'working':
      case 'in_progress':
        return 3;
      case 'finished':
        return 4;
      case 'completed':
      case 'paid':
        return 5;
      default:
        return 0;
    }
  }

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
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchBookings,
              color: Colors.blueAccent,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
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

  List<Widget> _buildUpcomingList() {
    if (_upcomingBookings.isEmpty)
      return [
        _buildEmptyState(
          'No upcoming bookings',
          'Book a service to see it here.',
        ),
      ];
    return _upcomingBookings
        .map(
          (booking) => Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _buildBookingCard(booking, isHistory: false),
          ),
        )
        .toList();
  }

  List<Widget> _buildHistoryList() {
    if (_historyBookings.isEmpty)
      return [
        _buildEmptyState(
          'No history yet',
          'Your completed services will appear here.',
        ),
      ];
    return _historyBookings
        .map(
          (booking) => Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _buildBookingCard(booking, isHistory: true),
          ),
        )
        .toList();
  }

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
  // 🃏 Widget: การ์ดรายการจอง (แยกโหมด Upcoming / History)
  // ==========================================
  Widget _buildBookingCard(
    Map<String, dynamic> booking, {
    bool isHistory = false,
  }) {
    final status = (booking['status'] ?? 'pending').toString().toLowerCase();
    final statusColor = _getStatusColor(status);
    final icon = _getServiceIcon(booking['service_category']);
    final isExpanded = _expandedIds.contains(booking['id'].toString());

    return GestureDetector(
      // 🧠 ถ้าเป็น History ปิดไม่ให้กดกางการ์ดได้
      onTap: isHistory ? null : () => _toggleExpand(booking['id'].toString()),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
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
            // --- 🟢 ส่วนหัวของการ์ด (มองเห็นตลอดทั้ง Upcoming และ History) ---
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
                        '${booking['service_category']} - ${booking['service_type']}',
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
                        '${booking['booking_date']} | ${booking['booking_time']}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
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
                        status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // ซ่อนลูกศรถ้าเป็นหน้า History
                    if (!isHistory) ...[
                      const SizedBox(height: 8),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                    ],
                  ],
                ),
              ],
            ),

            // ==========================================
            // 🔽 ส่วนด้านล่าง (เส้นคั่น, Tracker, ข้อมูลกางออก โชว์เฉพาะ Upcoming เท่านั้น)
            // ==========================================
            if (!isHistory) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Divider(height: 1, thickness: 1),
              ),

              _buildTrackerBar(_getStepFromStatus(status)),

              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: isExpanded
                    ? _buildExpandedDetails(booking, status)
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 📝 รายละเอียดตอนกางการ์ดออก
  Widget _buildExpandedDetails(Map<String, dynamic> booking, String status) {
    // 🧠 คำนวณเงื่อนไขปุ่ม
    // Request (pending) = แก้ได้, ยกเลิกได้
    // Accept (confirmed) = แก้ไม่ได้, ยกเลิกได้
    // Arrive ขึ้นไป = แก้ไม่ได้, ยกเลิกไม่ได้
    bool canEdit = status == 'pending';
    bool canCancel =
        status == 'pending' || status == 'confirmed' || status == 'accepted';

    // ดึงข้อมูล JSON เฉพาะทาง
    final specificDetails =
        booking['specific_details'] as Map<String, dynamic>? ?? {};
    final imageUrls = List<String>.from(booking['image_urls'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Divider(height: 1, thickness: 1, color: Colors.grey),
        ),

        // 📍 แสดงข้อมูลเฉพาะ
        const Text(
          'Service Details',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ...specificDetails.entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ${e.key.replaceAll('_', ' ').toUpperCase()}: ',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${e.value}',
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 16,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                booking['address'] ?? 'No address',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ),
          ],
        ),

        if (booking['issue_description'] != null &&
            booking['issue_description'].toString().isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Note: ${booking['issue_description']}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange.shade800,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],

        // 🖼️ แสดงรูปภาพ (ถ้ามี) แบบเลื่อนแนวนอน
        if (imageUrls.isNotEmpty) ...[
          const SizedBox(height: 15),
          const Text(
            'Photos',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80, // ขนาดไม่ใหญ่ไม่เล็กเกินไป
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(imageUrls[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],

        // 🔘 ปุ่ม Edit / Cancel
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: canEdit
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Edit feature coming soon!'),
                          ),
                        );
                      }
                    : null, // ถ้าเป็น null ปุ่มจะเป็นสีเทากดไม่ได้
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: canEdit ? Colors.blueAccent : Colors.grey.shade300,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Edit Info',
                  style: TextStyle(
                    color: canEdit ? Colors.blueAccent : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: canCancel
                    ? () => _cancelBooking(booking['id'].toString())
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  disabledBackgroundColor: Colors.grey.shade200,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: canCancel ? Colors.white : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

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
                : 0,
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
