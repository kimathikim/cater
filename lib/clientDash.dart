import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'clientBooking.dart';
import 'feedback.dart';
import 'mycontacts.dart';

class ClientDashboard extends StatelessWidget {
  const ClientDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFF00BFA5),
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
      ),
      home: const ClientDashboardPage(),
    );
  }
}

class ClientDashboardPage extends StatefulWidget {
  const ClientDashboardPage({super.key});

  @override
  _ClientDashboardPageState createState() => _ClientDashboardPageState();
}

class _ClientDashboardPageState extends State<ClientDashboardPage> {
  final String baseUrl =
      'https://catermanage-388b2a1ca8bc.herokuapp.com/api/v1';
  final bool _isLoading = true;
  final List<Map<String, dynamic>> _bookings = [];
  final List<Map<String, dynamic>> _notifications = [];
  int _bookingPage = 1;
  int _notificationPage = 1;

  @override
  void initState() {
    super.initState();
    Hive.initFlutter();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    await _fetchBookings();
    await _fetchNotifications();
  }

  Future<void> _fetchBookings() async {
    // Add progressive loading for bookings
    try {
      var box = await Hive.openBox('authBox');
      String? token = box.get('token');
      if (token == null) {
        _showErrorDialog('User not authenticated. Please log in again.');
        return;
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final bookingsResponse = await http.get(
        Uri.parse('$baseUrl/bookings?page=$_bookingPage'),
        headers: headers,
      );
      print(bookingsResponse.body);

      if (bookingsResponse.statusCode == 200) {
        final bookingsData = json.decode(bookingsResponse.body);

        setState(() {
          _bookings.addAll(
              List<Map<String, dynamic>>.from(bookingsData['bookings'][0]));
          _bookingPage++;
        });
      }
      print(_bookings);
    } catch (e) {
      _showErrorDialog('Error fetching bookings: $e');
    }
  }

  Future<void> _fetchNotifications() async {
    // Add progressive loading for notifications
    try {
      var box = await Hive.openBox('authBox');
      String? token = box.get('token');
      if (token == null) {
        _showErrorDialog('User not authenticated. Please log in again.');
        return;
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final notificationsResponse = await http.get(
        Uri.parse('$baseUrl/notifications?page=$_notificationPage'),
        headers: headers,
      );

      if (notificationsResponse.statusCode == 200) {
        final notificationsData = json.decode(notificationsResponse.body);

        setState(() {
          _notifications.addAll(List<Map<String, dynamic>>.from(
              notificationsData['notifications']));
          _notificationPage++;
        });
      }
    } catch (e) {
      _showErrorDialog('Error fetching notifications: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        elevation: 0,
        title: const Text('Welcome, Client',
            style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickActions(),
            const SizedBox(height: 20),
            _buildBookingsSection(),
            const SizedBox(height: 20),
            _buildNotificationsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _quickActionButton(context, Icons.calendar_today,
                    'Make Bookings', const Color(0xFF00D7A3)),
                const SizedBox(width: 20),
                _quickActionButton(context, Icons.rate_review,
                    'Provide Feedback', const Color(0xFFFF8A80)),
                const SizedBox(width: 20),
                _quickActionButton(context, Icons.chat_bubble, 'Communicate',
                    const Color(0xFF4FC3F7)),
                const SizedBox(width: 20),
                _quickActionButton(context, Icons.list_alt, 'Bookings',
                    const Color(0xFFFFB74D)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Upcoming Bookings', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _bookings.length + 1,
          itemBuilder: (context, index) {
            if (index < _bookings.length) {
              return _bookingRow(
                _bookings[index]['event_name'],
                _bookings[index]['event_date'],
                _bookings[index]['guests_count'].toString(),
                _bookings[index]['status'],
              );
            } else {
              return _buildProgressiveLoader(_fetchBookings);
            }
          },
        ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Notifications', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _notifications.length + 1,
          itemBuilder: (context, index) {
            if (index < _notifications.length) {
              return _notificationRow(
                _notifications[index]['message'],
                _notifications[index]['time'],
              );
            } else {
              return _buildProgressiveLoader(_fetchNotifications);
            }
          },
        ),
      ],
    );
  }

  Widget _buildProgressiveLoader(Future<void> Function() fetchMore) {
    return Center(
      child: OutlinedButton(
        onPressed: fetchMore,
        child: const Text('Load More'),
      ),
    );
  }

  Widget _quickActionButton(
      BuildContext context, IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        switch (label) {
          case 'Make Bookings':
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ClientBookingApp()));
            break;
          case 'Provide Feedback':
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const FeedbackPage()));
            break;
          case 'Communicate':
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MessagesPage()));
          default:
            break;
        }
      },
      child: Column(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: color,
            radius: 30.0,
            child: Icon(icon, size: 30.0, color: Colors.white),
          ),
          const SizedBox(height: 10.0),
          Text(label, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _bookingRow(String event, String date, String guests, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(event, style: const TextStyle(color: Colors.black)),
            Text('$date • $guests', style: TextStyle(color: Colors.grey[600])),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'Confirmed'
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: status == 'Confirmed' ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationRow(String message, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(message),
        subtitle: Text(time),
        leading: const Icon(Icons.notifications),
      ),
    );
  }
}
