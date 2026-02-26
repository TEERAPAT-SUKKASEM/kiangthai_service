import 'package:flutter/material.dart';

class AcServiceForm extends StatefulWidget {
  const AcServiceForm({super.key});

  @override
  State<AcServiceForm> createState() => _AcServiceFormState();
}

class _AcServiceFormState extends State<AcServiceForm> {
  // --- 🧠 ตัวแปรเก็บข้อมูล ---
  String _serviceType = 'Cleaning';
  String _acType = 'Wall Mounted';
  String _btuSize = 'Not sure';
  int _acCount = 1;

  DateTime _selectedDate = DateTime.now().add(
    const Duration(days: 1),
  ); // ค่าเริ่มต้นคือพรุ่งนี้
  String? _selectedTime; // เปลี่ยนมาเก็บเวลาเป็น String (เช่น '09:30')
  int _timeTab = 0; // 0 = เช้า, 1 = บ่าย

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  final List<String> _serviceOptions = [
    'Cleaning',
    'Repair',
    'Installation',
    'Inspection',
  ];
  final List<String> _acTypeOptions = [
    'Wall Mounted',
    'Cassette Type',
    'Standing',
  ];
  final List<String> _btuOptions = [
    'Not sure',
    '9,000 BTU',
    '12,000 BTU',
    '18,000 BTU',
    '24,000+ BTU',
  ];

  // ⏰ รายการเวลา เช้า-บ่าย (ห่างทีละ 30 นาที)
  final List<String> _morningSlots = [
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
  ];
  final List<String> _afternoonSlots = [
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
  ];

  // 🔒 MOCK DATA: จำลองข้อมูลว่าเวลานี้/วันนี้ "คิวเต็มแล้ว" (เดี๋ยวตอนต่อ DB ค่อยดึงของจริงมาใส่)
  final List<String> _bookedTimeSlots = [
    '09:30',
    '10:00',
    '14:30',
    '15:00',
  ]; // เวลาที่โดนจองแล้ว
  final DateTime _fullyBookedDate = DateTime.now().add(
    const Duration(days: 3),
  ); // สมมติว่าอีก 3 วันคิวเต็มทั้งวัน

  @override
  void dispose() {
    _addressController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _submitBooking() {
    if (_selectedTime == null || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select time and enter your address.'),
        ),
      );
      return;
    }

    print("--- AC BOOKING DATA ---");
    print("Service: $_serviceType | $_acType | $_btuSize | $_acCount Units");
    print(
      "Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} | Time: $_selectedTime",
    );
    print("Address: ${_addressController.text}");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking Details Ready to Save!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Book AC Service',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- ❄️ Header ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.ac_unit,
                            size: 40,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'AC Service',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Provide details for the best service',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- 🛠️ Service Type & Details ---
                    const Text(
                      'Service Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _serviceOptions.map((type) {
                        bool isSelected = _serviceType == type;
                        return ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _serviceType = type);
                          },
                          selectedColor: Colors.blueAccent.withOpacity(0.2),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.blueAccent
                                : Colors.grey.shade600,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.blueAccent
                                  : Colors.grey.shade300,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 25),

                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            value: _acType,
                            decoration: InputDecoration(
                              labelText: 'AC Type',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: _acTypeOptions
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(
                                      type,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) => setState(() => _acType = val!),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() {
                                    if (_acCount > 1) _acCount--;
                                  }),
                                  child: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                Text(
                                  '$_acCount',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() => _acCount++),
                                  child: const Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // --- 📅 ปฏิทินเลือกวัน (Inline Calendar) ---
                    const Text(
                      'Select Date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: CalendarDatePicker(
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 60),
                        ), // จองล่วงหน้าได้ 60 วัน
                        onDateChanged: (date) {
                          setState(() {
                            _selectedDate = date;
                            _selectedTime =
                                null; // รีเซ็ตเวลาทุกครั้งที่เปลี่ยนวัน
                          });
                        },
                        selectableDayPredicate: (DateTime date) {
                          // 🔒 จำลองระบบบล็อกวัน: ถ้าเป็นวันที่ตั้งไว้ว่าคิวเต็ม ให้กดไม่ได้ (สีเทา)
                          if (date.year == _fullyBookedDate.year &&
                              date.month == _fullyBookedDate.month &&
                              date.day == _fullyBookedDate.day) {
                            return false;
                          }
                          return true;
                        },
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- ⏰ เลือกเวลา (Time Slots) ---
                    const Text(
                      'Select Time',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // แท็บสลับ เช้า-บ่าย
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        children: [
                          Expanded(child: _buildTimeTab('Morning', 0)),
                          Expanded(child: _buildTimeTab('Afternoon', 1)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // กล่องโชว์เวลา (ดึงข้อมูล เช้า หรือ บ่าย ตามแท็บที่เลือก)
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          (_timeTab == 0 ? _morningSlots : _afternoonSlots).map(
                            (time) {
                              bool isBooked = _bookedTimeSlots.contains(
                                time,
                              ); // เช็คว่าคิวเต็มไหม
                              bool isSelected = _selectedTime == time;

                              return GestureDetector(
                                onTap: isBooked
                                    ? null
                                    : () =>
                                          setState(() => _selectedTime = time),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width:
                                      (MediaQuery.of(context).size.width - 64) /
                                      3, // แบ่ง 3 คอลัมน์พอดีเป๊ะ
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isBooked
                                        ? Colors.grey.shade100
                                        : (isSelected
                                              ? Colors.blueAccent
                                              : Colors.white),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isBooked
                                          ? Colors.transparent
                                          : (isSelected
                                                ? Colors.blueAccent
                                                : Colors.grey.shade300),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      time,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isBooked
                                            ? Colors.grey.shade400
                                            : (isSelected
                                                  ? Colors.white
                                                  : Colors.black87),
                                        decoration: isBooked
                                            ? TextDecoration.lineThrough
                                            : null, // ขีดฆ่าเวลาที่เต็มแล้ว
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                    ),
                    const SizedBox(height: 30),

                    // --- 📍 สถานที่และรายละเอียด ---
                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Full Address...',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _detailsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Any specific issues?',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- 🚀 ปุ่มยืนยัน ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Confirm AC Booking',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget สำหรับปุ่มแท็บ เช้า-บ่าย
  Widget _buildTimeTab(String title, int index) {
    bool isActive = _timeTab == index;
    return GestureDetector(
      onTap: () => setState(() {
        _timeTab = index;
        _selectedTime = null; // เปลี่ยนแท็บปุ๊บ รีเซ็ตเวลาที่เลือกไว้
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              color: isActive ? Colors.black87 : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }
}
