import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(const NotificationsPageApp());
}

class NotificationsPageApp extends StatelessWidget {
  const NotificationsPageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFF00BFA5),
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
          bodySmall: TextStyle(color: Colors.black54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BFA5), // Teal green
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const NotificationsPage(),
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<Map<String, String>> _notifications = [
    {
      "type": "order",
      "title": "New Order: Wedding Catering",
      "date": "Dec 25, 2023"
    },
    {
      "type": "booking",
      "title": "New Booking: Corporate Event",
      "date": "Jan 15, 2024"
    },
    {
      "type": "message",
      "title": "Unread Message from Client",
      "date": "Today"
    },
  ];

  final List<Map<String, String>> _readNotifications = [];

  void _markAsRead(int index) {
    setState(() {
      _readNotifications.add(_notifications[index]);
      _notifications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSendNotificationButtons(),
            const SizedBox(height: 20),
            const Text(
              'Recent Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _notifications.isNotEmpty
                  ? AnimatedList(
                      initialItemCount: _notifications.length,
                      itemBuilder: (context, index, animation) {
                        return _buildNotificationItem(context, index, animation);
                      },
                    )
                  : const Center(
                      child: Text('No new notifications', style: TextStyle(color: Colors.black54)),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, int index, Animation<double> animation) {
    final notification = _notifications[index];

    return SlideTransition(
      position: animation.drive(Tween(begin: const Offset(1, 0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeInOut))),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildNotificationIcon(notification['type']!),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification['title']!,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notification['date']!,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.check_circle, color: Color(0xFF00BFA5)),
                onPressed: () {
                  _markAsRead(index);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(String type) {
    IconData icon;
    Color iconColor;

    switch (type) {
      case 'order':
        icon = FontAwesomeIcons.shoppingCart;
        iconColor = const Color(0xFF00BFA5); // Teal for orders
        break;
      case 'booking':
        icon = FontAwesomeIcons.calendarCheck;
        iconColor = const Color(0xFF00BFA5); // Teal for bookings
        break;
      case 'message':
        icon = FontAwesomeIcons.envelope;
        iconColor = const Color(0xFF00BFA5); // Teal for messages
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.2),
      child: Icon(icon, color: iconColor),
    );
  }

  Widget _buildSendNotificationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // Logic to send notification to client
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notification sent to client!')),
            );
          },
          icon: const Icon(FontAwesomeIcons.solidPaperPlane),
          label: const Text('Send to Client'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BFA5),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            // Logic to send notification to caterer
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notification sent to caterer!')),
            );
          },
          icon: const Icon(FontAwesomeIcons.userTie),
          label: const Text('Send to Caterer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BFA5),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          ),
        ),
      ],
    );
  }
}

