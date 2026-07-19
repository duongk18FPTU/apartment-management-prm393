import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/user_model.dart';
import '../../../utils/constants.dart';
import '../../../providers/apartment_provider.dart';
import '../../../providers/resident_provider.dart';
import 'widgets/resident_form_fields.dart';

class ResidentFormScreen extends StatefulWidget {
  const ResidentFormScreen({super.key, this.resident});

  final UserModel? resident;

  @override
  State<ResidentFormScreen> createState() => _ResidentFormScreenState();
}

class _ResidentFormScreenState extends State<ResidentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _idController;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _nationalIdController;
  String _status = 'active';
  String? _selectedApartmentId;

  @override
  void initState() {
    super.initState();
    final resident = widget.resident;
    _idController = TextEditingController(text: resident?.id);
    _nameController = TextEditingController(text: resident?.fullName);
    _emailController = TextEditingController(text: resident?.email);
    _phoneController = TextEditingController(text: resident?.phone);
    _nationalIdController = TextEditingController(text: resident?.nationalId);
    _status = resident?.status.name ?? 'active';
    _selectedApartmentId = resident?.apartmentId;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ApartmentProvider>().loadApartments(),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final old = widget.resident;
    final oldApartmentId = old?.apartmentId;
    final resident = UserModel(
      uid: _idController.text.trim(),
      email: _emailController.text.trim(),
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      role: UserRole.resident,
      apartmentId: oldApartmentId,
      nationalId: _nationalIdController.text.trim(),
      dateOfBirth: old?.dateOfBirth,
      avatarUrl: old?.avatarUrl,
      status: UserStatus.values.byName(_status),
      createdAt: old?.createdAt ?? DateTime.now(),
      updatedAt: old?.updatedAt ?? DateTime.now(),
    );
    try {
      await _saveResident(resident);
      await _syncApartment(oldApartmentId, resident.id);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to save resident profile.')),
        );
    }
  }

  Future<void> _saveResident(UserModel resident) {
    final provider = context.read<ResidentProvider>();
    return widget.resident == null
        ? provider.create(resident)
        : provider.save(resident);
  }

  Future<void> _syncApartment(String? oldApartmentId, String residentId) async {
    if (oldApartmentId == _selectedApartmentId) return;
    final provider = context.read<ApartmentProvider>();
    if (_selectedApartmentId == null && oldApartmentId != null) {
      await provider.unassignResident(
        apartmentId: oldApartmentId,
        residentId: residentId,
      );
    } else if (_selectedApartmentId != null) {
      await provider.assignResident(
        apartmentId: _selectedApartmentId!,
        residentId: residentId,
        asOwner: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final apartments = context.watch<ApartmentProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.resident == null ? 'Add resident' : 'Edit resident'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            ResidentFormFields(
              idController: _idController,
              nameController: _nameController,
              emailController: _emailController,
              phoneController: _phoneController,
              nationalIdController: _nationalIdController,
              apartmentProvider: apartments,
              apartmentId: _selectedApartmentId,
              status: _status,
              idEnabled: widget.resident == null,
              onApartmentChanged: (value) =>
                  setState(() => _selectedApartmentId = value),
              onStatusChanged: (value) =>
                  setState(() => _status = value ?? _status),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: apartments.isLoading ? null : _submit,
              child: Text(
                widget.resident == null ? 'Create profile' : 'Save changes',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
