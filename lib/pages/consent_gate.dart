import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tche_organiza/pages/main_page.dart';
import 'package:tche_organiza/pages/onboarding_page.dart';

class ConsentGate extends StatefulWidget {
  const ConsentGate({super.key});

  @override
  State<ConsentGate> createState() => _ConsentGateState();
}

class _ConsentGateState extends State<ConsentGate> {
  static const String _consentKey = 'app_disclaimer_accepted_v1';
  static const String _onboardingKey = 'onboarding_seen_v1';

  bool? _accepted;
  bool? _onboardingSeen;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool(_consentKey) ?? false;
    final onboardingSeen = prefs.getBool(_onboardingKey) ?? false;
    if (!mounted) return;
    setState(() {
      _accepted = accepted;
      _onboardingSeen = onboardingSeen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_accepted == null || _onboardingSeen == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_onboardingSeen! || !_accepted!) {
      return OnboardingPage(
        onFinish: () {
          setState(() {
            _onboardingSeen = true;
            _accepted = true;
          });
        },
      );
    }

    return const MainPage();
  }
}
