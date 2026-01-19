import 'package:flutter/material.dart';
import 'package:tche_organiza/pages/components/ru_menu_section.dart';

class RuMenuPage extends StatelessWidget {
  const RuMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RuMenuSection(),
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
      ),
    );
  }
}
