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
            ParcelEvidenceGallery(
              photos: current.photos,
              languageCode: widget.languageCode,
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

class ParcelEvidenceGallery extends StatelessWidget {
  const ParcelEvidenceGallery({
    super.key,
    required this.photos,
    required this.languageCode,
  });

  final List<ParcelPhotoSummary> photos;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('parcel_evidence_gallery'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t(languageCode, 'หลักฐาน', 'ຫຼັກຖານ'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 620 ? 3 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: photos.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) => ParcelEvidenceTile(
                photo: photos[index],
                languageCode: languageCode,
              ),
            );
          },
        ),
      ],
    );
  }
}

class ParcelEvidenceTile extends StatelessWidget {
  const ParcelEvidenceTile({
    super.key,
    required this.photo,
    required this.languageCode,
  });

  final ParcelPhotoSummary photo;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final title = photo.type == 'SIGNATURE'
        ? t(languageCode, 'ลายเซ็น', 'ລາຍເຊັນ')
        : t(languageCode, 'รูปถ่าย', 'ຮູບຖ່າຍ');
    return InkWell(
      key: ValueKey('parcel_evidence_${photo.id}'),
      borderRadius: BorderRadius.circular(8),
      onTap: () => showDialog<void>(
        context: context,
        builder: (context) =>
            ParcelEvidencePreview(photo: photo, languageCode: languageCode),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: ParcelEvidenceImage(photo: photo)),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        photo.type == 'SIGNATURE'
                            ? Icons.draw
                            : Icons.photo_camera,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  EvidenceMeta(photo: photo),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ParcelEvidenceImage extends StatelessWidget {
  const ParcelEvidenceImage({super.key, required this.photo});

  final ParcelPhotoSummary photo;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Image.network(
        photo.url,
        fit: BoxFit.cover,
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
        errorBuilder: (context, error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              photo.type == 'SIGNATURE'
                  ? Icons.draw_outlined
                  : Icons.broken_image_outlined,
              color: Theme.of(context).colorScheme.outline,
              size: 34,
            ),
          ),
        ),
      ),
    );
  }
}

class EvidenceMeta extends StatelessWidget {
  const EvidenceMeta({super.key, required this.photo});

  final ParcelPhotoSummary photo;

  @override
  Widget build(BuildContext context) {
    final lines = [
      if (photo.capturedAt != null) photo.capturedAt!.toLocal().toString(),
      if (photo.addressText?.trim().isNotEmpty == true) photo.addressText!,
    ];
    if (lines.isEmpty) {
      return const SizedBox(height: 18);
    }
    return Text(
      lines.join('\n'),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

class ParcelEvidencePreview extends StatelessWidget {
  const ParcelEvidencePreview({
    super.key,
    required this.photo,
    required this.languageCode,
  });

  final ParcelPhotoSummary photo;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final title = photo.type == 'SIGNATURE'
        ? t(languageCode, 'ลายเซ็น', 'ລາຍເຊັນ')
        : t(languageCode, 'รูปถ่าย', 'ຮູບຖ່າຍ');
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            IconButton(
              tooltip: t(languageCode, 'ปิด', 'ປິດ'),
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Image.network(
                  photo.url,
                  fit: BoxFit.contain,
                  webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                  errorBuilder: (context, error, stackTrace) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: SelectableText(photo.url),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            EvidenceMeta(photo: photo),
          ],
        ),
      ),
    );
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
