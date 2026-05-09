import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/scan_cubit.dart';
import '../state/scan_state.dart';

class ScanFeedback extends StatelessWidget {
  const ScanFeedback({super.key, required this.languageCode});

  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScanCubit, ScanState>(
      builder: (context, state) {
        if (state.message == null && state.lastParcel == null) {
          return const SizedBox.shrink();
        }
        final color = switch (state.submissionStatus) {
          ScanSubmissionStatus.success => Theme.of(
            context,
          ).colorScheme.primaryContainer,
          ScanSubmissionStatus.error => Theme.of(
            context,
          ).colorScheme.errorContainer,
          ScanSubmissionStatus.needsCustomerName => Theme.of(
            context,
          ).colorScheme.tertiaryContainer,
          _ => Theme.of(context).colorScheme.surfaceContainerHighest,
        };
        return Card(
          key: const ValueKey('scan_feedback_card'),
          color: color,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.message != null)
                  Text(
                    state.message!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                if (state.lastParcel != null) ...[
                  const SizedBox(height: 8),
                  Text(state.lastParcel!.trackingCode),
                  Text(state.lastParcel!.status.label(languageCode)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
