import 'package:flutter/material.dart';
import 'package:tche_organiza/services/credential_storage.dart';
import 'package:tche_organiza/services/ru_ticket.dart';

class CredentialsLoginView extends StatefulWidget {
  const CredentialsLoginView({super.key});

  @override
  State<CredentialsLoginView> createState() => _CredentialsLoginViewState();
}

class _CredentialsLoginViewState extends State<CredentialsLoginView> {
  final _service = RUTicketService();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _checkingCredentials = true;
  String? _error;
  String? _loggedInUser;

  @override
  void initState() {
    super.initState();
    _checkExistingCredentials();
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingCredentials() async {
    final creds = await CredentialsStorage.load();
    if (!mounted) return;
    setState(() {
      _loggedInUser = creds?.$1;
      _checkingCredentials = false;
    });
  }

  Future<void> _logout() async {
    setState(() => _loading = true);

    try {
      await CredentialsStorage.clear();
      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Logout realizado com sucesso')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _login() async {
    final user = _userController.text.trim();
    final password = _passwordController.text;

    if (user.isEmpty || password.isEmpty) {
      setState(() => _error = 'Preencha usuário e senha');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final valid = await _service.login(usuario: user, senha: password);

      if (!valid) {
        setState(() => _error = 'Usuário ou senha inválidos');
        return;
      }

      await CredentialsStorage.save(user: user, password: password);

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Login salvo com sucesso')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_checkingCredentials) {
      return _SheetShell(
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_loggedInUser != null) {
      return _SheetShell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              title: 'Conta ativa',
              subtitle: 'Você está logado',
              onClose: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainerHigh,
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Usuário atual'),
                subtitle: Text(_loggedInUser!),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              _ErrorMessage(message: _error!),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: _loading ? null : _logout,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sair da conta'),
              ),
            ),
          ],
        ),
      );
    }

    return _SheetShell(
      bottomInset: MediaQuery.of(context).viewInsets.bottom,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            title: 'Bem-vindo',
            subtitle: 'Faça login',
            onClose: () => Navigator.pop(context),
          ),
          const SizedBox(height: 8),
          Text(
            'Entre com suas credenciais para acessar seus tickets.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Seus dados ficam armazenados apenas neste dispositivo.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _userController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Usuário',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: true,
            onSubmitted: (_) => _login(),
            decoration: const InputDecoration(
              labelText: 'Senha',
              border: OutlineInputBorder(),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _ErrorMessage(message: _error!),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Entrar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.child, this.bottomInset = 0});

  final Widget child;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
          child: child,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.onClose,
  });

  final String title;
  final String subtitle;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
        IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
      ],
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.errorContainer,
      child: ListTile(
        dense: true,
        leading: Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
        title: Text(
          message,
          style: TextStyle(color: colorScheme.onErrorContainer),
        ),
      ),
    );
  }
}
