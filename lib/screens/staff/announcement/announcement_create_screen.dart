import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../models/notification_model.dart';
import '../../../providers/announcement_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/validators.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/loading_indicator.dart';
import 'widgets/announcement_metadata_fields.dart';

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
  AnnouncementType _selectedType = AnnouncementType.general;
  final Set<UserRole> _selectedRoles = Set.of(UserRole.values);
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
          _selectedType = AnnouncementType.fromValue(item.type);
          _selectedRoles
            ..clear()
            ..addAll(
              UserRole.values.where(
                (role) => item.targetRoles.contains(role.name),
              ),
            );
          if (_selectedRoles.isEmpty) {
            _selectedRoles.addAll(UserRole.values);
          }
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
    if (_selectedRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một đối tượng nhận.'),
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final provider = context.read<AnnouncementProvider>();
    final bool ok;
    final targetRoles = _selectedRoles
        .map((role) => role.name)
        .toList(growable: false);

    if (widget.isEditing) {
      ok = await provider.updateAnnouncement(
        id: widget.editId!,
        title: _titleController.text,
        content: _contentController.text,
        type: _selectedType.value,
        targetRoles: targetRoles,
      );
    } else {
      ok = await provider.createAnnouncement(
        title: _titleController.text,
        content: _contentController.text,
        createdBy: auth.userModel?.uid ?? '',
        type: _selectedType.value,
        targetRoles: targetRoles,
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
                'Chọn loại thông báo và các vai trò được phép nhận thông báo.',
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
              const SizedBox(height: AppSpacing.md),
              AnnouncementMetadataFields(
                selectedType: _selectedType,
                selectedRoles: _selectedRoles,
                onTypeChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
                onRoleToggled: (role) {
                  setState(() {
                    if (_selectedRoles.contains(role)) {
                      _selectedRoles.remove(role);
                    } else {
                      _selectedRoles.add(role);
                    }
                  });
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submit,
                  child: isSubmitting
                      ? const LoadingIndicator.circular(size: 24)
                      : Text(
                          widget.isEditing ? 'Lưu thay đổi' : 'Đăng thông báo',
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
