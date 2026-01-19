import 'package:flutter/material.dart';
import 'package:tche_organiza/services/credential_storage.dart';
import 'package:tche_organiza/services/ru_ticket.dart';

class CredentialsLoginView extends StatefulWidget {
  const CredentialsLoginView({super.key});

  @override
  State<CredentialsLoginView> createState() =>
      _CredentialsLoginViewState();
}

class _CredentialsLoginViewState
    extends State<CredentialsLoginView> {
  final _service = UFRGSRuTickets();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    final user = _userController.text.trim();
    final password = _passwordController.text;

    if (user.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Preencha usuário e senha';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final valid = await _service.login(
        usuario: user,
        senha: password,
      );

      if (!valid) {
        setState(() {
          _error = 'Usuário ou senha inválidos';
        });
        return;
      }

      await CredentialsStorage.save(
        user: user,
        password: password,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login salvo com sucesso')),
      );

      // You can navigate to RU tickets here
      // Navigator.pushReplacement(...)
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(
                labelText: 'Usuário',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Entrar'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      );
  }
}
