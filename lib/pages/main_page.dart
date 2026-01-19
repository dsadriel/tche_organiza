
import 'package:flutter/material.dart';
import 'package:tche_organiza/pages/ru_menu.dart';
import 'package:tche_organiza/pages/ru_tickets_view.dart';

class MainPage extends StatelessWidget {
  const MainPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    
    final EdgeInsets safePadding = MediaQuery.of(context).padding;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: safePadding.top + 16,
          bottom: safePadding.bottom + 16,
          left: 16,
          right: 16,
        ),
        child: const Column(
          spacing: 32,
          children: [
            RuTicketsView(),
            RuMenu(),
          ],
        ),
      ),
    );
  }
}
