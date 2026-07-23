import 'package:flutter/material.dart';

import '../../../../models/notification_model.dart';
import '../../../../utils/constants.dart';

class AnnouncementMetadataFields extends StatelessWidget {
  const AnnouncementMetadataFields({
    super.key,
    required this.selectedType,
    required this.selectedRoles,
    required this.onTypeChanged,
    required this.onRoleToggled,
  });

  final AnnouncementType selectedType;
  final Set<UserRole> selectedRoles;
  final ValueChanged<AnnouncementType?> onTypeChanged;
  final ValueChanged<UserRole> onRoleToggled;

  String _roleLabel(UserRole role) {
    return switch (role) {
      UserRole.admin => 'Admin',
      UserRole.staff => 'Staff',
      UserRole.resident => 'Resident',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<AnnouncementType>(
          initialValue: selectedType,
          decoration: const InputDecoration(
            labelText: 'Loại thông báo',
            prefixIcon: Icon(Icons.category_outlined),
          ),
          items: AnnouncementType.values
              .map(
                (type) =>
                    DropdownMenuItem(value: type, child: Text(type.label)),
              )
              .toList(growable: false),
          onChanged: onTypeChanged,
        ),
        const SizedBox(height: 16),
        Text('Đối tượng nhận', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: UserRole.values
              .map(
                (role) => FilterChip(
                  label: Text(_roleLabel(role)),
                  selected: selectedRoles.contains(role),
                  onSelected: (_) => onRoleToggled(role),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}
