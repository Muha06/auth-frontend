import 'package:auth_frontend/core/errors/api_exception.dart';
import 'package:auth_frontend/core/helpers/navigation.dart';
import 'package:auth_frontend/core/helpers/snackbars.dart';
import 'package:auth_frontend/features/auth/presentation/pages/auth_page.dart';
import 'package:auth_frontend/features/auth/presentation/providers/auth_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  late final TextEditingController _oldPasswordCtrl;
  late final TextEditingController _newPasswordCtrl;

  @override
  void initState() {
    super.initState();

    _oldPasswordCtrl = TextEditingController()
      ..addListener(() => setState(() {}));
    _newPasswordCtrl = TextEditingController()
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();

    super.dispose();
  }

  String get oldPassword => _oldPasswordCtrl.text;
  String get newPassword => _newPasswordCtrl.text;

  bool get hasValidInput =>
      oldPassword.trim().isNotEmpty && newPassword.trim().isNotEmpty;

  Future<void> _submit() async {
    final trimmedOldPassword = oldPassword.trim();
    final trimmedNewPassword = newPassword.trim();

    if (trimmedOldPassword.isEmpty || trimmedNewPassword.isEmpty) {
      AppSnackBar.error(
        context,
        'Please enter both your old and new password.',
      );
      return;
    }

    if (trimmedOldPassword == trimmedNewPassword) {
      AppSnackBar.error(context, 'Old password cannot match the new password.');
      return;
    }

    if (trimmedOldPassword.length < 6) {
      AppSnackBar.error(
        context,
        'Old password must be at least 6 characters long.',
      );
      return;
    }

    if (trimmedNewPassword.length < 6) {
      AppSnackBar.error(
        context,
        'New password must be at least 6 characters long.',
      );
      return;
    }

    try {
      await ref
          .read(authProvider.notifier)
          .changePassword(
            oldPassword: trimmedOldPassword,
            newPassword: trimmedNewPassword,
          );

      if (!mounted) return;
      AppSnackBar.success(context, "Password changed successfully.");

      _oldPasswordCtrl.clear();
      _newPasswordCtrl.clear();

      AppNavigator.pushReplacement(context, const AuthPage());
    } on ApiException catch (e) {
      if (!mounted) return;

      AppSnackBar.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Change password')),
      body: Column(
        children: [
          _PasswordTextField(
            controller: _oldPasswordCtrl,
            label: 'Old password',
          ),
          const SizedBox(height: 16),

          _PasswordTextField(
            controller: _newPasswordCtrl,
            label: 'New password',
            textInputAction: TextInputAction.done,
            onSubmitted: () => _submit(),
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: (hasValidInput && !isLoading) ? _submit : null,
            child: isLoading
                ? const CupertinoActivityIndicator(radius: 24)
                : const Text('Change password'),
          ),
        ],
      ),
    );
  }
}

class _PasswordTextField extends StatefulWidget {
  const _PasswordTextField({
    required this.controller,
    required this.label,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;

  @override
  State<_PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<_PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      enableSuggestions: false,
      autocorrect: false,
      textInputAction: widget.textInputAction,
      onSubmitted: (_) => widget.onSubmitted?.call(),
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() => _obscureText = !_obscureText);
          },
          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
        ),
      ),
    );
  }
}
