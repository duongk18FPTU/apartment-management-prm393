import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../models/bill_model.dart';
import '../../../providers/bill_provider.dart';
import '../../../widgets/custom_text_field.dart';

class BillCreateScreen extends StatefulWidget {
  const BillCreateScreen({super.key});

  @override
  State<BillCreateScreen> createState() => _BillCreateScreenState();
}

class _BillCreateScreenState extends State<BillCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apartmentController = TextEditingController();
  final _amountController = TextEditingController();
  final _monthController = TextEditingController(text: '2026-07');

  BillType _selectedType = BillType.service;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 15));

  @override
  void dispose() {
    _apartmentController.dispose();
    _amountController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<BillProvider>();
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    final newBill = BillModel(
      billId: '', // Firebase tự tạo ID
      apartmentId: _apartmentController.text.trim(),
      residentId: '', // Sẽ được hệ thống map tự động
      type: _selectedType,
      amount: amount,
      billingMonth: _monthController.text.trim(),
      dueDate: _dueDate,
      status: 'unpaid',
      createdBy: 'staff_temp_uid', // UID nhân viên đang đăng nhập
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await provider.createNewBill(newBill);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tạo hóa đơn thành công!'),
          backgroundColor: DesignTokens.tertiary,
        ),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Có lỗi xảy ra'),
          backgroundColor: DesignTokens.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isLoading = context.watch<BillProvider>().isLoading;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(title: const Text('Tạo Hóa Đơn Mới')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Mã số căn hộ (Ví dụ: 301)',
                hint: 'Nhập số phòng căn hộ',
                controller: _apartmentController,
                validator: (val) => val == null || val.isEmpty
                    ? 'Vui lòng nhập số phòng'
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),

              Text('Loại hóa đơn', style: textTheme.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              DropdownButtonFormField<BillType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(),
                items: BillType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              const SizedBox(height: AppSpacing.md),

              CustomTextField(
                label: 'Số tiền (VNĐ)',
                hint: 'Ví dụ: 150000',
                controller: _amountController,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Vui lòng nhập số tiền';
                  }
                  if (double.tryParse(val) == null) {
                    return 'Số tiền không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              CustomTextField(
                label: 'Tháng thanh toán (Định dạng YYYY-MM)',
                hint: 'Ví dụ: 2026-07',
                controller: _monthController,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Vui lòng nhập tháng' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              Text('Hạn thanh toán', style: textTheme.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              InkWell(
                onTap: () => _selectDueDate(context),
                borderRadius: AppRadius.borderSm,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: DesignTokens.surface,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy').format(_dueDate),
                        style: textTheme.bodyLarge,
                      ),
                      const Icon(
                        Icons.calendar_month_outlined,
                        color: DesignTokens.neutralVariant,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Tạo Hóa Đơn'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
