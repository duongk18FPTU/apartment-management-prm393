import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../models/request_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/request_provider.dart';
import '../../../utils/validators.dart';

class RequestCreateScreen extends StatefulWidget {
  const RequestCreateScreen({super.key});

  @override
  State<RequestCreateScreen> createState() => _RequestCreateScreenState();
}

class _RequestCreateScreenState extends State<RequestCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();

  RequestCategory _category = RequestCategory.general;
  final List<XFile> _images = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 75);
    if (picked.isEmpty) return;
    setState(() {
      _images
        ..clear()
        ..addAll(picked.take(3));
    });
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().userModel;
    if (user == null) return;

    final apartmentId = user.apartmentId;
    if (apartmentId == null || apartmentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tài khoản chưa được gán căn hộ. Liên hệ Ban quản lý.'),
          backgroundColor: Color(0xFFBA1A1A),
        ),
      );
      return;
    }

    final provider = context.read<RequestProvider>();
    final ok = await provider.createRequest(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      residentId: user.uid,
      apartmentId: apartmentId,
      imageFiles: _images.map((x) => File(x.path)).toList(),
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi yêu cầu thành công'),
          backgroundColor: Color(0xFF0D9488),
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Gửi yêu cầu thất bại'),
          backgroundColor: const Color(0xFFBA1A1A),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<RequestProvider>().isSubmitting;

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
          'Gửi yêu cầu sửa chữa',
          style: TextStyle(
            color: Color(0xFF091426),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Form Label: Tiêu đề
                      const Text(
                        'TIÊU ĐỀ',
                        style: TextStyle(
                          color: Color(0xFF75777D),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(
                          color: Color(0xFF091426),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ví dụ: Vòi nước bị rò rỉ',
                          hintStyle: const TextStyle(
                            color: Color(0xFF75777D),
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.title_rounded,
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
                        validator: (v) => AppValidators.validateRequired(
                          v,
                          fieldName: 'Tiêu đề',
                        ),
                        textInputAction: TextInputAction.next,
                      ),

                      const SizedBox(height: 24),

                      // Form Label: Loại sự cố
                      const Text(
                        'LOẠI SỰ CỐ',
                        style: TextStyle(
                          color: Color(0xFF75777D),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: RequestCategory.values.map((c) {
                          final selected = _category == c;
                          return ChoiceChip(
                            label: Text(c.label),
                            selected: selected,
                            selectedColor: const Color(0xFF091426),
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF45474C),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: selected
                                    ? const Color(0xFF091426)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            onSelected: (_) => setState(() => _category = c),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Form Label: Mô tả chi tiết
                      const Text(
                        'MÔ TẢ CHI TIẾT',
                        style: TextStyle(
                          color: Color(0xFF75777D),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        style: const TextStyle(
                          color: Color(0xFF091426),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Mô tả vị trí và tình trạng sự cố...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF75777D),
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.description_outlined,
                            color: Color(0xFF75777D),
                          ),
                          filled: true,
                          fillColor: Colors.white,
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
                        validator: (v) => AppValidators.validateRequired(
                          v,
                          fieldName: 'Mô tả',
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Form Label: Ảnh đính kèm
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ẢNH ĐÍNH KÈM (TỐI ĐA 3)',
                            style: TextStyle(
                              color: Color(0xFF75777D),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            '${_images.length}/3',
                            style: const TextStyle(
                              color: Color(0xFF75777D),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: isSubmitting || _images.length >= 3
                            ? null
                            : _pickImages,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: Text(
                          _images.isEmpty
                              ? 'Chọn ảnh từ thư viện'
                              : 'Chọn thêm ảnh từ thư viện',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF091426),
                          side: const BorderSide(
                            color: Color(0xFF091426),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),

                      // Chosen images list preview with a remove option
                      if (_images.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 80,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _images.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(_images[index].path),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom submit button action bar
              Container(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 24.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  ),
                ),
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF091426),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Gửi yêu cầu',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
