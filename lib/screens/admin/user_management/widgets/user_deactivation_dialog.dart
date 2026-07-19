import 'package:flutter/material.dart';

Future<bool> confirmUserDeactivation(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Vô hiệu hóa tài khoản?'),
      content: const Text(
        'Người dùng sẽ không thể truy cập ứng dụng cho đến khi được kích hoạt lại.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Vô hiệu hóa'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
