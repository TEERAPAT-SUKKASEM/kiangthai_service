import 'package:flutter/material.dart';

class PromosTab extends StatefulWidget {
  const PromosTab({super.key});

  @override
  State<PromosTab> createState() => _PromosTabState();
}

class _PromosTabState extends State<PromosTab> {
  final Set<int> _collectedCoupons = {};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          const Text(
            'Exclusive Promos',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Collect your discount codes below',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 25),

          _buildCouponTicket(
            id: 1,
            discount: '50%\nOFF',
            title: 'First AC Cleaning',
            subtitle: 'Max discount ฿300',
            expiry: 'Expires in 2 days',
            color: Colors.blueAccent,
          ),
          const SizedBox(height: 15),
          _buildCouponTicket(
            id: 2,
            discount: '฿200\nOFF',
            title: 'Electrical Repair',
            subtitle: 'Min. spend ฿1,000',
            expiry: 'Expires in 5 days',
            color: Colors.amber,
          ),
          const SizedBox(height: 15),
          _buildCouponTicket(
            id: 3,
            discount: '15%\nOFF',
            title: 'Solar Cell Install',
            subtitle: 'For new customers only',
            expiry: 'Valid until end of month',
            color: Colors.teal,
          ),
          const SizedBox(height: 15),
          _buildCouponTicket(
            id: 4,
            discount: 'FREE\nCHK',
            title: 'CCTV Checkup',
            subtitle: 'Free system diagnostic',
            expiry: 'Limited to 50 users',
            color: Colors.indigo,
          ),
        ],
      ),
    );
  }

  Widget _buildCouponTicket({
    required int id,
    required String discount,
    required String title,
    required String subtitle,
    required String expiry,
    required Color color,
  }) {
    bool isCollected = _collectedCoupons.contains(id);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 25),
            decoration: BoxDecoration(
              color: isCollected ? Colors.grey.shade300 : color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
            ),
            child: Center(
              child: Text(
                discount,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCollected ? Colors.grey : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 10),

                  // 🛠️ แก้บั๊กแถบเหลืองดำตรงนี้ครับ 🛠️
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // สั่งให้ส่วนข้อความเวลายืดหยุ่นได้
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            // ใส่ Expanded ครอบ Text อีกชั้น และสั่งให้ตัดคำด้วย ... (ellipsis) ถ้าที่เต็ม
                            Expanded(
                              child: Text(
                                expiry,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8), // เว้นระยะห่างก่อนถึงปุ่มนิดนึง
                      // ปุ่ม Collect
                      ElevatedButton(
                        onPressed: isCollected
                            ? null
                            : () {
                                setState(() => _collectedCoupons.add(id));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Collected: $title')),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCollected
                              ? Colors.grey.shade200
                              : color,
                          foregroundColor: isCollected
                              ? Colors.grey
                              : Colors.white,
                          elevation: isCollected ? 0 : 2,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 0,
                          ),
                          minimumSize: const Size(0, 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          isCollected ? 'Collected' : 'Collect',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
