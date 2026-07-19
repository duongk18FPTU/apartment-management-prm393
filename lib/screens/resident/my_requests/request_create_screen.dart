import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../models/request_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/request_provider.dart';
import '../../../utils/validators.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/loading_indicator.dart';

/// Resident — create a new maintenance request (title, description, category, photos).
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().userModel;
    if (user == null) return;

    final apartmentId = user.apartmentId;
    if (apartmentId == null || apartmentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tài khoản chưa được gán căn hộ. Liên hệ Ban quản lý.'),
        ),
      );
      return;
    }

    final provider = context.read<RequestProvider>();
    final ok = await provider.createRequest(
      title: _titleController.text,
      description: _descriptionController.text,
      category: _category,
      residentId: user.uid,
      apartmentId: apartmentId,
      imageFiles: _images.map((x) => File(x.path)).toList(),
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi yêu cầu thành công')),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Gửi yêu cầu thất bại'),
          backgroundColor: DesignTokens.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<RequestProvider>().isSubmitting;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(title: const Text('Gửi yêu cầu sửa chữa')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              CustomTextField(
                label: 'Tiêu đề',
                hint: 'Ví dụ: Vòi nước bị rò rỉ',
                controller: _titleController,
                validator: (v) =>
                    AppValidators.validateRequired(v, fieldName: 'Tiêu đề'),
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.title_rounded,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Loại sự cố', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: RequestCategory.values.map((c) {
                  final selected = _category == c;
                  return ChoiceChip(
                    label: Text(c.label),
                    selected: selected,
                    onSelected: (_) => setState(() => _category = c),
                    selectedColor: DesignTokens.secondaryContainer,
                    labelStyle: TextStyle(
                      color: selected
                          ? DesignTokens.secondary
                          : DesignTokens.onSurface,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                label: 'Mô tả chi tiết',
                hint: 'Mô tả vị trí và tình trạng sự cố...',
                controller: _descriptionController,
                validator: (v) =>
                    AppValidators.validateRequired(v, fieldName: 'Mô tả'),
                maxLines: 5,
                prefixIcon: Icons.description_outlined,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Ảnh đính kèm (tối đa 3)',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: isSubmitting ? null : _pickImages,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(
                  _images.isEmpty
                      ? 'Chọn ảnh từ thư viện'
                      : 'Đã chọn ${_images.length} ảnh',
                ),
              ),
              if (_images.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 88,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: Image.file(
                          File(_images[index].path),
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submit,
                  child: isSubmitting
                      ? const LoadingIndicator.circular(size: 24)
                      : const Text('Gửi yêu cầu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
