import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 🚀 นำเข้า Supabase ของจริง

class AcServiceForm extends StatefulWidget {
  const AcServiceForm({super.key});

  @override
  State<AcServiceForm> createState() => _AcServiceFormState();
}

class _AcServiceFormState extends State<AcServiceForm> {
  // 🚀 ตัวแปรจัดการ Database และสถานะการโหลด
  final _supabase = Supabase.instance.client;
  bool _isLoading = false; // เอาไว้ทำวงแหวนหมุนๆ ตอนกดบันทึก

  // --- 🧠 ตัวแปรเก็บข้อมูล ---
  String _serviceType = 'Cleaning';
  String _acType = 'Wall Mounted';
  String _btuSize = 'Not sure';
  int _acCount = 1;

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  DateTime _focusedMonth = DateTime.now();
  String? _selectedTime;
  int _timeTab = 0;

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
  final List<String> _bookedTimeSlots = ['09:30', '10:00', '14:30', '15:00'];
  final DateTime _fullyBookedDate = DateTime.now().add(const Duration(days: 3));
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

  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];

  @override
  void dispose() {
    _addressController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  // ==========================================
  // 🚀 ฟังก์ชันหลัก: ยิงข้อมูลขึ้น SUPABASE ของจริง!
  // ==========================================
  Future<void> _submitBooking() async {
    // 1. ดักจับก่อนว่ากรอกข้อมูลครบไหม
    if (_selectedTime == null || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select time and enter your address.'),
        ),
      );
      return;
    }

    // 2. เช็คว่ามีคน Login อยู่ไหม (เพื่อเอา ID ไปผูกกับบิลการจอง)
    final user = _supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not logged in!')),
      );
      return;
    }

    setState(() => _isLoading = true); // เริ่มโหลดวงแหวนหมุนๆ

    try {
      List<String> uploadedImageUrls = [];

      // 3. 📸 อัปโหลดรูปภาพทีละรูป (ถ้าลูกค้าแนบมา)
      for (File image in _selectedImages) {
        final fileExt = image.path.split('.').last;
        // สร้างชื่อไฟล์ไม่ให้ซ้ำกัน (ใช้เวลาปัจจุบัน + ID ลูกค้า)
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${user.id}.$fileExt';
        final filePath = 'ac_service/$fileName'; // สร้างโฟลเดอร์ย่อยในถัง

        // อัปโหลดขึ้น Storage ถัง booking_images
        await _supabase.storage.from('booking_images').upload(filePath, image);

        // เอาลิงก์รูป (Public URL) มาเก็บไว้
        final publicUrl = _supabase.storage
            .from('booking_images')
            .getPublicUrl(filePath);
        uploadedImageUrls.add(publicUrl);
      }

      // 4. 📦 แพ็คข้อมูลเฉพาะของแอร์ (ใส่กล่อง JSONB)
      final specificDetails = {
        'ac_type': _acType,
        'btu_size': _btuSize,
        'ac_count': _acCount,
      };

      // 5. 💾 ยิงข้อมูลทั้งหมดลง Database ตาราง bookings!
      await _supabase.from('bookings').insert({
        'customer_id': user.id,
        'service_category': 'AC Service',
        'service_type': _serviceType,
        'booking_date': _selectedDate.toIso8601String().split(
          'T',
        )[0], // เอาแค่วันที่ YYYY-MM-DD
        'booking_time': _selectedTime,
        'address': _addressController.text,
        'issue_description': _detailsController.text,
        'specific_details': specificDetails, // โยนกล่อง JSONB ลงไปเลย!
        'image_urls': uploadedImageUrls,
      });

      // 6. สำเร็จ! แจ้งเตือนและเด้งกลับหน้าโฮม
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Booking Successful! 🎉',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
      Navigator.pop(context); // ปิดหน้าฟอร์ม กลับไปหน้าหลัก
    } catch (e) {
      // ถ้ามี Error ให้โชว์บอก
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false); // หยุดโหลด
    }
  }

  // ==========================================
  // 📸 ฟังก์ชันรูปภาพ (โค้ดเดิม)
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
                leading: const Icon(Icons.camera_alt, color: Colors.blueAccent),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Colors.blueAccent,
                ),
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
  // 🗓️ ป๊อปอัปเลือกเดือนและปี (โค้ดเดิม)
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
                      color: isSelected
                          ? Colors.blueAccent
                          : Colors.grey.shade100,
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
          'Book AC Service',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      // 🚀 ใช้ Stack เพื่อให้เวลากดโหลดแล้วหน้าจอคลิกไม่ได้
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                onChanged: (val) =>
                                    setState(() => _acType = val!),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
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

                        const SizedBox(height: 15),
                        // 🔽 กล่องเลือก BTU ที่หายไป! ใส่ตรงนี้เลยครับ
                        DropdownButtonFormField<String>(
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
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(
                                    type,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) => setState(() => _btuSize = val!),
                        ),
                        const SizedBox(height: 30),

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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children:
                                    ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
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
                              (_timeTab == 0 ? _morningSlots : _afternoonSlots)
                                  .map((time) {
                                    bool isBooked = _bookedTimeSlots.contains(
                                      time,
                                    );
                                    bool isSelected = _selectedTime == time;
                                    return GestureDetector(
                                      onTap: isBooked
                                          ? null
                                          : () => setState(
                                              () => _selectedTime = time,
                                            ),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        width:
                                            (MediaQuery.of(context).size.width -
                                                64) /
                                            3,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isBooked
                                              ? Colors.grey.shade100
                                              : (isSelected
                                                    ? Colors.blueAccent
                                                    : Colors.white),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  })
                                  .toList(),
                        ),
                        const SizedBox(height: 30),

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
                            hintText: 'Any specific issues?',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

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
                                      color: Colors.blueAccent,
                                      width: 2,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo,
                                        color: Colors.blueAccent,
                                        size: 30,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Add Photo',
                                        style: TextStyle(
                                          color: Colors.blueAccent,
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
                          'Help technicians by providing photos.',
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
                    onPressed: _isLoading
                        ? null
                        : _submitBooking, // ถ้ากำลังโหลด ให้ปิดปุ่มกด
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    // โชว์วงแหวนโหลด ถ้า _isLoading เป็น true
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
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

          // 🛡️ ฉากกั้นสีดำจางๆ กันคนมือลั่นกดอย่างอื่นตอนระบบกำลังโหลด
          if (_isLoading) Container(color: Colors.black.withOpacity(0.3)),
        ],
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
              color: isSelected ? Colors.blueAccent : Colors.transparent,
              shape: BoxShape.circle,
              border: isToday && !isSelected
                  ? Border.all(color: Colors.blueAccent, width: 2)
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
