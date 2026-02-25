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

          // --- รายการคูปอง (แบบใหม่ สลับฝั่งสั้นไปขวา) ---
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
            subtitle: 'For new customers only',
            expiry: 'Exp: End of month',
            color1: Colors.tealAccent,
            color2: Colors.teal,
          ),
          const SizedBox(height: 20),
          _buildTicketCoupon(
            id: 4,
            discount: 'FREE\nCHK',
            title: 'CCTV Checkup',
            subtitle: 'Free system diagnostic',
            expiry: 'Exp: Limited to 50 users',
            color1: Colors.blueAccent,
            color2: Colors.indigoAccent,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 🎟️ Widget สร้างคูปองทรงตั๋ว (อัปเกรด: ฝั่งยาวซ้าย ฝั่งสั้นขวา)
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
    const double cutoutRadius = 12.0;
    const double ticketHeight =
        140.0; // ความสูงกลับมาที่ 140 ได้แล้วเพราะพื้นที่ซ้ายกว้างขึ้น
    const double shortSideWidth = 120.0; // กำหนดความกว้างของฝั่งขวา (ฝั่งสั้น)

    return Stack(
      children: [
        // --- ชั้นล่าง: เงา ---
        Container(
          height: ticketHeight,
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
        // --- ชั้นบน: ตัวตั๋ว ---
        ClipPath(
          clipper: TicketClipper(
            cutoutRadius: cutoutRadius,
            shortSideWidth: shortSideWidth,
          ),
          child: Container(
            height: ticketHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                // 👉 ฝั่งซ้าย (ฝั่งยาว): สีขาว ใส่รายละเอียด
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      20,
                      15,
                      20,
                    ), // ขอบซ้าย บน ขวา(หลบเส้นปะ) ล่าง
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isCollected ? Colors.grey : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
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
                      ],
                    ),
                  ),
                ),

                // 👉 ฝั่งขวา (ฝั่งสั้น): สีไล่ระดับ + ส่วนลด + ปุ่ม Collect
                Container(
                  width: shortSideWidth,
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
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        discount,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 🧠 ปุ่ม Collect แทนที่ PROMO
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
                              ? Colors.grey.shade300
                              : Colors.white, // ปุ่มสีขาว
                          foregroundColor: isCollected
                              ? Colors.grey
                              : color2, // ตัวหนังสือสีตามธีม
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          isCollected ? 'Collected' : 'Collect',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // --- ชั้นบนสุด: เส้นปะ ---
        Positioned(
          top: cutoutRadius,
          bottom: cutoutRadius,
          right: shortSideWidth - 1, // 👈 ย้ายเส้นปะมาอิงจากขอบขวาแทน
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
// ✂️ Class สำหรับตัดขอบ (แก้ไขให้ตัดที่ฝั่งขวา)
// ==========================================
class TicketClipper extends CustomClipper<Path> {
  final double cutoutRadius;
  final double shortSideWidth;
  TicketClipper({required this.cutoutRadius, required this.shortSideWidth});

  @override
  Path getClip(Size size) {
    final path = Path();
    // คำนวณจุดที่จะเจาะรอยบาก (เอาความกว้างทั้งหมด ลบด้วย ความกว้างฝั่งสั้น)
    final double splitX = size.width - shortSideWidth;

    path.moveTo(0, 0);
    path.lineTo(splitX - cutoutRadius, 0);
    // รอยบากบน
    path.arcToPoint(
      Offset(splitX + cutoutRadius, 0),
      radius: Radius.circular(cutoutRadius),
      clockwise: false,
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(splitX + cutoutRadius, size.height);
    // รอยบากล่าง
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
// 🖊️ Class สำหรับวาดเส้นปะ
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
