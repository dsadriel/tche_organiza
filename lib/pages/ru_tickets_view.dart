import 'package:flutter/material.dart';
import 'package:tche_organiza/pages/login.dart';
import 'package:tche_organiza/services/credential_storage.dart';
import 'package:tche_organiza/services/ru_ticket.dart';

class RuTicketsView extends StatefulWidget {
  const RuTicketsView({super.key});

  @override
  State<RuTicketsView> createState() => _RuTicketsViewState();
}

class _RuTicketsViewState extends State<RuTicketsView> {
  final _service = UFRGSRuTickets();

  bool _loading = false;
  bool _credentialsMissing = false;
  String? _error;
  Map<String, int>? _tickets;

  Future<void> _loadTickets() async {
    setState(() {
      _loading = true;
      _credentialsMissing = false;
      _error = null;
      _tickets = null;
    });

    try {
      final creds = await CredentialsStorage.load();

      if (creds == null) {
        setState(() {
          _credentialsMissing = true;
          _loading = false;
        });
        return;
      }

      final (user, password) = creds!;
      var result = await _service.loginAndFetchTicketCounts(
        usuario: user,
        senha: password,
      );

      setState(() {
        _tickets = result;
      });
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
  void initState() {
    super.initState();
    _loadTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Seus tickets'),
        _buildBody()
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_credentialsMissing) {
      return GestureDetector(
        onTap: () {
          showBottomSheet(
            context: context,
            builder: (context) {
              return CredentialsLoginView();
            },
          ).closed.then((value) {
            // Called when bottom sheet is dismissed
            _loadTickets();
          });
        },
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Registre suas credenciais',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' para consultar seus tickets'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTickets,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_tickets == null || _tickets!.isEmpty) {
      return const Center(child: Text('Nenhum ticket encontrado'));
    }

    return Column(
      children: _tickets!.entries.map((entry) {
        return Card(
          child: ListTile(
            title: Text(entry.key),
            trailing: Text(
              entry.value.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }
}
