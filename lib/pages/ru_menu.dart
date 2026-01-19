import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tche_organiza/models/ru_menu_data.dart';
import 'package:intl/intl.dart';

class RuMenu extends StatefulWidget {
  const RuMenu({super.key});

  @override
  State<RuMenu> createState() => _RuMenuState();
}

class _RuMenuState extends State<RuMenu> {
  late String selectedDay;
  late Future<RuMenuData?> menuDataFuture;

  @override
  void initState() {
    super.initState();
    selectedDay = DateFormat.EEEE().format(DateTime.now()).toLowerCase();
    selectedDay = ['sunday', 'saturday'].contains(selectedDay)
        ? 'monday'
        : selectedDay;
    menuDataFuture = fetchMenuData();
  }

  Future<RuMenuData?> fetchMenuData() async {
    final url = Uri.parse(
      'https://www.inf.ufrgs.br/~adsouza/utils/ru-menu/api/',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Handle successful response
        Map<String, dynamic> userMap = jsonDecode(response.body);
        return RuMenuData.fromJson(userMap);
      } else {
        // Handle error
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text('Cardápio'), _buildBody()],
    );
  }

  FutureBuilder<RuMenuData?> _buildBody() {
    return FutureBuilder(
      future: menuDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          Text('erro');
        }

        final ruMenu = snapshot.data!;

        return Center(
          child: Column(
            spacing: 32,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Período:\n${ruMenu.metadata.weekPeriod}'),
                  ),

                  DropdownMenu(
                    initialSelection: selectedDay,
                    onSelected: (value) {
                      setState(() {
                        selectedDay = value!;
                      });
                    },
                    dropdownMenuEntries: [
                      DropdownMenuEntry(value: 'monday', label: 'Segunda'),
                      DropdownMenuEntry(value: 'tuesday', label: 'Terça'),
                      DropdownMenuEntry(value: 'wednesday', label: 'Quarta'),
                      DropdownMenuEntry(value: 'thursday', label: 'Quinta'),
                      DropdownMenuEntry(value: 'friday', label: 'Sexta'),
                    ],
                  ),
                ],
              ),

              Column(
                children:
                    ruMenu.menus[selectedDay]?.lunch.map((e) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          spacing: 12,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Almoço',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              e.items.join('\n'),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'Disponível em: ${e.availableAt.join(', ')}',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }).toList() ??
                    [],
              ),

              Column(
                children:
                    ruMenu.menus[selectedDay]?.dinner.map((e) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          spacing: 12,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Janta',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              e.items.join('\n'),
                              textAlign: TextAlign.center,
                            ),
                            Text('Disponível em: ${e.availableAt.join(', ')}'),
                          ],
                        ),
                      );
                    }).toList() ??
                    [],
              ),
              Text(
                'As informações do cardápio são fornecidas como referência e podem estar sujeitas a alterações.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
