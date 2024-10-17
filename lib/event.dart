import 'package:flutter/material.dart';

class EventSchedulingPage extends StatelessWidget {
  const EventSchedulingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Scheduling'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Event Scheduling Page'),
            ElevatedButton(
              onPressed: () {
                // Event scheduling logic here
              },
              child: const Text('Add Event'),
            ),
          ],
        ),
      ),
    );
  }
}

