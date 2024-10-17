import 'package:flutter/material.dart';

class NotificationsApp extends StatelessWidget {
  const NotificationsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFF00BFA5), // Neutral Teal color
        scaffoldBackgroundColor:
            const Color(0xFFF9F9F9), // Light gray background
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
          bodySmall: TextStyle(color: Colors.black54),
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
  final List<Map<String, dynamic>> _notifications = [
    {
      'type': 'New Booking',
      'message': 'New Booking Confirmed: Corporate Event - Dec 25, 2023',
      'isRead': false,
    },
    {
      'type': 'Order Update',
      'message': 'Order #1234 has been updated to Confirmed',
      'isRead': false,
    },
    {
      'type': 'Task Update',
      'message': 'Task for Corporate Event marked as Completed',
      'isRead': false,
    },
    {
      'type': 'Unread Message',
      'message': 'You have 1 unread message from Alice Johnson',
      'isRead': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        elevation: 0,
        title:
            const Text('Notifications', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationCategory(
                'New Bookings', _getNotificationsByType('New Booking')),
            const SizedBox(height: 20),
            _buildNotificationCategory(
                'Order Updates', _getNotificationsByType('Order Update')),
            const SizedBox(height: 20),
            _buildNotificationCategory(
                'Task Updates', _getNotificationsByType('Task Update')),
            const SizedBox(height: 20),
            _buildNotificationCategory(
                'Unread Messages', _getNotificationsByType('Unread Message')),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getNotificationsByType(String type) {
    return _notifications
        .where((notification) => notification['type'] == type)
        .toList();
  }

  Widget _buildNotificationCategory(
      String title, List<Map<String, dynamic>> notifications) {
    return notifications.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Column(
                children: notifications.map((notification) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notification['message']),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (!notification['isRead'])
                                ElevatedButton(
                                  onPressed: () {
                                    _markAsRead(notification);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00BFA5),
                                  ),
                                  child: const Text('Mark as Read'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          )
        : Container();
  }

  void _markAsRead(Map<String, dynamic> notification) {
    setState(() {
      notification['isRead'] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Marked as read: ${notification['message']}'),
      duration: const Duration(seconds: 2),
    ));
  }
}
