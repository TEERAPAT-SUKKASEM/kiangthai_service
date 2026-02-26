import 'package:flutter/material.dart';

class AcServiceForm extends StatefulWidget {
  const AcServiceForm({super.key});

  @override
  State<AcServiceForm> createState() => _AcServiceFormState();
}

class _AcServiceFormState extends State<AcServiceForm> {
  // --- 🧠 ตัวแปรเก็บข้อมูลเตรียมส่งเข้า Database ---
  String _serviceType = 'Cleaning'; // ค่าเริ่มต้น: ล้างแอร์
  String _acType = 'Wall Mounted'; // ค่าเริ่มต้น: แอร์ผนัง
  String _btuSize = 'Not sure'; // ค่าเริ่มต้น: ไม่แน่ใจ
  int _acCount = 1;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
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

  @override
  void dispose() {
    _addressController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.blueAccent),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.blueAccent),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _submitBooking() {
    // 🚧 เช็คว่ากรอกข้อมูลครบไหมก่อนส่ง
    if (_selectedDate == null ||
        _selectedTime == null ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date, time and enter your address.'),
        ),
      );
      return;
    }

    // โชว์ข้อมูลที่เตรียมส่งเข้า DB ใน Console
    print("--- AC BOOKING DATA ---");
    print("Service: $_serviceType");
    print("AC Type: $_acType | BTU: $_btuSize | Units: $_acCount");
    print("Date: $_selectedDate | Time: $_selectedTime");
    print("Address: ${_addressController.text}");
    print("Details: ${_detailsController.text}");

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

                    // --- 🛠️ ประเภทงาน (Choice Chips) ---
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
                          onSelected: (selected) {
                            if (selected) setState(() => _serviceType = type);
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
                    const SizedBox(height: 30),

                    // --- 📝 รายละเอียดแอร์ ---
                    const Text(
                      'AC Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Dropdown ประเภทแอร์
                    DropdownButtonFormField<String>(
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
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _acType = val!),
                    ),
                    const SizedBox(height: 15),

                    Row(
                      children: [
                        // Dropdown ขนาด BTU
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            value: _btuSize,
                            decoration: InputDecoration(
                              labelText: 'BTU Size',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: _btuOptions
                                .map(
                                  (size) => DropdownMenuItem(
                                    value: size,
                                    child: Text(
                                      size,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) => setState(() => _btuSize = val!),
                          ),
                        ),
                        const SizedBox(width: 15),
                        // ปุ่มเพิ่ม/ลด จำนวนเครื่อง
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5),
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

                    // --- 📅 วันเวลา และ สถานที่ ---
                    const Text(
                      'Schedule & Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(
                              _selectedDate == null
                                  ? 'Select Date'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickTime,
                            icon: const Icon(Icons.access_time, size: 18),
                            label: Text(
                              _selectedTime == null
                                  ? 'Select Time'
                                  : _selectedTime!.format(context),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _addressController,
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
                        hintText:
                            'Any specific issues? (e.g., leaking water, weird noise)...',
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
}
