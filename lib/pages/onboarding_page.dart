import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingPage({super.key, required this.onFinish});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _termsAccepted = false;

  final List<_OnboardingItem> _items = [
    _OnboardingItem(
      title: 'Cardápio do RU',
      description: 'Veja o que vai rolar no RU hoje. Almoço e jantar sempre atualizados.',
      icon: Icons.restaurant_menu,
      color: Colors.orange,
    ),
    _OnboardingItem(
      title: 'Tickets em Tempo Real',
      description: 'Acompanhe seu saldo e veja seus tickets ativos sem precisar abrir o portal.',
      icon: Icons.confirmation_number,
      color: Colors.blue,
    ),
    _OnboardingItem(
      title: 'Xô, Perrengue!',
      description: 'Tudo fica salvo offline. Mesmo sem internet na fila, seu ticket estará lá.',
      icon: Icons.offline_pin,
      color: Colors.green,
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen_v1', true);
    await prefs.setBool('app_disclaimer_accepted_v1', true);
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final totalPages = _items.length + 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: totalPages,
                itemBuilder: (context, index) {
                  if (index == _items.length) {
                    return _buildTermsPage(context, textTheme, colorScheme);
                  }

                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.icon,
                            size: 100,
                            color: item.color,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          item.title,
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item.description,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(
                      totalPages,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? colorScheme.primary
                              : colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  // Button
                  if (_currentPage == totalPages - 1)
                    FilledButton(
                      onPressed: _termsAccepted ? _completeOnboarding : null,
                      child: const Text('Começar'),
                    )
                  else
                    IconButton.filledTonal(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.arrow_forward),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsPage(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.gavel_rounded,
            size: 64,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            'Aviso importante',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Este app não possui relação oficial com a UFRGS e é fornecido apenas para fins de estudo.',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'As credenciais ficam salvas no seu dispositivo e não são enviadas para terceiros.',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Elas são usadas somente para autenticação no portal da UFRGS.',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: colorScheme.surfaceContainerLow,
            child: CheckboxListTile(
              value: _termsAccepted,
              onChanged: (value) => setState(() => _termsAccepted = value ?? false),
              title: const Text('Li e concordo com os termos acima.'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
