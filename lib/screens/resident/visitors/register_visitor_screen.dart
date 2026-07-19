import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/visitor_provider.dart';
import '../../../utils/vietnamese_formatters.dart';

class RegisterVisitorScreen extends StatefulWidget {
  const RegisterVisitorScreen({super.key});

  @override
  State<RegisterVisitorScreen> createState() => _RegisterVisitorScreenState();
}

class _RegisterVisitorScreenState extends State<RegisterVisitorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedPurpose;
  DateTime? _expectedDateTime;
  bool _isLoading = false;

  final List<String> _purposes = [
    'Gặp người thân',
    'Giao hàng',
    'Kỹ thuật sửa chữa',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF091426),
              onPrimary: Colors.white,
              onSurface: Color(0xFF091426),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF091426),
                onPrimary: Colors.white,
                onSurface: Color(0xFF091426),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _expectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_expectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn thời gian dự kiến đến!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthProvider>();
      final user = auth.userModel;
      if (user == null) throw Exception('User not logged in');

      final apartmentId = user.apartmentId;
      if (apartmentId == null || apartmentId.isEmpty) {
        throw Exception('Tài khoản chưa được gán căn hộ');
      }

      final provider = context.read<VisitorProvider>();
      final ok = await provider.registerVisitor(
        visitorName: _nameController.text.trim(),
        visitorPhone: _phoneController.text.trim(),
        purpose: _selectedPurpose ?? 'Gặp người thân',
        registeredBy: user.uid,
        apartmentId: apartmentId,
        expectedTime: _expectedDateTime!,
      );

      if (!mounted) return;

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký khách thành công!'),
            backgroundColor: Color(0xFF0D9488),
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Đăng ký thất bại'),
            backgroundColor: const Color(0xFFBA1A1A),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng ký thất bại: $e'),
            backgroundColor: const Color(0xFFBA1A1A),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF091426)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Đăng ký khách',
          style: TextStyle(
            color: Color(0xFF091426),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero lobby banner image
              Container(
                height: 180,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1540518614846-7eded433c457?auto=format&fit=crop&w=1200&q=80',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  padding: const EdgeInsets.all(20.0),
                  alignment: Alignment.bottomLeft,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin khách',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Vui lòng điền thông tin chính xác để check-in tại cổng an ninh.',
                        style: TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Input Name
                      const Text(
                        'HỌ TÊN KHÁCH',
                        style: TextStyle(
                          color: Color(0xFF75777D),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(
                          color: Color(0xFF091426),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Nguyễn Văn A',
                          hintStyle: const TextStyle(color: Color(0xFF75777D)),
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: Color(0xFF75777D),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF091426),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên khách';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Input Phone
                      const Text(
                        'SĐT KHÁCH',
                        style: TextStyle(
                          color: Color(0xFF75777D),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                          color: Color(0xFF091426),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: '090 000 0000',
                          hintStyle: const TextStyle(color: Color(0xFF75777D)),
                          prefixIcon: const Icon(
                            Icons.call_outlined,
                            color: Color(0xFF75777D),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF091426),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập số điện thoại';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Input Purpose
                      const Text(
                        'MỤC ĐÍCH',
                        style: TextStyle(
                          color: Color(0xFF75777D),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedPurpose,
                        style: const TextStyle(
                          color: Color(0xFF091426),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Chọn mục đích',
                          hintStyle: const TextStyle(color: Color(0xFF75777D)),
                          prefixIcon: const Icon(
                            Icons.assignment_ind_outlined,
                            color: Color(0xFF75777D),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF091426),
                            ),
                          ),
                        ),
                        items: _purposes.map((p) {
                          return DropdownMenuItem<String>(
                            value: p,
                            child: Text(p),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedPurpose = val;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Vui lòng chọn mục đích';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Expected Arrival Time
                      const Text(
                        'THỜI GIAN DỰ KIẾN ĐẾN',
                        style: TextStyle(
                          color: Color(0xFF75777D),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectDateTime,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                color: Color(0xFF75777D),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _expectedDateTime != null
                                      ? VietnameseFormatters.dateTime.format(
                                          _expectedDateTime!,
                                        )
                                      : 'Chọn ngày giờ dự kiến đến',
                                  style: TextStyle(
                                    color: _expectedDateTime != null
                                        ? const Color(0xFF091426)
                                        : const Color(0xFF75777D),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down_rounded,
                                color: Color(0xFF75777D),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Warning Footer
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFFD97706),
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Lưu ý: Khách cần mang theo CMND/CCCD để đối chiếu khi check-in tại quầy bảo vệ.',
                                style: TextStyle(
                                  color: Color(0xFFB45309),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Register Button
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF091426),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Xác nhận đăng ký',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.chevron_right_rounded, size: 20),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
