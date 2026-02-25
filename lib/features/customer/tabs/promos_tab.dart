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

          // --- รายการคูปอง (แบบใหม่ Ticket Style) ---
          _buildTicketCoupon(
            id: 1,
            discount: '50%\nOFF',
            title: 'First AC Cleaning',
            subtitle: 'Max discount ฿300',
            expiry: 'Exp: 2 days left',
            color1: Colors.purpleAccent,
            color2: Colors.pinkAccent,
          ),
          const SizedBox(height: 20),
          _buildTicketCoupon(
            id: 2,
            discount: '฿200\nOFF',
            title: 'Electrical Repair',
            subtitle: 'Min. spend ฿1,000',
            expiry: 'Exp: 5 days left',
            color1: Colors.orangeAccent,
            color2: Colors.deepOrangeAccent,
          ),
          const SizedBox(height: 20),
          _buildTicketCoupon(
            id: 3,
            discount: '15%\nOFF',
            title: 'Solar Cell Install',
            subtitle: 'New customers',
            expiry: 'Exp: End of month',
            color1: Colors.tealAccent,
            color2: Colors.teal,
          ),
          const SizedBox(height: 20),
          _buildTicketCoupon(
            id: 4,
            discount: 'FREE\nCHK',
            title: 'CCTV Checkup',
            subtitle: 'Diagnostic only',
            expiry: 'Exp: 50 users',
            color1: Colors.blueAccent,
            color2: Colors.indigoAccent,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 🎟️ Widget สร้างคูปองทรงตั๋ว (Ticket Style)
  // ==========================================
  Widget _buildTicketCoupon({
    required int id,
    required String discount,
    required String title,
    required String subtitle,
    required String expiry,
    required Color color1,
    required Color color2,
  }) {
    bool isCollected = _collectedCoupons.contains(id);
    const double cutoutRadius = 12.0; // ขนาดรอยบากวงกลม

    return Stack(
      children: [
        // --- ชั้นล่าง: เงาของตั๋ว ---
        Container(
          height: 140,
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        ),
        // --- ชั้นบน: ตัวตั๋วที่ถูกตัดขอบ ---
        ClipPath(
          clipper: TicketClipper(cutoutRadius: cutoutRadius),
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                // 👉 ฝั่งซ้าย: สีไล่ระดับ + ส่วนลด
                Container(
                  width: 130,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isCollected
                          ? [Colors.grey.shade400, Colors.grey.shade600]
                          : [color1, color2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'COUPON',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        discount,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'PROMO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 👉 ฝั่งขวา: รายละเอียด + ปุ่ม
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      25,
                      15,
                      15,
                      15,
                    ), // เว้นซ้ายเยอะหน่อยหลบเส้นปะ
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isCollected
                                    ? Colors.grey
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  expiry,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                            // ปุ่ม Collect
                            ElevatedButton(
                              onPressed: isCollected
                                  ? null
                                  : () {
                                      setState(() => _collectedCoupons.add(id));
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Collected: $title'),
                                        ),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isCollected
                                    ? Colors.grey.shade300
                                    : color2,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                isCollected ? 'Collected' : 'Collect',
                                style: const TextStyle(
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

                // 👉 ขวาสุด: ข้อความแนวตั้งเท่ๆ
                RotatedBox(
                  quarterTurns: 3, // หมุน 270 องศา
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 15.0,
                    ),
                    child: Text(
                      'KIANGTHAI TICKET',
                      style: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // --- ชั้นบนสุด: วาดเส้นปะตรงกลาง ---
        Positioned(
          top: cutoutRadius,
          bottom: cutoutRadius,
          left: 130 - 1, // ตำแหน่งเดียวกับความกว้างฝั่งซ้าย
          child: CustomPaint(
            size: const Size(2, double.infinity),
            painter: DashedLinePainter(),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// ✂️ Class สำหรับตัดขอบเป็นทรงตั๋ว (Ticket Shape)
// ==========================================
class TicketClipper extends CustomClipper<Path> {
  final double cutoutRadius;
  TicketClipper({required this.cutoutRadius});

  @override
  Path getClip(Size size) {
    final path = Path();
    const double splitX =
        130.0; // ตำแหน่งที่จะตัดแบ่ง (ตรงกับความกว้างฝั่งซ้าย)

    path.moveTo(0, 0);
    path.lineTo(splitX - cutoutRadius, 0);
    // วาดรอยบากครึ่งวงกลมด้านบน
    path.arcToPoint(
      Offset(splitX + cutoutRadius, 0),
      radius: Radius.circular(cutoutRadius),
      clockwise: false,
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(splitX + cutoutRadius, size.height);
    // วาดรอยบากครึ่งวงกลมด้านล่าง
    path.arcToPoint(
      Offset(splitX - cutoutRadius, size.height),
      radius: Radius.circular(cutoutRadius),
      clockwise: false,
    );
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(TicketClipper oldClipper) => false;
}

// ==========================================
// 🖊️ Class สำหรับวาดเส้นปะ (Dashed Line)
// ==========================================
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 5, startY = 0;
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 2;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
