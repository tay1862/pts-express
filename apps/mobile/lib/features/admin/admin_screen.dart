import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/api/api_client.dart';
import '../../core/i18n/app_strings.dart';
import 'state/admin_cubit.dart';
import 'state/admin_state.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key, required this.languageCode});

  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AdminCubit(context.read<ApiClient>(), languageCode)..loadUsers(),
      child: AdminWorkspace(languageCode: languageCode),
    );
  }
}

class AdminWorkspace extends StatefulWidget {
  const AdminWorkspace({super.key, required this.languageCode});

  final String languageCode;

  @override
  State<AdminWorkspace> createState() => AdminWorkspaceState();
}

class AdminWorkspaceState extends State<AdminWorkspace> {
  final usernameController = TextEditingController();
  final displayNameController = TextEditingController();
  final passwordController = TextEditingController();
  String role = 'STAFF';

  @override
  void dispose() {
    usernameController.dispose();
    displayNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            t(widget.languageCode, 'ผู้ดูแลระบบ', 'ຜູ້ດູແລລະບົບ'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          AdminCreateUserForm(
            usernameController: usernameController,
            displayNameController: displayNameController,
            passwordController: passwordController,
            role: role,
            languageCode: widget.languageCode,
            onRoleChanged: (value) => setState(() => role = value),
            onCreate: createUser,
          ),
          if (state.loading) const LinearProgressIndicator(),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                state.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 16),
          for (final user in state.users)
            ListTile(
              title: Text(user.displayName),
              subtitle: Text('${user.username} · ${user.role}'),
              trailing: Icon(user.isActive ? Icons.check_circle : Icons.block),
            ),
        ],
      ),
    );
  }

  Future<void> createUser() async {
    await context.read<AdminCubit>().createUser(
      username: usernameController.text,
      password: passwordController.text,
      displayName: displayNameController.text,
      role: role,
    );
    usernameController.clear();
    displayNameController.clear();
    passwordController.clear();
  }
}

class AdminCreateUserForm extends StatelessWidget {
  const AdminCreateUserForm({
    super.key,
    required this.usernameController,
    required this.displayNameController,
    required this.passwordController,
    required this.role,
    required this.languageCode,
    required this.onRoleChanged,
    required this.onCreate,
  });

  final TextEditingController usernameController;
  final TextEditingController displayNameController;
  final TextEditingController passwordController;
  final String role;
  final String languageCode;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 180,
              child: TextField(
                key: const ValueKey('admin_username_field'),
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: t(languageCode, 'ชื่อผู้ใช้', 'ຊື່ຜູ້ໃຊ້'),
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: TextField(
                key: const ValueKey('admin_display_name_field'),
                controller: displayNameController,
                decoration: InputDecoration(
                  labelText: t(languageCode, 'ชื่อที่แสดง', 'ຊື່ສະແດງ'),
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: TextField(
                key: const ValueKey('admin_password_field'),
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: t(languageCode, 'รหัสผ่าน', 'ລະຫັດຜ່ານ'),
                ),
              ),
            ),
            DropdownMenu<String>(
              key: const ValueKey('admin_role_menu'),
              initialSelection: role,
              onSelected: (value) => onRoleChanged(value ?? 'STAFF'),
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: 'STAFF', label: 'Staff'),
                DropdownMenuEntry(value: 'ADMIN', label: 'Admin'),
                DropdownMenuEntry(value: 'OWNER', label: 'Owner'),
              ],
            ),
            FilledButton.icon(
              key: const ValueKey('admin_create_user_button'),
              onPressed: onCreate,
              icon: const Icon(Icons.person_add),
              label: Text(t(languageCode, 'สร้างผู้ใช้', 'ສ້າງຜູ້ໃຊ້')),
            ),
          ],
        ),
      ),
    );
  }
}
