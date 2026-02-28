import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TechJobBoardTab extends StatefulWidget {
  const TechJobBoardTab({super.key});

  @override
  State<TechJobBoardTab> createState() => _TechJobBoardTabState();
}

class _TechJobBoardTabState extends State<TechJobBoardTab> {
  int _selectedTab = 0; // 0 = Requests, 1 = To-Do
  final _supabase = Supabase.instance.client;

  // 🚀 ฟังก์ชันกดรับงาน (เปลี่ยนเป็น confirmed)
  Future<void> _acceptJob(String jobId) async {
    _updateJobStatusInDB(
      jobId,
      'confirmed',
      '✅ รับงานสำเร็จ! ดูรายละเอียดได้ในแท็บ To-Do',
    );
  }

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

      // ถ้าเป็นการกดเปลี่ยนสถานะจากเมนู Bottom Sheet ให้ปิด Bottom Sheet ด้วย
      if (newStatus != 'confirmed' && mounted) {
        Navigator.pop(context);
      }

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

  // 📋 ฟังก์ชันโชว์เมนูเด้งขึ้นมาจากขอบล่าง (Bottom Sheet)
  void _showStatusMenu(String jobId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'อัปเดตสถานะหน้างาน',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    color: Colors.blueAccent,
                  ),
                ),
                title: const Text(
                  'กำลังเดินทาง (Traveling)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => _updateJobStatusInDB(
                  jobId,
                  'traveling',
                  '🚗 อัปเดตสถานะ: กำลังเดินทาง',
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.build, color: Colors.orange),
                ),
                title: const Text(
                  'กำลังดำเนินการ (Working)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => _updateJobStatusInDB(
                  jobId,
                  'working',
                  '🛠️ อัปเดตสถานะ: กำลังดำเนินการซ่อม',
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.green),
                ),
                title: const Text(
                  'งานเสร็จสิ้น (Completed)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => _updateJobStatusInDB(
                  jobId,
                  'completed',
                  '✅ อัปเดตสถานะ: งานเสร็จสิ้นแล้ว!',
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.payments, color: Colors.amber),
                ),
                title: const Text(
                  'รับเงินเรียบร้อย (Paid)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => _updateJobStatusInDB(
                  jobId,
                  'paid',
                  '💰 ปิดจ๊อบ! รับเงินเรียบร้อย',
                ),
              ),
            ],
          ),
        );
      },
    );
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
                  // แท็บ Requests โชว์แค่ pending
                  if (_selectedTab == 0) return status == 'pending';
                  // แท็บ To-Do โชว์งานที่ยังไม่เสร็จ (ไม่รวม pending และ cancelled)
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

          if (isPending) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _acceptJob(jobId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Accept Job',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    // 👇 เปลี่ยนตรงนี้! พอกดปุ่มแล้วให้เรียกฟังก์ชันโชว์เมนูเด้ง 👇
                    onPressed: () => _showStatusMenu(jobId),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                      side: const BorderSide(color: Colors.blueAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Update Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
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
