import 'package:flutter/material.dart';

import '../../../../providers/apartment_provider.dart';
import 'apartment_dropdown.dart';

class ResidentFormFields extends StatelessWidget {
  const ResidentFormFields({
    super.key,
    required this.idController,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.nationalIdController,
    required this.apartmentProvider,
    required this.apartmentId,
    required this.status,
    required this.onApartmentChanged,
    required this.onStatusChanged,
    required this.idEnabled,
  });

  final TextEditingController idController;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController nationalIdController;
  final ApartmentProvider apartmentProvider;
  final String? apartmentId;
  final String status;
  final ValueChanged<String?> onApartmentChanged;
  final ValueChanged<String?> onStatusChanged;
  final bool idEnabled;

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required.' : null;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          TextFormField(
            controller: idController,
            enabled: idEnabled,
            decoration: const InputDecoration(labelText: 'Firebase user ID'),
            validator: _required,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Full name'),
            validator: _required,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) => value == null || !value.contains('@')
                ? 'Enter a valid email.'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone'),
            validator: _required,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: nationalIdController,
            decoration: const InputDecoration(labelText: 'National ID'),
            validator: _required,
          ),
          const SizedBox(height: 16),
          ApartmentDropdown(
            provider: apartmentProvider,
            value: apartmentId,
            onChanged: onApartmentChanged,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
            ],
            onChanged: onStatusChanged,
          ),
        ],
      );
}
