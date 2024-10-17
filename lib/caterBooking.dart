import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ManagerOrdersAndBookingsApp extends StatelessWidget {
  const ManagerOrdersAndBookingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFF00BFA5), // Neutral Teal color
        scaffoldBackgroundColor: const Color(0xFFF9F9F9), // Light gray background
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
          bodySmall: TextStyle(color: Colors.black54),
        ),
      ),
      home: const OrdersAndBookingsPage(),
    );
  }
}

class OrdersAndBookingsPage extends StatefulWidget {
  const OrdersAndBookingsPage({super.key});

  @override
  _OrdersAndBookingsPageState createState() => _OrdersAndBookingsPageState();
}

class _OrdersAndBookingsPageState extends State<OrdersAndBookingsPage> {
  final String baseUrl = 'https://catermanage-388b2a1ca8bc.herokuapp.com/api/v1';
  bool _isLoading = true;
  List<Map<String, String>> _orders = [];
  List<Map<String, dynamic>> _bookings = [];
  String? token;

  @override
  void initState() {
    super.initState();
    Hive.initFlutter();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var box = await Hive.openBox('authBox');
      token = box.get('token');

      if (token == null) {
        _showErrorDialog("Authentication Error", "User not authenticated.");
        return;
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final ordersResponse = await http.get(Uri.parse('$baseUrl/orders'), headers: headers);
      final bookingsResponse = await http.get(Uri.parse('$baseUrl/bookings'), headers: headers);

      if (ordersResponse.statusCode == 200 && bookingsResponse.statusCode == 200) {
        setState(() {
          _orders = List<Map<String, String>>.from(json.decode(ordersResponse.body)['orders']);
          _bookings = List<Map<String, dynamic>>.from(json.decode(bookingsResponse.body)['bookings']);
        });

        var box = await Hive.openBox('managerDataBox');
        await box.put('orders', _orders);
        await box.put('bookings', _bookings);
      } else {
        _showErrorDialog("Data Error", "Failed to fetch orders or bookings.");
      }
    } catch (e) {
      _showErrorDialog("Network Error", "An error occurred: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
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
        title: const Text('Orders and Bookings', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContainer(
                    title: 'Ongoing Orders',
                    child: _buildOrdersList(),
                  ),
                  const SizedBox(height: 20),
                  _buildContainer(
                    title: 'Bookings',
                    child: _buildBookingsList(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildContainer({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return Column(
      children: _orders.map((order) {
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
                Text(
                  'Client: ${order['client']}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('Event: ${order['event']}'),
                Text('Status: ${order['status']}'),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to order details
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BFA5),
                      ),
                      child: const Text('View Details'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        _updateOrderStatus(order);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                      ),
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBookingsList() {
    return Column(
      children: _bookings.map((booking) {
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
                Text(
                  'Event: ${booking['event']}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('Guests: ${booking['guestCount']}'),
                Text('Caterers: ${booking['caterers'].join(', ')}'),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to booking details
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BFA5),
                      ),
                      child: const Text('View Details'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        _updateBookingStatus(booking);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text('Complete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _updateOrderStatus(Map<String, String> order) async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('$baseUrl/orders/${order['orderId']}/status');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = json.encode({'status': 'Confirmed'});

    try {
      final response = await http.patch(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        setState(() {
          order['status'] = 'Confirmed';
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Order for ${order['client']} confirmed!'),
          duration: const Duration(seconds: 2),
        ));
      } else {
        _showErrorDialog("Update Error", "Failed to update order status.");
      }
    } catch (e) {
      _showErrorDialog("Network Error", "An error occurred: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _updateBookingStatus(Map<String, dynamic> booking) async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('$baseUrl/bookings/${booking['bookingId']}');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = json.encode({'status': 'Completed'});

    try {
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        setState(() {
          booking['status'] = 'Completed';
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Booking for ${booking['event']} completed!'),
          duration: const Duration(seconds: 2),
        ));
      } else {
        _showErrorDialog("Update Error", "Failed to update booking status.");
      }
    } catch (e) {
      _showErrorDialog("Network Error", "An error occurred: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }
}

