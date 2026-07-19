import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/custom_text_field.dart';

class ResidentProfileScreen extends StatefulWidget {
  const ResidentProfileScreen({super.key});

  @override
  State<ResidentProfileScreen> createState() => _ResidentProfileScreenState();
}

class _ResidentProfileScreenState extends State<ResidentProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _emailController = TextEditingController();

  DateTime? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  void _loadCurrentProfile() {
    final user = context.read<AuthProvider>().userModel;
    if (user != null) {
      _nameController.text = user.fullName;
      _phoneController.text = user.phone;
      _nationalIdController.text = user.nationalId;
      _emailController.text = user.email;
      _dateOfBirth = user.dateOfBirth;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(1995, 1, 1),
      firstDate: DateTime(1950, 1, 1),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.userModel;
    if (user == null) return;

    final updatedUser = user.copyWith(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      nationalId: _nationalIdController.text.trim(),
      dateOfBirth: _dateOfBirth,
    );

    final success = await authProvider.updateProfile(updatedUser);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lưu thông tin cá nhân thành công!'),
          backgroundColor: DesignTokens.tertiary,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Gặp sự cố khi lưu thông tin',
          ),
          backgroundColor: DesignTokens.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Thông Tin Cá Nhân'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: DesignTokens.secondary.withValues(
                        alpha: 0.1,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: DesignTokens.secondary,
                        size: 50,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: const BoxDecoration(
                          color: DesignTokens.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Form fields
              CustomTextField(
                label: 'Họ và tên',
                hint: 'Nhập họ tên đầy đủ',
                controller: _nameController,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              CustomTextField(
                label: 'Số điện thoại',
                hint: 'Nhập số điện thoại',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              CustomTextField(
                label: 'Số CCCD/CMND',
                hint: 'Nhập số CMND/CCCD',
                controller: _nationalIdController,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Vui lòng nhập số CCCD/CMND';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              Text('Ngày sinh', style: textTheme.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              InkWell(
                onTap: () => _selectDateOfBirth(context),
                borderRadius: AppRadius.borderSm,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: DesignTokens.surface,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _dateOfBirth == null
                            ? 'Chọn ngày sinh'
                            : DateFormat('dd/MM/yyyy').format(_dateOfBirth!),
                        style: textTheme.bodyLarge,
                      ),
                      const Icon(
                        Icons.cake_outlined,
                        color: DesignTokens.neutralVariant,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              CustomTextField(
                label: 'Email (Chỉ xem)',
                controller: _emailController,
                readOnly: true,
                enabled: false,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Save button
              ElevatedButton(
                onPressed: authProvider.isLoading ? null : _submit,
                child: authProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('LƯU THAY ĐỔI'),
              ),
              const SizedBox(height: AppSpacing.md),

              // Logout Button
              OutlinedButton.icon(
                onPressed: () => authProvider.logout(),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('ĐĂNG XUẤT TÀI KHOẢN'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DesignTokens.error,
                  side: const BorderSide(color: DesignTokens.error, width: 1.5),
                  minimumSize: const Size(double.infinity, 52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
