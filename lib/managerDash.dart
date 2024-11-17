import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'managerBooking.dart';
import 'communication.dart';

class CateringDashboard extends StatelessWidget {
  const CateringDashboard({super.key});

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
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final String baseUrl =
      'https://catermanage-388b2a1ca8bc.herokuapp.com/api/v1';
  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> _orders = [];
  bool _isLoadingBookings = true;
  bool _isLoadingOrders = true;

  @override
  void initState() {
    super.initState();
    Hive.initFlutter();
    _fetchDashboardData();
  }

  Future<String?> _getToken() async {
    var box = await Hive.openBox('authBox');
    return box.get('token');
  }

  Future<void> _fetchDashboardData() async {
    await _fetchBookings();
    await _fetchOrders();
  }

  Future<void> _fetchUserProfile() async {
    String? token = await _getToken();
    if (token == null) {
      _showMessage('User not authenticated. Please log in.');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        var box = await Hive.openBox('userBox');
        await box.put('userName', data['name']);
        await box.put('userId', data['id']);
        _showMessage('User profile loaded successfully!');
      } else {
        _showMessage('Failed to load user profile: ${response.body}');
      }
    } catch (e) {
      _showMessage('Error loading user profile: $e');
    }
  }

  Future<void> _fetchBookings() async {
    String? token = await _getToken();
    if (token == null) {
      _showMessage('User not authenticated. Please log in.');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bookings/all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _bookings = List<Map<String, dynamic>>.from(data['bookings'][0]);
          _isLoadingBookings = false;
        });
      } else {
        _showMessage('Failed to fetch bookings: ${response.body}');
      }
    } catch (e) {
      _showMessage('Error fetching bookings: $e');
    }
  }

  Future<void> _fetchOrders() async {
    String? token = await _getToken();
    if (token == null) {
      _showMessage('User not authenticated. Please log in.');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _orders = List<Map<String, dynamic>>.from(data['orders']);
          _isLoadingOrders = false;
        });
      } else {
        _showMessage('Failed to fetch orders: ${response.body}');
      }
    } catch (e) {
      _showMessage('Error fetching orders: $e');
    }
  }

  Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
    String? token = await _getToken();
    if (token == null) {
      _showMessage('User not authenticated. Please log in.');
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/bookings/$bookingId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        _showMessage('Booking status updated successfully!');
        await _fetchBookings(); // Refresh bookings data
      } else {
        _showMessage('Failed to update booking status: ${response.body}');
      }
    } catch (e) {
      _showMessage('Error updating booking status: $e');
    }
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    String? token = await _getToken();
    if (token == null) {
      _showMessage('User not authenticated. Please log in.');
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/bookings/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        _showMessage('Booking status updated successfully!');
        await _fetchOrders(); // Refresh orders data
      } else {
        _showMessage('Failed to update order status: ${response.body}');
      }
    } catch (e) {
      _showMessage('Error updating order status: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Welcome, Manager',
                style: TextStyle(color: Colors.white)),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickActionsSection(context),
              const SizedBox(height: 20),
              _sectionWithViewMore('Upcoming Bookings', _buildBookingsCard()),
              const SizedBox(height: 20),
              _sectionWithViewMore('Pending Orders', _buildPendingOrdersCard()),
              const SizedBox(height: 20),
              _sectionWithViewMore(
                  'Recent Notifications', _buildNotificationsCard()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Quick Actions',
                  style: TextStyle(fontSize: 18, color: Colors.black)),
              TextButton(onPressed: () {}, child: const Text('View More'))
            ],
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 20,
            children: [
              _quickActionButton(context, Icons.receipt_long, 'View Orders',
                  const Color(0xFFB39DDB)),
              _quickActionButton(context, Icons.calendar_today, 'View Bookings',
                  const Color(0xFF00D7A3)),
              _quickActionButton(context, Icons.assignment_ind, 'Assign Tasks',
                  const Color(0xFFFF8A80)),
              _quickActionButton(context, Icons.check_circle, 'Confirm Tasks',
                  const Color(0xFF81C784)),
              _quickActionButton(context, Icons.update, 'Provide Updates',
                  const Color(0xFF4FC3F7)),
              _quickActionButton(context, Icons.chat_bubble, 'Communicate',
                  const Color(0xFFFFB74D)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionWithViewMore(String title, Widget child) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 18, color: Colors.black)),
            TextButton(onPressed: () {}, child: const Text('View More'))
          ],
        ),
        child,
      ],
    );
  }

  Widget _quickActionButton(
      BuildContext context, IconData icon, String label, Color color) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            switch (label) {
              // case 'View Orders':
              //   Navigator.push(context,
              //       MaterialPageRoute(builder: (context) => OrdersPage()));
              //   break;
              case 'View Bookings':
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManagerBookingsPage()));
                break;
              // case 'Assign Tasks':
              //   Navigator.push(context,
              //       MaterialPageRoute(builder: (context) => AssignTasksPage()));
              //   break;
              // case 'Confirm Tasks':
              //   Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => ConfirmTasksPage()));
              //   break;
              // case 'Provide Updates':
              //   Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => ProvideUpdatesPage()));
              //   break;
                          }
          },
          child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(20),
              child: Icon(icon, color: Colors.white, size: 20)),
        ),
        const SizedBox(height: 10),
        Text(label,
            style: const TextStyle(color: Colors.black, fontSize: 10),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildBookingsCard() {
    if (_isLoadingBookings) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_bookings.isEmpty) {
      return const Center(child: Text('No bookings available.'));
    }
    return _infoCard(
      _bookings.map((booking) {
        return GestureDetector(
          child: _bookingRow(
            booking['event_name'],
            booking['event_date'],
            '${booking['guest_count']} guests',
            booking['status'],
            booking['status'] == 'Confirmed'
                ? const Color(0xFF81C784)
                : const Color(0xFFFFB74D),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPendingOrdersCard() {
    if (_isLoadingOrders) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_orders.isEmpty) {
      return const Center(child: Text('No orders available.'));
    }
    return _infoCard(
      _orders.map((order) {
        return GestureDetector(
          onTap: () => _updateOrderStatus(order['id'], 'Completed'),
          child: _orderRow(
            order['order_number'],
            order['event_name'],
            order['event_date'],
            order['status'],
            order['status'] == 'In Progress'
                ? const Color(0xFF81C784)
                : const Color(0xFFFFB74D),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotificationsCard() {
    return _infoCard(
      [
        _notificationRow('New Booking: Corporate Luncheon', '10 minutes ago'),
        _notificationRow(
            'Task Completed: Setup for Wedding Reception', '1 hour ago'),
      ],
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _bookingRow(String event, String date, String guests, String status,
      Color statusColor) {
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
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(status, style: TextStyle(color: statusColor)),
          ),
        ],
      ),
    );
  }

  Widget _orderRow(String orderId, String event, String date, String status,
      Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(orderId, style: const TextStyle(color: Colors.black)),
              Text('$event • $date', style: TextStyle(color: Colors.grey[600])),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(status, style: TextStyle(color: statusColor)),
          ),
        ],
      ),
    );
  }

  Widget _notificationRow(String message, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Flexible(
            child: Text(message, style: const TextStyle(color: Colors.black)),
          ),
          Text(time, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
