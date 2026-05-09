import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/api/api_client.dart';
import 'core/models/parcel_models.dart';
import 'core/repositories/offline_queue_repository.dart';
import 'core/repositories/parcel_repository.dart';
import 'core/repositories/session_store.dart';
import 'core/services/auto_sync_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/shell/home_shell.dart';
import 'features/tracking/public_tracking_screen.dart';

class PtsApp extends StatefulWidget {
  const PtsApp({
    super.key,
    required this.sessionStore,
    required this.apiClient,
    required this.parcelRepository,
    required this.offlineQueue,
    required this.autoSync,
  });

  final SessionStore sessionStore;
  final ApiClient apiClient;
  final ParcelRepository parcelRepository;
  final OfflineQueueRepository offlineQueue;
  final AutoSyncService autoSync;

  @override
  State<PtsApp> createState() => PtsAppState();
}

class PtsAppState extends State<PtsApp> with WidgetsBindingObserver {
  UserSession? session;
  String languageCode = 'th';
  bool loading = true;
  bool showingPublicTracking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.autoSync.start();
    loadSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(widget.autoSync.dispose());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && session != null) {
      widget.autoSync.scheduleSync();
    }
  }

  Future<void> loadSession() async {
    final nextSession = await widget.sessionStore.session();
    final nextLanguage = await widget.sessionStore.languageCode();
    if (!mounted) {
      return;
    }
    setState(() {
      session = nextSession;
      languageCode = nextLanguage;
      loading = false;
    });
    widget.autoSync.setEnabled(nextSession != null);
  }

  Future<void> setLanguageCode(String value) async {
    await widget.sessionStore.saveLanguageCode(value);
    setState(() => languageCode = value);
  }

  Future<void> setSession(UserSession value) async {
    await widget.sessionStore.saveSession(value);
    setState(() {
      session = value;
      showingPublicTracking = false;
    });
    widget.autoSync.setEnabled(true);
  }

  Future<void> logout() async {
    await widget.sessionStore.clearSession();
    setState(() {
      session = null;
      showingPublicTracking = false;
    });
    widget.autoSync.setEnabled(false);
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.sessionStore),
        RepositoryProvider.value(value: widget.apiClient),
        RepositoryProvider.value(value: widget.parcelRepository),
        RepositoryProvider.value(value: widget.offlineQueue),
        RepositoryProvider.value(value: widget.autoSync),
      ],
      child: MaterialApp(
        title: 'PTS Express',
        theme: buildPtsTheme(),
        debugShowCheckedModeBanner: false,
        home: loading
            ? const AppLoadingScreen()
            : session == null
            ? showingPublicTracking
                  ? PublicTrackingGuestScreen(
                      languageCode: languageCode,
                      onLanguageChanged: setLanguageCode,
                      onBackToLogin: () =>
                          setState(() => showingPublicTracking = false),
                    )
                  : LoginScreen(
                      languageCode: languageCode,
                      onLanguageChanged: setLanguageCode,
                      onLoggedIn: setSession,
                      onPublicTracking: () =>
                          setState(() => showingPublicTracking = true),
                    )
            : HomeShell(
                session: session!,
                languageCode: languageCode,
                onLanguageChanged: setLanguageCode,
                onLogout: logout,
              ),
      ),
    );
  }
}

class PublicTrackingGuestScreen extends StatelessWidget {
  const PublicTrackingGuestScreen({
    super.key,
    required this.languageCode,
    required this.onLanguageChanged,
    required this.onBackToLogin,
  });

  final String languageCode;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PTS Express'),
        actions: [
          SegmentedButton<String>(
            key: const ValueKey('guest_language_toggle'),
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 'th', label: Text('TH')),
              ButtonSegment(value: 'lo', label: Text('LO')),
            ],
            selected: {languageCode},
            onSelectionChanged: (value) => onLanguageChanged(value.first),
          ),
          IconButton(
            key: const ValueKey('back_to_login_button'),
            tooltip: languageCode == 'lo' ? 'ເຂົ້າລະບົບ' : 'เข้าสู่ระบบ',
            onPressed: onBackToLogin,
            icon: const Icon(Icons.login),
          ),
        ],
      ),
      body: PublicTrackingScreen(languageCode: languageCode),
    );
  }
}

class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/pts-logo.png', width: 92, height: 92),
            const SizedBox(height: 20),
            const SizedBox(
              width: 132,
              child: LinearProgressIndicator(minHeight: 3),
            ),
          ],
        ),
      ),
    );
  }
}
