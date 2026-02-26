import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class WaterPumpForm extends StatefulWidget {
  const WaterPumpForm({super.key});

  @override
  State<WaterPumpForm> createState() => _WaterPumpFormState();
}

class _WaterPumpFormState extends State<WaterPumpForm> {
  // --- 🧠 ตัวแปรเฉพาะของงานปั๊มน้ำ ---
  String _serviceType = 'Repair';
  String _pumpType = 'Not Sure';
  String _motorPower = 'Not Sure';

  // ตัวแปรปฏิทินและเวลา
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  DateTime _focusedMonth = DateTime.now();
  String? _selectedTime;
  int _timeTab = 0;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  final List<String> _serviceOptions = [
    'Repair',
    'Installation',
    'Inspection',
    'Replacement',
  ];
  final List<String> _pumpOptions = [
    'Automatic (Round)',
    'Constant Pressure (Square)',
    'Submersible',
    'Not Sure',
  ];
  final List<String> _powerOptions = [
    '100-150W',
    '200-250W',
    '300W+',
    'Not Sure',
  ];

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
  final List<String> _bookedTimeSlots = [
    '08:30',
    '09:00',
    '14:00',
    '14:30',
  ]; // สุ่มคิวเต็มของช่างปั๊มน้ำ
  final DateTime _fullyBookedDate = DateTime.now().add(const Duration(days: 1));
  final List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // 📸 ระบบรูปภาพ
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];

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

    print("--- WATER PUMP BOOKING DATA ---");
    print("Service: $_serviceType | Pump: $_pumpType | Power: $_motorPower");
    print(
      "Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} | Time: $_selectedTime",
    );
    print("Photos attached: ${_selectedImages.length} images");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Water Pump Booking Ready to Save!')),
    );
  }

  // ==========================================
  // 📸 ฟังก์ชันรูปภาพ
  // ==========================================
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.cyan),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.cyan),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (pickedFile != null)
        setState(() => _selectedImages.add(File(pickedFile.path)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error selecting image.')));
    }
  }

  // ==========================================
  // 🗓️ ป๊อปอัปเลือกเดือนและปี
  // ==========================================
  void _showMonthPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Select Month',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SizedBox(
            width: 300,
            height: 300,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                bool isSelected = _focusedMonth.month == index + 1;
                return InkWell(
                  onTap: () {
                    setState(
                      () => _focusedMonth = DateTime(
                        _focusedMonth.year,
                        index + 1,
                        1,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.cyan : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _monthNames[index].substring(0, 3),
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showYearPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Year'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              selectedDate: _focusedMonth,
              onChanged: (DateTime dateTime) {
                setState(
                  () => _focusedMonth = DateTime(
                    dateTime.year,
                    _focusedMonth.month,
                    1,
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Book Water Pump',
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
                    // --- 💧 Header (ธีมสี Cyan) ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.cyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.water_drop,
                            size: 40,
                            color: Colors.cyan,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Water Pump Service',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.cyan,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Reliable repair & installation',
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
                          selectedColor: Colors.cyan.withOpacity(0.2),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.cyan.shade800
                                : Colors.grey.shade600,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.cyan
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
                          child: DropdownButtonFormField<String>(
                            value: _pumpType,
                            decoration: InputDecoration(
                              labelText: 'Pump Type',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: _pumpOptions
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(
                                      type,
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _pumpType = val!),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _motorPower,
                            decoration: InputDecoration(
                              labelText: 'Motor Power',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: _powerOptions
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(
                                      type,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _motorPower = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // --- 🗓️ ปฏิทิน Custom ---
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
                      padding: const EdgeInsets.all(20),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.chevron_left,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                    () => _focusedMonth = DateTime(
                                      _focusedMonth.year,
                                      _focusedMonth.month - 1,
                                      1,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: _showMonthPicker,
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      foregroundColor: Colors.black87,
                                    ),
                                    child: Text(
                                      _monthNames[_focusedMonth.month - 1],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _showYearPicker,
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      foregroundColor: Colors.black87,
                                    ),
                                    child: Text(
                                      '${_focusedMonth.year}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.chevron_right,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                    () => _focusedMonth = DateTime(
                                      _focusedMonth.year,
                                      _focusedMonth.month + 1,
                                      1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                                .map(
                                  (day) => SizedBox(
                                    width: 35,
                                    child: Center(
                                      child: Text(
                                        day,
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 15),
                          _buildCustomCalendarGrid(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- ⏰ เลือกเวลา ---
                    const Text(
                      'Select Time',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
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
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          (_timeTab == 0 ? _morningSlots : _afternoonSlots).map(
                            (time) {
                              bool isBooked = _bookedTimeSlots.contains(time);
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
                                      3,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isBooked
                                        ? Colors.grey.shade100
                                        : (isSelected
                                              ? Colors.cyan
                                              : Colors.white),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isBooked
                                          ? Colors.transparent
                                          : (isSelected
                                                ? Colors.cyan
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
                                            : null,
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
                      'Location & Details',
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
                        hintText:
                            'Provide details (e.g. Pump leaking, no pressure, noisy)...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- 📸 อัปโหลดรูปภาพ ---
                    const Text(
                      'Photos (Optional)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _showImagePickerOptions,
                            child: Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(right: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.cyan,
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    color: Colors.cyan,
                                    size: 30,
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Add Photo',
                                    style: TextStyle(
                                      color: Colors.cyan,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ..._selectedImages.asMap().entries.map((entry) {
                            int index = entry.key;
                            File imageFile = entry.value;
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  margin: const EdgeInsets.only(right: 15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    image: DecorationImage(
                                      image: FileImage(imageFile),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -5,
                                  right: 5,
                                  child: GestureDetector(
                                    onTap: () => setState(
                                      () => _selectedImages.removeAt(index),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Provide photos of the water pump, nameplate, or the leak.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
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
                  backgroundColor: Colors.cyan,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Confirm Booking',
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

  // ปฏิทิน
  Widget _buildCustomCalendarGrid() {
    int daysInMonth = DateUtils.getDaysInMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );
    int firstWeekday = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    ).weekday;
    int totalCells = daysInMonth + firstWeekday - 1;
    int rows = (totalCells / 7).ceil();
    int totalGridCells = rows * 7;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 10,
        crossAxisSpacing: 5,
      ),
      itemCount: totalGridCells,
      itemBuilder: (context, index) {
        if (index < firstWeekday - 1 || index >= totalCells)
          return const SizedBox.shrink();
        int day = index - (firstWeekday - 1) + 1;
        DateTime cellDate = DateTime(
          _focusedMonth.year,
          _focusedMonth.month,
          day,
        );
        DateTime now = DateTime.now();
        bool isToday =
            cellDate.year == now.year &&
            cellDate.month == now.month &&
            cellDate.day == now.day;
        bool isSelected =
            cellDate.year == _selectedDate.year &&
            cellDate.month == _selectedDate.month &&
            cellDate.day == _selectedDate.day;
        bool isPast = cellDate.isBefore(DateTime(now.year, now.month, now.day));
        bool isFullyBooked =
            cellDate.year == _fullyBookedDate.year &&
            cellDate.month == _fullyBookedDate.month &&
            cellDate.day == _fullyBookedDate.day;
        bool isDisabled = isPast || isFullyBooked;
        return GestureDetector(
          onTap: isDisabled
              ? null
              : () {
                  setState(() {
                    _selectedDate = cellDate;
                    _selectedTime = null;
                  });
                },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.cyan : Colors.transparent,
              shape: BoxShape.circle,
              border: isToday && !isSelected
                  ? Border.all(color: Colors.cyan, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected || isToday
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : (isDisabled ? Colors.grey.shade300 : Colors.black87),
                  decoration: isFullyBooked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeTab(String title, int index) {
    bool isActive = _timeTab == index;
    return GestureDetector(
      onTap: () => setState(() {
        _timeTab = index;
        _selectedTime = null;
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
