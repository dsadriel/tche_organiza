import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tche_organiza/pages/login.dart';
import 'package:tche_organiza/services/credential_storage.dart';
import 'package:tche_organiza/services/ru_ticket.dart';

class RuTicketsController {
  VoidCallback? _reload;
  VoidCallback? _openCredentials;

  void reload() => _reload?.call();

  void openCredentials() => _openCredentials?.call();
}

class RuTicketsSection extends StatefulWidget {
  const RuTicketsSection({super.key, this.controller});

  final RuTicketsController? controller;

  @override
  State<RuTicketsSection> createState() => _RuTicketsSectionState();
}

class _RuTicketsSectionState extends State<RuTicketsSection> {
  bool _loading = true;
  bool _credentialsMissing = false;
  bool _apiRefreshFailed = false;
  String? _error;
  Map<String, int>? _tickets;

  @override
  void initState() {
    super.initState();
    _bindController();
    _loadTickets();
  }

  @override
  void didUpdateWidget(covariant RuTicketsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._reload = null;
      oldWidget.controller?._openCredentials = null;
      _bindController();
    }
  }

  @override
  void dispose() {
    widget.controller?._reload = null;
    widget.controller?._openCredentials = null;
    super.dispose();
  }

  void _bindController() {
    widget.controller?._reload = _loadTickets;
    widget.controller?._openCredentials = _openCredentialsSheet;
  }

  Future<void> _loadTickets() async {
    setState(() {
      _loading = true;
      _apiRefreshFailed = false;
      _error = null;
    });

    try {
      final creds = await CredentialsStorage.load();
      if (creds == null) {
        setState(() {
          _credentialsMissing = true;
          _tickets = null;
          _loading = false;
        });
        return;
      }

      final (user, password) = creds;

      await for (final response in RUTicketService().getTicketCountsWithCache(
        usuario: user,
        senha: password,
      )) {
        final sortedTickets = Map.fromEntries(
          response.ticketCounts.entries.toList()
            ..sort((a, b) => a.value.compareTo(b.value)),
        );

        if (!mounted) return;

        setState(() {
          _credentialsMissing = false;
          _tickets = sortedTickets;
          _apiRefreshFailed = response.refreshFailed;
          _loading = response.isFromCache && !response.refreshFailed;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Não foi possível carregar os tickets';
        _apiRefreshFailed = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _openCredentialsSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const CredentialsLoginView(),
    );
    if (!mounted) return;
    _loadTickets();
  }

  Future<void> _openPurchaseLink() async {
    final url = Uri.parse(
      'https://www1.ufrgs.br/CatalogoServicos/servicos/acesso-servico?servico=4797',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o link de compra')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tickets RU', style: textTheme.titleLarge),
        const SizedBox(height: 12),
        if (_tickets != null && _tickets!.isNotEmpty) ...[
          ..._tickets!.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                elevation: 0,
                child: ListTile(
                  title: Text(
                    entry.key,
                    style: textTheme.titleLarge?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${entry.value} usos',
                        style: textTheme.titleMedium?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (_loading) ...[
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ] else if (_apiRefreshFailed) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.cloud_off,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ] else if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_error != null)
          _MessageCard(
            message: _error!,
            icon: Icons.error_outline,
            color: colorScheme.errorContainer,
            onColor: colorScheme.onErrorContainer,
          )
        else if (_credentialsMissing)
          _MessageCard(
            message: 'Credenciais não informadas',
            icon: Icons.info_outline,
            color: colorScheme.surfaceContainerHighest,
            onColor: colorScheme.onSurfaceVariant,
            onTap: _openCredentialsSheet,
          )
        else
          _MessageCard(
            message: 'Seus tickets acabaram, clique aqui para comprar',
            icon: Icons.shopping_cart_outlined,
            color: colorScheme.primaryContainer,
            onColor: colorScheme.onPrimaryContainer,
            onTap: _openPurchaseLink,
          ),
      ],
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.message,
    required this.icon,
    required this.color,
    required this.onColor,
    this.onTap,
  });

  final String message;
  final IconData icon;
  final Color color;
  final Color onColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: onColor),
        title: Text(message, style: TextStyle(color: onColor)),
        trailing: onTap != null
            ? Icon(Icons.chevron_right, color: onColor)
            : null,
      ),
    );
  }
}
