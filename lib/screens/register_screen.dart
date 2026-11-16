import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';

/// Daftar akun lewat `POST /api/auth/register/`. Jika berhasil, kembali ke
/// halaman login dengan membawa username yang baru dibuat.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password1 = TextEditingController();
  final _password2 = TextEditingController();
  bool _loading = false;
  ApiException? _error;

  @override
  void dispose() {
    _username.dispose();
    _password1.dispose();
    _password2.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final message = await context.read<ApiClient>().register(
            _username.text.trim(),
            _password1.text,
            _password2.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      Navigator.of(context).pop(_username.text.trim());
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _required(String? value, String label) =>
      (value == null || value.isEmpty) ? '$label wajib diisi.' : null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = _error;
    // Pesan umum hanya ditampilkan jika tidak ada error yang bisa ditaruh di field.
    final generalError = error != null &&
            error.fieldError('username') == null &&
            error.fieldError('password1') == null &&
            error.fieldError('password2') == null
        ? error.message
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      key: const Key('register-username'),
                      controller: _username,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        errorText: error?.fieldError('username'),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) => _required(value?.trim(), 'Username'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('register-password1'),
                      controller: _password1,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        errorText: error?.fieldError('password1'),
                        errorMaxLines: 3,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) => _required(value, 'Password'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('register-password2'),
                      controller: _password2,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Ulangi password',
                        errorText: error?.fieldError('password2'),
                        errorMaxLines: 3,
                      ),
                      onFieldSubmitted: (_) => _submit(),
                      validator: (value) => _required(value, 'Konfirmasi password'),
                    ),
                    if (generalError != null) ...[
                      const SizedBox(height: 16),
                      Text(generalError, style: TextStyle(color: theme.colorScheme.error)),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const Key('register-submit'),
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Daftar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
