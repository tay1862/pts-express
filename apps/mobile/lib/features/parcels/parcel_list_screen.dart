import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/api/api_client.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/models/parcel_models.dart';
import '../../core/models/parcel_status.dart';
import '../../core/repositories/parcel_repository.dart';
import 'state/parcel_list_cubit.dart';
import 'state/parcel_list_state.dart';
import 'widgets/parcel_detail_sheet.dart';

class ParcelListScreen extends StatelessWidget {
  const ParcelListScreen({
    super.key,
    required this.session,
    required this.languageCode,
  });

  final UserSession session;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ParcelListCubit(context.read<ParcelRepository>(), languageCode)
            ..search(),
      child: ParcelListWorkspace(session: session, languageCode: languageCode),
    );
  }
}

class ParcelListWorkspace extends StatefulWidget {
  const ParcelListWorkspace({
    super.key,
    required this.session,
    required this.languageCode,
  });

  final UserSession session;
  final String languageCode;

  @override
  State<ParcelListWorkspace> createState() => ParcelListWorkspaceState();
}

class ParcelListWorkspaceState extends State<ParcelListWorkspace> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParcelListCubit, ParcelListState>(
      builder: (context, state) => Column(
        children: [
          ParcelSearchBar(
            languageCode: widget.languageCode,
            controller: searchController,
            selectedStatus: state.filterStatus,
            onSearch: () => context.read<ParcelListCubit>().search(
              query: searchController.text,
              status: state.filterStatus,
            ),
            onStatusChanged: (status) => context.read<ParcelListCubit>().search(
              query: searchController.text,
              status: status,
            ),
          ),
          if (state.loading) const LinearProgressIndicator(),
          Expanded(
            child: state.parcels.isEmpty && !state.loading
                ? Center(
                    child: Text(
                      t(
                        widget.languageCode,
                        'ยังไม่มีพัสดุ',
                        'ຍັງບໍ່ມີພັດສະດຸ',
                      ),
                    ),
                  )
                : ListView.builder(
                    key: const ValueKey('parcel_list'),
                    itemCount: state.parcels.length,
                    itemBuilder: (context, index) => ParcelListTile(
                      parcel: state.parcels[index],
                      languageCode: widget.languageCode,
                      isAdmin: widget.session.isAdmin,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class ParcelSearchBar extends StatelessWidget {
  const ParcelSearchBar({
    super.key,
    required this.languageCode,
    required this.controller,
    required this.selectedStatus,
    required this.onSearch,
    required this.onStatusChanged,
  });

  final String languageCode;
  final TextEditingController controller;
  final ParcelStatus? selectedStatus;
  final VoidCallback onSearch;
  final ValueChanged<ParcelStatus?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 320,
            child: TextField(
              key: const ValueKey('parcel_search_field'),
              controller: controller,
              onSubmitted: (_) => onSearch(),
              decoration: InputDecoration(
                labelText: t(
                  languageCode,
                  'เลข / ชื่อ / เบอร์ / สถานะ',
                  'ເລກ / ຊື່ / ເບີ / ສະຖານະ',
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          DropdownMenu<ParcelStatus?>(
            key: const ValueKey('parcel_status_filter'),
            initialSelection: selectedStatus,
            onSelected: onStatusChanged,
            dropdownMenuEntries: [
              DropdownMenuEntry(
                value: null,
                label: t(languageCode, 'ทั้งหมด', 'ທັງໝົດ'),
              ),
              DropdownMenuEntry(
                value: ParcelStatus.receivedInThailand,
                label: ParcelStatus.receivedInThailand.label(languageCode),
              ),
              DropdownMenuEntry(
                value: ParcelStatus.arrivedInLaos,
                label: ParcelStatus.arrivedInLaos.label(languageCode),
              ),
              DropdownMenuEntry(
                value: ParcelStatus.pickedUp,
                label: ParcelStatus.pickedUp.label(languageCode),
              ),
            ],
          ),
          IconButton.filled(
            key: const ValueKey('parcel_search_button'),
            onPressed: onSearch,
            icon: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}

class ParcelListTile extends StatelessWidget {
  const ParcelListTile({
    super.key,
    required this.parcel,
    required this.languageCode,
    required this.isAdmin,
  });

  final ParcelSummary parcel;
  final String languageCode;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(parcel.trackingCode),
      subtitle: Text(
        '${parcel.customerName} · ${parcel.status.label(languageCode)}',
      ),
      trailing: parcel.queued
          ? const Icon(Icons.cloud_off)
          : const Icon(Icons.chevron_right),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => RepositoryProvider.value(
          value: context.read<ApiClient>(),
          child: ParcelDetailSheet(
            parcel: parcel,
            languageCode: languageCode,
            isAdmin: isAdmin,
          ),
        ),
      ),
    );
  }
}
