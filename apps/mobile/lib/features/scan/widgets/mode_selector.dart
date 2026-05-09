import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/parcel_status.dart';
import '../state/scan_cubit.dart';
import '../state/scan_state.dart';

class ModeSelector extends StatelessWidget {
  const ModeSelector({super.key, required this.languageCode});

  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScanCubit, ScanState>(
      builder: (context, state) => SegmentedButton<ScanMode>(
        key: const ValueKey('scan_mode_toggle'),
        segments: [
          for (final mode in ScanMode.values)
            ButtonSegment(
              value: mode,
              icon: Icon(switch (mode) {
                ScanMode.receive => Icons.input,
                ScanMode.arrive => Icons.warehouse,
                ScanMode.pickup => Icons.output,
              }),
              label: Text(mode.label(languageCode)),
            ),
        ],
        selected: {state.mode},
        onSelectionChanged: (value) =>
            context.read<ScanCubit>().setMode(value.first),
      ),
    );
  }
}
