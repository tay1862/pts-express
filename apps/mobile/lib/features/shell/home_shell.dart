import 'package:flutter/material.dart';

import '../../core/build/app_build_info.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/models/parcel_models.dart';
import '../admin/admin_screen.dart';
import '../parcels/parcel_list_screen.dart';
import '../scan/scan_screen.dart';
import '../tracking/public_tracking_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.session,
    required this.languageCode,
    required this.themeMode,
    required this.onLanguageChanged,
    required this.onThemeModeChanged,
    required this.onLogout,
  });

  final UserSession session;
  final String languageCode;
  final ThemeMode themeMode;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final VoidCallback onLogout;

  @override
  State<HomeShell> createState() => HomeShellState();
}

class HomeShellState extends State<HomeShell> {
  int selectedIndex = 0;
  late List<ShellDestination> _destinations = _buildDestinations();

  List<ShellDestination> _buildDestinations() => [
    ShellDestination(
      icon: Icons.qr_code_scanner,
      label: t(widget.languageCode, 'สแกน', 'ສະແກນ'),
      screen: ScanScreen(languageCode: widget.languageCode),
    ),
    ShellDestination(
      icon: Icons.inventory_2,
      label: t(widget.languageCode, 'พัสดุ', 'ພັດສະດຸ'),
      screen: ParcelListScreen(
        session: widget.session,
        languageCode: widget.languageCode,
      ),
    ),
    ShellDestination(
      icon: Icons.travel_explore,
      label: t(widget.languageCode, 'ติดตาม', 'ຕິດຕາມ'),
      screen: PublicTrackingScreen(languageCode: widget.languageCode),
    ),
    if (widget.session.isAdmin)
      ShellDestination(
        icon: Icons.admin_panel_settings,
        label: t(widget.languageCode, 'ผู้ดูแล', 'ຜູ້ດູແລ'),
        screen: AdminScreen(languageCode: widget.languageCode),
      ),
  ];

  @override
  void didUpdateWidget(covariant HomeShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.languageCode != widget.languageCode ||
        oldWidget.session != widget.session) {
      _destinations = _buildDestinations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _destinations;
    final selected = selectedIndex.clamp(0, items.length - 1);
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 760;
        return Scaffold(
          appBar: ShellAppBar(
            session: widget.session,
            languageCode: widget.languageCode,
            themeMode: widget.themeMode,
            onLanguageChanged: widget.onLanguageChanged,
            onThemeModeChanged: widget.onThemeModeChanged,
            onLogout: widget.onLogout,
          ),
          body: Row(
            children: [
              if (useRail)
                NavigationRail(
                  selectedIndex: selected,
                  onDestinationSelected: (index) =>
                      setState(() => selectedIndex = index),
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final item in items)
                      NavigationRailDestination(
                        icon: Icon(item.icon),
                        label: Text(item.label),
                      ),
                  ],
                ),
              Expanded(
                child: IndexedStack(
                  index: selected,
                  children: [for (final item in items) item.screen],
                ),
              ),
            ],
          ),
          bottomNavigationBar: useRail
              ? null
              : NavigationBar(
                  selectedIndex: selected,
                  onDestinationSelected: (index) =>
                      setState(() => selectedIndex = index),
                  destinations: [
                    for (final item in items)
                      NavigationDestination(
                        icon: Icon(item.icon),
                        label: item.label,
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class ShellDestination {
  const ShellDestination({
    required this.icon,
    required this.label,
    required this.screen,
  });

  final IconData icon;
  final String label;
  final Widget screen;
}

class ShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ShellAppBar({
    super.key,
    required this.session,
    required this.languageCode,
    required this.themeMode,
    required this.onLanguageChanged,
    required this.onThemeModeChanged,
    required this.onLogout,
  });

  final UserSession session;
  final String languageCode;
  final ThemeMode themeMode;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final VoidCallback onLogout;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 520;
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/pts-logo.png',
            width: compact ? 34 : 42,
            height: compact ? 34 : 42,
          ),
          const SizedBox(width: 8),
          Text(compact ? 'PTS' : 'PTS Express'),
        ],
      ),
      actions: [
        if (!compact) ...[Text(session.displayName), const SizedBox(width: 8)],
        IconButton(
          key: const ValueKey('theme_toggle_button'),
          tooltip: t(languageCode, 'เปลี่ยนธีม', 'ປ່ຽນຘີມ'),
          onPressed: () {
            final next = switch (themeMode) {
              ThemeMode.system => ThemeMode.light,
              ThemeMode.light => ThemeMode.dark,
              ThemeMode.dark => ThemeMode.system,
            };
            onThemeModeChanged(next);
          },
          icon: Icon(switch (themeMode) {
            ThemeMode.light => Icons.light_mode,
            ThemeMode.dark => Icons.dark_mode,
            ThemeMode.system => Icons.brightness_auto,
          }),
        ),
        IconButton(
          key: const ValueKey('build_info_button'),
          tooltip: AppBuildInfo.summary,
          onPressed: () => showAboutDialog(
            context: context,
            applicationName: 'PTS Express',
            applicationVersion:
                '${AppBuildInfo.appVersion}\n${AppBuildInfo.buildId}\n${AppBuildInfo.buildTime}',
          ),
          icon: const Icon(Icons.info_outline),
        ),
        SegmentedButton<String>(
          key: const ValueKey('shell_language_toggle'),
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: 'th', label: Text('TH')),
            ButtonSegment(value: 'lo', label: Text('LO')),
          ],
          selected: {languageCode},
          onSelectionChanged: (value) => onLanguageChanged(value.first),
        ),
        IconButton(
          key: const ValueKey('logout_button'),
          tooltip: t(languageCode, 'ออกจากระบบ', 'ອອກຈາກລະບົບ'),
          onPressed: onLogout,
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }
}
