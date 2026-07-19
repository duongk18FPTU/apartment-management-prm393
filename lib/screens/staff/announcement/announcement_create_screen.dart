import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../providers/announcement_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/validators.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/loading_indicator.dart';

/// Admin/Staff — create or edit an announcement.
class AnnouncementCreateScreen extends StatefulWidget {
  const AnnouncementCreateScreen({super.key, this.editId});

  final String? editId;

  bool get isEditing => editId != null && editId!.isNotEmpty;

  @override
  State<AnnouncementCreateScreen> createState() =>
      _AnnouncementCreateScreenState();
}

class _AnnouncementCreateScreenState extends State<AnnouncementCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final provider = context.read<AnnouncementProvider>();
        await provider.loadDetail(widget.editId!);
        if (!mounted) return;
        final item = provider.selected;
        if (item != null && !_prefilled) {
          _titleController.text = item.title;
          _contentController.text = item.content;
          _prefilled = true;
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final provider = context.read<AnnouncementProvider>();
    final bool ok;

    if (widget.isEditing) {
      ok = await provider.updateAnnouncement(
        id: widget.editId!,
        title: _titleController.text,
        content: _contentController.text,
      );
    } else {
      ok = await provider.createAnnouncement(
        title: _titleController.text,
        content: _contentController.text,
        createdBy: auth.userModel?.uid ?? '',
      );
    }

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing ? 'Đã cập nhật thông báo' : 'Đã tạo thông báo',
          ),
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Thao tác thất bại'),
          backgroundColor: DesignTokens.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<AnnouncementProvider>().isSubmitting;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Sửa thông báo' : 'Tạo thông báo'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text(
                'Thông báo sẽ hiển thị cho cư dân, nhân viên và quản trị (theo targetRoles mặc định).',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: DesignTokens.neutralVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                label: 'Tiêu đề',
                hint: 'Ví dụ: Họp cư dân tháng 8',
                controller: _titleController,
                validator: (v) =>
                    AppValidators.validateRequired(v, fieldName: 'Tiêu đề'),
                prefixIcon: Icons.title_rounded,
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                label: 'Nội dung',
                hint: 'Nội dung thông báo chi tiết...',
                controller: _contentController,
                maxLines: 8,
                validator: (v) =>
                    AppValidators.validateRequired(v, fieldName: 'Nội dung'),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submit,
                  child: isSubmitting
                      ? const LoadingIndicator.circular(size: 24)
                      : Text(widget.isEditing ? 'Lưu thay đổi' : 'Đăng thông báo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
