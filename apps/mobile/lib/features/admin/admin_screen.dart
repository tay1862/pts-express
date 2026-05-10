import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/api/api_client.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/models/parcel_models.dart';
import '../../core/repositories/offline_queue_repository.dart';
import 'state/admin_cubit.dart';
import 'state/admin_state.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key, required this.languageCode});

  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AdminCubit(
              context.read<ApiClient>(),
              context.read<OfflineQueueRepository>(),
              languageCode,
            )
            ..loadUsers()
            ..loadQueue(),
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
  final resetPasswordController = TextEditingController();
  String role = 'STAFF';
  bool isActive = true;
  AdminUser? editingUser;

  @override
  void dispose() {
    usernameController.dispose();
    displayNameController.dispose();
    passwordController.dispose();
    resetPasswordController.dispose();
    super.dispose();
  }

  void beginEdit(AdminUser user) {
    setState(() {
      editingUser = user;
      usernameController.text = user.username;
      displayNameController.text = user.displayName;
      role = user.role;
      isActive = user.isActive;
    });
  }

  void clearForm() {
    setState(() {
      editingUser = null;
      usernameController.clear();
      displayNameController.clear();
      passwordController.clear();
      role = 'STAFF';
      isActive = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) => DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Text(
                    t(widget.languageCode, 'ผู้ดูแลระบบ', 'ຜູ້ດູແລລະບົບ'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Spacer(),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        tabs: [
                          Tab(
                            text: t(widget.languageCode, 'พนักงาน', 'ພະນັກງານ'),
                          ),
                          Tab(
                            text:
                                '${t(widget.languageCode, 'คิวผิดปกติ', 'ຄິວຜິດປົກກະຕິ')} (${state.queueEntries.length})',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (state.loading || state.queueLoading)
              const LinearProgressIndicator(),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  state.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (state.queueError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  state.queueError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      AdminCreateUserForm(
                        editingUser: editingUser,
                        usernameController: usernameController,
                        displayNameController: displayNameController,
                        passwordController: passwordController,
                        role: role,
                        isActive: isActive,
                        languageCode: widget.languageCode,
                        onRoleChanged: (value) => setState(() => role = value),
                        onIsActiveChanged: (value) =>
                            setState(() => isActive = value),
                        onSubmit: submitUser,
                        onCancel: editingUser == null ? null : clearForm,
                      ),
                      const SizedBox(height: 16),
                      for (final user in state.users)
                        Card(
                          child: ListTile(
                            title: Text(user.displayName),
                            subtitle: Text('${user.username} · ${user.role}'),
                            leading: Icon(
                              user.isActive ? Icons.check_circle : Icons.block,
                              color: user.isActive
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) =>
                                  handleUserAction(context, user, value),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text(
                                    t(widget.languageCode, 'แก้ไข', 'ແກ້ໄຂ'),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'reset',
                                  child: Text(
                                    t(
                                      widget.languageCode,
                                      'รีเซ็ตรหัสผ่าน',
                                      'ຣີເຊັດລະຫັດຜ່ານ',
                                    ),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: user.isActive
                                      ? 'deactivate'
                                      : 'reactivate',
                                  child: Text(
                                    user.isActive
                                        ? t(
                                            widget.languageCode,
                                            'ปิดใช้งาน',
                                            'ປິດໃຊ້ງານ',
                                          )
                                        : t(
                                            widget.languageCode,
                                            'เปิดใช้งาน',
                                            'ເປີດໃຊ້ງານ',
                                          ),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    t(widget.languageCode, 'ลบ', 'ລຶບ'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        children: [
                          Text(
                            t(
                              widget.languageCode,
                              'คิวที่รอซิงก์/ผิดพลาด',
                              'ຄິວທີ່ລໍຖ້າຊິງຄ໌/ຜິດພາດ',
                            ),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Spacer(),
                          FilledButton.icon(
                            key: const ValueKey('retry_queue_button'),
                            onPressed: state.queueEntries.isEmpty
                                ? null
                                : () => context.read<AdminCubit>().retryQueue(),
                            icon: const Icon(Icons.refresh),
                            label: Text(
                              t(
                                widget.languageCode,
                                'ลองซิงก์ใหม่',
                                'ລອງຊິງຄ໌ໃໝ່',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      for (final entry in state.queueEntries)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.error_outline),
                            title: Text(entry.type),
                            subtitle: Text(
                              '${entry.clientMutationId}\n${entry.happenedAt.toLocal()}\n${entry.lastError ?? ''}',
                            ),
                            isThreeLine: true,
                            trailing: Text('x${entry.attempts}'),
                          ),
                        ),
                      if (state.queueEntries.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Center(
                            child: Text(
                              t(
                                widget.languageCode,
                                'ไม่มีคิวค้าง',
                                'ບໍ່ມີຄິວຄ້າງ',
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> submitUser() async {
    final cubit = context.read<AdminCubit>();
    if (editingUser == null) {
      await cubit.createUser(
        username: usernameController.text,
        password: passwordController.text,
        displayName: displayNameController.text,
        role: role,
      );
    } else {
      await cubit.updateUser(
        userId: editingUser!.id,
        displayName: displayNameController.text,
        role: role,
        isActive: isActive,
      );
    }
    clearForm();
  }

  Future<void> handleUserAction(
    BuildContext context,
    AdminUser user,
    String action,
  ) async {
    final cubit = context.read<AdminCubit>();
    switch (action) {
      case 'edit':
        beginEdit(user);
        break;
      case 'reset':
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => _ResetPasswordDialog(
            languageCode: widget.languageCode,
            controller: resetPasswordController,
            onSubmit: () async {
              await cubit.resetPassword(
                userId: user.id,
                password: resetPasswordController.text,
              );
              resetPasswordController.clear();
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
          ),
        );
        break;
      case 'deactivate':
        await cubit.updateUser(
          userId: user.id,
          displayName: user.displayName,
          role: user.role,
          isActive: false,
        );
        break;
      case 'reactivate':
        await cubit.updateUser(
          userId: user.id,
          displayName: user.displayName,
          role: user.role,
          isActive: true,
        );
        break;
      case 'delete':
        await cubit.deleteUser(user.id);
        break;
    }
  }
}

class AdminCreateUserForm extends StatelessWidget {
  const AdminCreateUserForm({
    super.key,
    required this.editingUser,
    required this.usernameController,
    required this.displayNameController,
    required this.passwordController,
    required this.role,
    required this.isActive,
    required this.languageCode,
    required this.onRoleChanged,
    required this.onIsActiveChanged,
    required this.onSubmit,
    required this.onCancel,
  });

  final AdminUser? editingUser;
  final TextEditingController usernameController;
  final TextEditingController displayNameController;
  final TextEditingController passwordController;
  final String role;
  final bool isActive;
  final String languageCode;
  final ValueChanged<String> onRoleChanged;
  final ValueChanged<bool> onIsActiveChanged;
  final VoidCallback onSubmit;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              editingUser == null
                  ? t(languageCode, 'สร้างพนักงาน', 'ສ້າງພະນັກງານ')
                  : t(languageCode, 'แก้ไขพนักงาน', 'ແກ້ໄຂພະນັກງານ'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 180,
                  child: TextField(
                    key: const ValueKey('admin_username_field'),
                    controller: usernameController,
                    enabled: editingUser == null,
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
                if (editingUser == null)
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
                FilterChip(
                  label: Text(
                    isActive
                        ? t(languageCode, 'ใช้งานอยู่', 'ໃຊ້ງານຢູ່')
                        : t(languageCode, 'ปิดใช้งาน', 'ປິດໃຊ້ງານ'),
                  ),
                  selected: isActive,
                  onSelected: onIsActiveChanged,
                ),
                FilledButton.icon(
                  key: const ValueKey('admin_submit_user_button'),
                  onPressed: onSubmit,
                  icon: Icon(
                    editingUser == null ? Icons.person_add : Icons.save,
                  ),
                  label: Text(
                    editingUser == null
                        ? t(languageCode, 'สร้างผู้ใช้', 'ສ້າງຜູ້ໃຊ້')
                        : t(languageCode, 'บันทึก', 'ບັນທຶກ'),
                  ),
                ),
                if (onCancel != null)
                  OutlinedButton(
                    onPressed: onCancel,
                    child: Text(t(languageCode, 'ยกเลิก', 'ຍົກເລີກ')),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResetPasswordDialog extends StatelessWidget {
  const _ResetPasswordDialog({
    required this.languageCode,
    required this.controller,
    required this.onSubmit,
  });

  final String languageCode;
  final TextEditingController controller;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(t(languageCode, 'รีเซ็ตรหัสผ่าน', 'ຣີເຊັດລະຫັດຜ່ານ')),
      content: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: t(languageCode, 'รหัสผ่านใหม่', 'ລະຫັດຜ່ານໃໝ່'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t(languageCode, 'ยกเลิก', 'ຍົກເລີກ')),
        ),
        FilledButton(
          onPressed: () async => onSubmit(),
          child: Text(t(languageCode, 'บันทึก', 'ບັນທຶກ')),
        ),
      ],
    );
  }
}
