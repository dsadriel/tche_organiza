import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:tche_organiza/models/ru_menu_data.dart';

class RuMenuController {
  VoidCallback? _reload;

  void reload() => _reload?.call();
}

class RuMenuSection extends StatefulWidget {
  const RuMenuSection({super.key, this.controller});

  final RuMenuController? controller;

  @override
  State<RuMenuSection> createState() => _RuMenuSectionState();
}

class _RuMenuSectionState extends State<RuMenuSection> {
  late String _selectedDay;
  late Future<RuMenuData?> _menuDataFuture;
  int _selectedMeal = 0;

  final Map<String, String> _dayLabels = {
    'monday': 'Seg',
    'tuesday': 'Ter',
    'wednesday': 'Qua',
    'thursday': 'Qui',
    'friday': 'Sex',
  };

  @override
  void initState() {
    super.initState();
    _bindController();
    _selectedDay = DateFormat.EEEE().format(DateTime.now()).toLowerCase();
    _selectedDay = ['sunday', 'saturday'].contains(_selectedDay)
        ? 'monday'
        : _selectedDay;
    _menuDataFuture = _fetchMenuData();
  }

  @override
  void didUpdateWidget(covariant RuMenuSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._reload = null;
      _bindController();
    }
  }

  @override
  void dispose() {
    widget.controller?._reload = null;
    super.dispose();
  }

  void _bindController() {
    widget.controller?._reload = _reloadMenu;
  }

  void _reloadMenu() {
    setState(() {
      _menuDataFuture = _fetchMenuData();
    });
  }

  Future<RuMenuData?> _fetchMenuData() async {
    final url = Uri.parse(
      'https://www.inf.ufrgs.br/~adsouza/utils/ru-menu/api/',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final userMap = jsonDecode(response.body) as Map<String, dynamic>;
        return RuMenuData.fromJson(userMap);
      }
      throw Exception('Erro ao carregar cardápio');
    } on SocketException {
      rethrow;
    } catch (_) {
      throw Exception('Erro ao carregar cardápio');
    }
  }

  String _mealLabel() => _selectedMeal == 0 ? 'Almoço' : 'Jantar';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<RuMenuData?>(
      future: _menuDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          final isOffline = snapshot.error is SocketException;
          return _MenuErrorMessage(
            icon: isOffline ? Icons.cloud_off : Icons.error_outline,
            message: isOffline
                ? "Bah! Você está sem internet! Não foi possível carregar o cardápio"
                : "Barbaridade! Algo deu errado, não foi possível carregar o cardápio",
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const _MenuErrorMessage(
            icon: Icons.error_outline,
            message:
                'Barbaridade! Algo deu errado, não foi possível carregar o cardápio',
          );
        }

        final ruMenu = snapshot.data!;
        final dayMenu = ruMenu.menus[_selectedDay];
        final menuOptions = dayMenu == null
            ? <MenuOption>[]
            : (_selectedMeal == 0 ? dayMenu.lunch : dayMenu.dinner);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Cardápio', style: textTheme.titleLarge)),
                Text(
                  ruMenu.metadata.weekPeriod,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _dayLabels.entries.map((entry) {
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: _selectedDay == entry.key,
                  onSelected: (_) => setState(() => _selectedDay = entry.key),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Almoço')),
                ButtonSegment(value: 1, label: Text('Jantar')),
              ],
              selected: {_selectedMeal},
              onSelectionChanged: (selection) {
                setState(() => _selectedMeal = selection.first);
              },
            ),
            const SizedBox(height: 12),
            if (menuOptions.isEmpty)
              Text('Nenhum item disponível para ${_mealLabel()}')
            else
              ...menuOptions.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 0,
                      color: colorScheme.surfaceContainerLow,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Disponível em: ${option.availableAt.join(', ')}',
                              style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...option.items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Text(item),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MenuErrorMessage extends StatelessWidget {
  const _MenuErrorMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
