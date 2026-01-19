import 'package:flutter/material.dart';
import 'package:tche_organiza/pages/components/ru_menu_section.dart';
import 'package:tche_organiza/pages/components/ru_tickets_section.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _ticketsController = RuTicketsController();
  final _menuController = RuMenuController();

  void _refreshAll() {
    _ticketsController.reload();
    _menuController.reload();
  }

  void _openCredentials() {
    _ticketsController.openCredentials();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            text: 'TchêOrganiza ',
            children: [
              TextSpan(
                text: '(beta)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: _openCredentials,
            icon: const Icon(Icons.manage_accounts),
            tooltip: 'Gerenciar credenciais',
          ),
          IconButton(
            onPressed: _refreshAll,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar tudo',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            RuTicketsSection(controller: _ticketsController),
            const SizedBox(height: 20),
            RuMenuSection(controller: _menuController),
            const SizedBox(height: 24),
            Text(
              'Este app não tem relação oficial com a UFRGS e é fornecido no estado em que se encontra (as is).',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
