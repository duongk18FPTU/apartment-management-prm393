import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/complaint_provider.dart';
import '../../../utils/validators.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/loading_indicator.dart';

/// Resident — submit a new complaint / feedback.
class ComplaintCreateScreen extends StatefulWidget {
  const ComplaintCreateScreen({super.key});

  @override
  State<ComplaintCreateScreen> createState() => _ComplaintCreateScreenState();
}

class _ComplaintCreateScreenState extends State<ComplaintCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
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

    final provider = context.read<ComplaintProvider>();
    final ok = await provider.createComplaint(
      content: _contentController.text,
      residentId: user.uid,
      apartmentId: apartmentId,
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi khiếu nại / góp ý')),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Gửi thất bại'),
          backgroundColor: DesignTokens.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<ComplaintProvider>().isSubmitting;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(title: const Text('Gửi khiếu nại / góp ý')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text(
                'Mô tả vấn đề hoặc góp ý của bạn. Ban quản lý sẽ phản hồi sớm nhất có thể.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: DesignTokens.neutralVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                label: 'Nội dung',
                hint: 'Ví dụ: Tiếng ồn vào ban đêm ở hành lang tầng 3...',
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
                      : const Text('Gửi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
