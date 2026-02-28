import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart'; // 👈 นำเข้าปลั๊กอิน QR Code ตรงนี้ครับ

class TechJobBoardTab extends StatefulWidget {
  const TechJobBoardTab({super.key});

  @override
  State<TechJobBoardTab> createState() => _TechJobBoardTabState();
}

class _TechJobBoardTabState extends State<TechJobBoardTab> {
  int _selectedTab = 0; // 0 = Requests, 1 = To-Do
  final _supabase = Supabase.instance.client;

  // 🚀 ฟังก์ชันกลางสำหรับอัปเดตสถานะทุกแบบ
  Future<void> _updateJobStatusInDB(
    String jobId,
    String newStatus,
    String successMessage,
  ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CircularProgressIndicator(color: Colors.amber)),
      );

      await _supabase
          .from('bookings')
          .update({'status': newStatus})
          .eq('id', jobId);

      if (mounted) Navigator.pop(context); // ปิด Loading

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(successMessage)));
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ เกิดข้อผิดพลาด: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.amber.shade100,
                  backgroundImage: const NetworkImage(
                    'https://i.pravatar.cc/150?img=11',
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Kiang',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.amber.shade600,
                          ),
                        ),
                        const Text(
                          'Thai',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'S E R V I C E',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 3.0,
                      ),
                    ),
                  ],
                ),
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
                  'Wishing you a safe and successful day! 🛠️',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(5),
              child: Row(
                children: [
                  Expanded(child: _buildTabButton('Requests', 0)),
                  Expanded(child: _buildTabButton('To-Do', 1)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _supabase
                  .from('bookings')
                  .stream(primaryKey: ['id'])
                  .order('created_at'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  );
                if (!snapshot.hasData || snapshot.data!.isEmpty)
                  return Center(
                    child: Text(
                      'No jobs available right now. ☕',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                    ),
                  );

                final displayList = snapshot.data!.where((job) {
                  final status = job['status'] ?? 'pending';
                  if (_selectedTab == 0) return status == 'pending';
                  return status != 'pending' &&
                      status != 'cancelled' &&
                      status != 'paid';
                }).toList();

                if (displayList.isEmpty)
                  return Center(
                    child: Text(
                      _selectedTab == 0
                          ? 'No new requests.'
                          : 'No tasks on your to-do list.',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                    ),
                  );

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  itemCount: displayList.length,
                  itemBuilder: (context, index) =>
                      _buildRealCard(displayList[index]),
                );
              },
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

  IconData _getServiceIcon(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('ac') || lowerType.contains('cleaning'))
      return Icons.ac_unit;
    if (lowerType.contains('cctv')) return Icons.videocam_outlined;
    if (lowerType.contains('electric'))
      return Icons.electrical_services_outlined;
    if (lowerType.contains('water') || lowerType.contains('pump'))
      return Icons.water_drop_outlined;
    if (lowerType.contains('solar')) return Icons.solar_power_outlined;
    return Icons.handyman_outlined;
  }

  // 🌟 ฟังก์ชันสร้างปุ่มอัจฉริยะ (แบบมี QR Code รับเงิน)
  Widget _buildDynamicActionButton(String jobId, String currentStatus) {
    String text = '';
    String nextStatus = '';
    String msg = '';
    Color color = Colors.blueAccent;
    IconData icon = Icons.update;
    Color textColor = Colors.white;

    // เช็คสถานะปัจจุบัน เพื่อกำหนดว่าปุ่มควรเป็นอะไรต่อไป
    switch (currentStatus) {
      case 'pending':
        text = 'Accept Job';
        nextStatus = 'confirmed';
        msg = '✅ Job Accepted!';
        color = Colors.amber;
        textColor = Colors.black87;
        icon = Icons.assignment_turned_in;
        break;
      case 'confirmed':
        text = 'Heading';
        nextStatus = 'traveling';
        msg = '🚗 Status: Heading to location';
        color = Colors.blueAccent;
        icon = Icons.directions_car;
        break;
      case 'traveling':
        text = 'Arrive';
        nextStatus = 'arrived';
        msg = '📍 Status: Arrived at location';
        color = Colors.teal;
        icon = Icons.location_on;
        break;
      case 'arrived':
        text = 'Start Work';
        nextStatus = 'working';
        msg = '🛠️ Status: Work started';
        color = Colors.orange;
        icon = Icons.build;
        break;
      case 'working':
        text = 'Finish Job';
        nextStatus = 'completed';
        msg = '✅ Status: Job finished!';
        color = Colors.green;
        icon = Icons.check_circle;
        break;

      // 🌟 สถานะ completed -> โชว์ QR Code รับเงิน
      case 'completed':
        return Column(
          children: [
            const SizedBox(height: 10),
            const Divider(color: Color(0xFFEEEEEE), thickness: 1, height: 20),
            const Text(
              'Client Payment via QR Code',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),

            // 🖼️ ส่วนแสดง QR Code
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  QrImageView(
                    data:
                        "012345678901234", // 👉 แอดมิน: แก้เป็น PromptPay/เลขบัญชีบริษัทที่จะให้สแกน
                    version: QrVersions.auto,
                    size: 160.0,
                    gapless: false,
                    errorStateBuilder: (cxt, err) => const Text(
                      "Error generating QR",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Company PromptPay / Account',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'KiangThai SERVICE Co., Ltd.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 💰 ปุ่มกดปิดจ๊อบเมื่อรับเงินแล้ว
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateJobStatusInDB(
                      jobId,
                      'paid',
                      '💰 Payment received! Job closed.',
                    ),
                    icon: const Icon(
                      Icons.payments,
                      size: 20,
                      color: Colors.black87,
                    ),
                    label: const Text(
                      'Mark as Paid',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade400,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

      default:
        return const SizedBox(); // สถานะอื่นๆ เช่น paid ซ่อนปุ่มไปเลย
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _updateJobStatusInDB(jobId, nextStatus, msg),
            icon: Icon(icon, size: 20, color: textColor),
            label: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: textColor,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRealCard(Map<String, dynamic> job) {
    String jobId = job['id'].toString();
    String title = job['service_type'] ?? 'Unknown Service';
    String dateStr = job['selected_date'] ?? 'ไม่ระบุวันที่';
    String timeStr = job['selected_time'] ?? '';
    String displayDate = timeStr.isNotEmpty ? '$dateStr | $timeStr' : dateStr;
    String address = job['address'] ?? 'ไม่ระบุที่อยู่';
    String details = job['details'] ?? '-';
    String status = (job['status'] ?? 'pending').toString().toLowerCase();

    bool isPending = status == 'pending';

    Color statusBgColor = isPending
        ? Colors.amber.shade50
        : Colors.blue.shade50;
    Color statusTextColor = isPending
        ? Colors.amber.shade700
        : Colors.blueAccent;
    String displayStatus = status.toUpperCase();

    IconData serviceIcon = _getServiceIcon(title);

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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(serviceIcon, color: Colors.black87, size: 28),
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
                  displayStatus,
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Divider(color: Colors.grey.shade200, thickness: 1),
          const SizedBox(height: 15),
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
          const SizedBox(height: 20),
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

          const SizedBox(height: 20),
          // 👇 ส่วนนี้จะแสดงปุ่มแบบอัจฉริยะ (และจะกลายเป็น QR Code ตอนงานเสร็จ!)
          _buildDynamicActionButton(jobId, status),
        ],
      ),
    );
  }
}
