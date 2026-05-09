import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/api/api_client.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/models/parcel_models.dart';
import 'state/login_cubit.dart';
import 'state/login_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    required this.languageCode,
    required this.onLanguageChanged,
    required this.onLoggedIn,
    required this.onPublicTracking,
  });

  final String languageCode;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<UserSession> onLoggedIn;
  final VoidCallback onPublicTracking;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(context.read<ApiClient>(), languageCode),
      child: LoginPanel(
        languageCode: languageCode,
        onLanguageChanged: onLanguageChanged,
        onLoggedIn: onLoggedIn,
        onPublicTracking: onPublicTracking,
      ),
    );
  }
}

class LoginPanel extends StatefulWidget {
  const LoginPanel({
    super.key,
    required this.languageCode,
    required this.onLanguageChanged,
    required this.onLoggedIn,
    required this.onPublicTracking,
  });

  final String languageCode;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<UserSession> onLoggedIn;
  final VoidCallback onPublicTracking;

  @override
  State<LoginPanel> createState() => LoginPanelState();
}

class LoginPanelState extends State<LoginPanel> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: LoginForm(
                usernameController: usernameController,
                passwordController: passwordController,
                languageCode: widget.languageCode,
                onLanguageChanged: widget.onLanguageChanged,
                onLoggedIn: widget.onLoggedIn,
                onPublicTracking: widget.onPublicTracking,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.languageCode,
    required this.onLanguageChanged,
    required this.onLoggedIn,
    required this.onPublicTracking,
  });

  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final String languageCode;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<UserSession> onLoggedIn;
  final VoidCallback onPublicTracking;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LoginBrandHeader(languageCode: languageCode),
          const SizedBox(height: 24),
          LanguageSwitch(
            languageCode: languageCode,
            onChanged: onLanguageChanged,
          ),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey('username_field'),
            controller: usernameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: t(languageCode, 'ชื่อผู้ใช้', 'ຊື່ຜູ້ໃຊ້'),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('password_field'),
            controller: passwordController,
            obscureText: true,
            onSubmitted: (_) => submit(context),
            decoration: InputDecoration(
              labelText: t(languageCode, 'รหัสผ่าน', 'ລະຫັດຜ່ານ'),
            ),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            key: const ValueKey('remember_me_toggle'),
            value: state.rememberMe,
            onChanged: (value) =>
                context.read<LoginCubit>().setRememberMe(value ?? false),
            contentPadding: EdgeInsets.zero,
            title: Text(t(languageCode, 'จดจำฉัน', 'ຈື່ຈຳຂ້ອຍ')),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (state.error != null) LoginErrorText(message: state.error!),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const ValueKey('login_button'),
            onPressed: state.loading ? null : () => submit(context),
            icon: state.loading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.login),
            label: Text(t(languageCode, 'เข้าสู่ระบบ', 'ເຂົ້າລະບົບ')),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            key: const ValueKey('guest_tracking_button'),
            onPressed: state.loading ? null : onPublicTracking,
            icon: const Icon(Icons.travel_explore),
            label: Text(t(languageCode, 'ติดตามพัสดุ', 'ຕິດຕາມພັດສະດຸ')),
          ),
        ],
      ),
    );
  }

  Future<void> submit(BuildContext context) async {
    final session = await context.read<LoginCubit>().login(
      username: usernameController.text,
      password: passwordController.text,
    );
    if (session != null) {
      onLoggedIn(session);
    }
  }
}

class LoginBrandHeader extends StatelessWidget {
  const LoginBrandHeader({super.key, required this.languageCode});

  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/pts-logo.png',
              width: 76,
              height: 76,
              semanticLabel: 'PTS Express',
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'PTS Express',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          t(languageCode, 'ระบบโกดัง ไทย - ลาว', 'ລະບົບສາງ ໄທ - ລາວ'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class LanguageSwitch extends StatelessWidget {
  const LanguageSwitch({
    super.key,
    required this.languageCode,
    required this.onChanged,
  });

  final String languageCode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      key: const ValueKey('language_toggle'),
      segments: const [
        ButtonSegment(value: 'th', label: Text('ไทย')),
        ButtonSegment(value: 'lo', label: Text('ລາວ')),
      ],
      selected: {languageCode},
      onSelectionChanged: (value) => onChanged(value.first),
    );
  }
}

class LoginErrorText extends StatelessWidget {
  const LoginErrorText({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
