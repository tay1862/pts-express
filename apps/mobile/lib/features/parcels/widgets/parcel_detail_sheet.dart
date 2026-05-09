import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_client.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/models/parcel_models.dart';
import '../../../core/models/parcel_status.dart';

class ParcelDetailSheet extends StatefulWidget {
  const ParcelDetailSheet({
    super.key,
    required this.parcel,
    required this.languageCode,
    required this.isAdmin,
  });

  final ParcelSummary parcel;
  final String languageCode;
  final bool isAdmin;

  @override
  State<ParcelDetailSheet> createState() => ParcelDetailSheetState();
}

class ParcelDetailSheetState extends State<ParcelDetailSheet> {
  ParcelSummary? parcel;
  final reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    parcel = widget.parcel;
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = parcel!;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      maxChildSize: 0.95,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            current.trackingCode,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(current.status.label(widget.languageCode)),
          const SizedBox(height: 16),
          Text(
            '${t(widget.languageCode, 'ลูกค้า', 'ລູກຄ້າ')}: ${current.customerName}',
          ),
          if (current.customerPhone?.isNotEmpty == true)
            Text(
              '${t(widget.languageCode, 'เบอร์โทร', 'ເບີໂທ')}: ${current.customerPhone}',
            ),
          if (current.note?.isNotEmpty == true)
            Text(
              '${t(widget.languageCode, 'หมายเหตุ', 'ໝາຍເຫດ')}: ${current.note}',
            ),
          if (current.photos.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              t(widget.languageCode, 'หลักฐาน', 'ຫຼັກຖານ'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final photo in current.photos)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  photo.type == 'SIGNATURE' ? Icons.draw : Icons.photo_camera,
                ),
                title: Text(
                  photo.type == 'SIGNATURE'
                      ? t(widget.languageCode, 'ลายเซ็น', 'ລາຍເຊັນ')
                      : t(widget.languageCode, 'รูปถ่าย', 'ຮູບຖ່າຍ'),
                ),
                subtitle: Text(
                  [
                    if (photo.capturedAt != null)
                      photo.capturedAt!.toLocal().toString(),
                    if (photo.addressText?.isNotEmpty == true)
                      photo.addressText!,
                  ].join('\n'),
                ),
              ),
          ],
          const Divider(height: 32),
          for (final event in current.events)
            ListTile(
              dense: true,
              leading: const Icon(Icons.check_circle_outline),
              title: Text(
                event.toStatus?.label(widget.languageCode) ?? event.eventType,
              ),
              subtitle: Text(event.happenedAt.toLocal().toString()),
            ),
          if (widget.isAdmin)
            AdminOverridePanel(
              languageCode: widget.languageCode,
              reasonController: reasonController,
              onOverride: overrideStatus,
            ),
        ],
      ),
    );
  }

  Future<void> overrideStatus(ParcelStatus status) async {
    final apiClient = context.read<ApiClient>();
    final updated = await apiClient.overrideStatus(
      parcel!.id,
      status,
      reasonController.text,
    );
    setState(() => parcel = updated);
  }
}

class AdminOverridePanel extends StatelessWidget {
  const AdminOverridePanel({
    super.key,
    required this.languageCode,
    required this.reasonController,
    required this.onOverride,
  });

  final String languageCode;
  final TextEditingController reasonController;
  final ValueChanged<ParcelStatus> onOverride;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t(languageCode, 'แก้สถานะโดยผู้ดูแล', 'ຜູ້ດູແລແກ້ສະຖານະ'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              key: const ValueKey('override_reason_field'),
              controller: reasonController,
              decoration: InputDecoration(
                labelText: t(languageCode, 'เหตุผล', 'ເຫດຜົນ'),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final status in ParcelStatus.values)
                  ActionChip(
                    label: Text(status.apiValue),
                    onPressed: () => onOverride(status),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
