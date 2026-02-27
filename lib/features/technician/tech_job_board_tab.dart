import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TechJobBoardTab extends StatefulWidget {
  const TechJobBoardTab({super.key});

  @override
  State<TechJobBoardTab> createState() => _TechJobBoardTabState();
}

class _TechJobBoardTabState extends State<TechJobBoardTab> {
  // 🧠 0 = Requests, 1 = To-Do
  int _selectedTab = 0;
  final _supabase = Supabase.instance.client;

  // 🚀 ฟังก์ชันสำหรับกดรับงาน
  Future<void> _acceptJob(String jobId) async {
    try {
      // โชว์ Loading นิดนึงให้ดูโปร
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CircularProgressIndicator(color: Colors.amber)),
      );

      // ยิงคำสั่งอัปเดตสถานะไปที่ Supabase
      await _supabase
          .from('bookings')
          .update({'status': 'confirmed'}) // เปลี่ยนเป็น confirmed
          .eq('id', jobId); // อ้างอิงจาก ID ของงานนั้นๆ

      // ปิดหน้าต่าง Loading
      if (mounted) Navigator.pop(context);

      // แจ้งเตือนความสำเร็จ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ รับงานสำเร็จ! ดูรายละเอียดได้ในแท็บ To-Do'),
          ),
        );
      }
    } catch (e) {
      if (mounted)
        Navigator.pop(context); // ปิดหน้าต่าง Loading ก่อนถ้ามี Error
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
          // ==========================================
          // 1. Top Bar: Profile | Custom Text Logo | Notifications
          // ==========================================
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

          // ==========================================
          // 2. Greeting
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
                  'Wishing you a safe and successful day! 🛠️',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ==========================================
          // 3. Toggle Bar: Requests / To-Do
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
                  Expanded(child: _buildTabButton('Requests', 0)),
                  Expanded(child: _buildTabButton('To-Do', 1)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ==========================================
          // 4. Content List (Real-time Stream)
          // ==========================================
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
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
                  return Center(
                    child: Text(
                      'No jobs available right now. ☕',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                final allBookings = snapshot.data!;

                // 🧠 สับรางข้อมูลตาม Tab
                final displayList = allBookings.where((job) {
                  final status = job['status'] ?? 'pending';
                  if (_selectedTab == 0) {
                    return status == 'pending'; // แท็บซ้าย: รอยืนยัน
                  } else {
                    return status != 'pending'; // แท็บขวา: ยืนยันแล้ว หรืออื่นๆ
                  }
                }).toList();

                if (displayList.isEmpty) {
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
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    final job = displayList[index];
                    return _buildRealCard(job);
                  },
                );
              },
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

  // 🌟 การ์ดโชว์ข้อมูล และปุ่มรับงาน
  Widget _buildRealCard(Map<String, dynamic> job) {
    String jobId = job['id'].toString();
    String title = job['service_type'] ?? 'Unknown Service';
    String subtitle = job['address'] ?? 'No address provided';
    String status = (job['status'] ?? 'pending').toString().toLowerCase();

    bool isPending = status == 'pending';
    Color statusColor = isPending ? Colors.amber.shade700 : Colors.blueAccent;
    String displayStatus = isPending ? 'PENDING' : status.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
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
                  displayStatus,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // 🛑 เพิ่มปุ่มตรงนี้! โชว์เฉพาะตอนสถานะ pending
          if (isPending) ...[
            const SizedBox(height: 15),
            const Divider(height: 1),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _acceptJob(jobId), // 👈 กดแล้วเรียกฟังก์ชันอัปเดต DB
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Accept Job',
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
