import 'package:flutter/material.dart';

import 'mai.dart';
import 'mainscreen.dart';

void main() {
  runApp(const CateringM());
}

class CateringM extends StatelessWidget {
  const CateringM({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CaterX',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginApp(),
        '/main': (context) => const MainScreen(),
        // '/main': (context) => const ClientBookingApp(),
        //   '/main': (context) => const ClientDashboard(),
        '/login': (context) => const LoginApp(),
      },
    );
  }
}
