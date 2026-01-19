import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tche_organiza/pages/main_page.dart';

class ConsentGate extends StatefulWidget {
  const ConsentGate({super.key});

  @override
  State<ConsentGate> createState() => _ConsentGateState();
}

class _ConsentGateState extends State<ConsentGate> {
  static const String _consentKey = 'app_disclaimer_accepted_v1';

  bool? _accepted;
  bool _agreeChecked = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadConsent();
  }

  Future<void> _loadConsent() async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool(_consentKey) ?? false;
    if (!mounted) return;
    setState(() => _accepted = accepted);
  }

  Future<void> _saveConsent(bool value) async {
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, value);
    if (!mounted) return;
    setState(() {
      _accepted = value;
      _saving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_accepted == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_accepted == true) {
      return const MainPage();
    }

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Card(
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Aviso importante', style: textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Text(
                        'Este app não possui relação oficial com a UFRGS e é fornecido apenas para fins de estudo.',
                        textAlign: TextAlign.justify,
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'As credenciais ficam salvas no seu dispositivo e não são enviadas para terceiros.',
                        textAlign: TextAlign.justify,
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Elas são usadas somente para autenticação no portal da UFRGS.',
                        textAlign: TextAlign.justify,
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        value: _agreeChecked,
                        onChanged: _saving
                            ? null
                            : (value) {
                                setState(() => _agreeChecked = value ?? false);
                              },
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Li e concordo com os termos acima.'),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: (!_agreeChecked || _saving)
                              ? null
                              : () => _saveConsent(true),
                          child: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Concordar e entrar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
