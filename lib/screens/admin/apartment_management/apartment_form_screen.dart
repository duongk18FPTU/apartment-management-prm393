import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/apartment_model.dart';
import '../../../providers/apartment_provider.dart';
import 'widgets/apartment_form_fields.dart';

class ApartmentFormScreen extends StatefulWidget {
  const ApartmentFormScreen({super.key, this.apartment});

  final ApartmentModel? apartment;

  @override
  State<ApartmentFormScreen> createState() => _ApartmentFormScreenState();
}

class _ApartmentFormScreenState extends State<ApartmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _numberController;
  late final TextEditingController _buildingController;
  late final TextEditingController _floorController;
  late final TextEditingController _areaController;
  late ApartmentStatus _status;

  @override
  void initState() {
    super.initState();
    final apartment = widget.apartment;
    _numberController = TextEditingController(text: apartment?.number);
    _buildingController = TextEditingController(
      text: apartment?.building ?? 'Building A',
    );
    _floorController = TextEditingController(text: apartment?.floor.toString());
    _areaController = TextEditingController(text: apartment?.area.toString());
    _status = apartment?.status ?? ApartmentStatus.vacant;
  }

  @override
  void dispose() {
    _numberController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final old = widget.apartment;
    final apartment = ApartmentModel(
      id: old?.id ?? '',
      number: _numberController.text.trim(),
      floor: int.parse(_floorController.text),
      building: _buildingController.text.trim(),
      area: double.parse(_areaController.text),
      ownerId: old?.ownerId,
      status: _status,
      residentIds: old?.residentIds ?? const [],
      createdAt: old?.createdAt,
      updatedAt: old?.updatedAt,
    );
    try {
      await context.read<ApartmentProvider>().save(apartment);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to save apartment.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<ApartmentProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.apartment == null ? 'Add apartment' : 'Edit apartment',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            ApartmentFormFields(
              numberController: _numberController,
              buildingController: _buildingController,
              floorController: _floorController,
              areaController: _areaController,
              status: _status,
              onStatusChanged: (value) =>
                  setState(() => _status = value ?? _status),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: loading ? null : _submit,
              child: Text(loading ? 'Saving…' : 'Save apartment'),
            ),
          ],
        ),
      ),
    );
  }
}
