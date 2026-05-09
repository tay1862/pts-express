import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/api/api_client.dart';
import '../../core/i18n/app_strings.dart';
import 'state/public_tracking_cubit.dart';
import 'state/public_tracking_state.dart';

class PublicTrackingScreen extends StatelessWidget {
  const PublicTrackingScreen({super.key, required this.languageCode});

  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PublicTrackingCubit(context.read<ApiClient>(), languageCode),
      child: PublicTrackingWorkspace(languageCode: languageCode),
    );
  }
}

class PublicTrackingWorkspace extends StatefulWidget {
  const PublicTrackingWorkspace({super.key, required this.languageCode});

  final String languageCode;

  @override
  State<PublicTrackingWorkspace> createState() =>
      PublicTrackingWorkspaceState();
}

class PublicTrackingWorkspaceState extends State<PublicTrackingWorkspace> {
  final trackingController = TextEditingController();

  @override
  void dispose() {
    trackingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          t(widget.languageCode, 'ติดตามพัสดุ', 'ຕິດຕາມພັດສະດຸ'),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const ValueKey('public_tracking_field'),
                controller: trackingController,
                onSubmitted: (_) => context.read<PublicTrackingCubit>().track(
                  trackingController.text,
                ),
                decoration: InputDecoration(
                  labelText: t(widget.languageCode, 'เลขพัสดุ', 'ເລກພັດສະດຸ'),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              key: const ValueKey('public_tracking_button'),
              onPressed: () => context.read<PublicTrackingCubit>().track(
                trackingController.text,
              ),
              icon: const Icon(Icons.search),
            ),
          ],
        ),
        const SizedBox(height: 16),
        PublicTrackingResult(languageCode: widget.languageCode),
      ],
    );
  }
}

class PublicTrackingResult extends StatelessWidget {
  const PublicTrackingResult({super.key, required this.languageCode});

  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PublicTrackingCubit, PublicTrackingState>(
      builder: (context, state) {
        if (state.loading) {
          return const LinearProgressIndicator();
        }
        if (state.error != null) {
          return Text(
            state.error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          );
        }
        final result = state.result;
        if (result == null) {
          return const SizedBox.shrink();
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TrackingCodeTitle(trackingCode: result.trackingCode),
                const SizedBox(height: 8),
                Text(result.status.label(languageCode)),
                const Divider(height: 28),
                for (final event in result.history)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.check),
                    title: Text(
                      event.toStatus?.label(languageCode) ?? event.eventType,
                    ),
                    subtitle: Text(event.happenedAt.toLocal().toString()),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TrackingCodeTitle extends StatelessWidget {
  const TrackingCodeTitle({super.key, required this.trackingCode});

  final String trackingCode;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          trackingCode,
          maxLines: 1,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
