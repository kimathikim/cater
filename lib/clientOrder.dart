import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ClientOrderPlacementApp extends StatelessWidget {
  final bool fromBottomNavBar;

  const ClientOrderPlacementApp({super.key, this.fromBottomNavBar = true});

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
      home: OrderPlacementPage(fromBottomNavBar: fromBottomNavBar),
    );
  }
}

class OrderPlacementPage extends StatefulWidget {
  final bool fromBottomNavBar;

  const OrderPlacementPage({super.key, this.fromBottomNavBar = false});

  @override
  _OrderPlacementPageState createState() => _OrderPlacementPageState();
}

class _OrderPlacementPageState extends State<OrderPlacementPage> {
  final _formKey = GlobalKey<FormState>();
  int _guestCount = 50;
  String _selectedService = 'Buffet Service';
  String _eventLocation = '';
  String _notes = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final String baseUrl =
      'https://catermanage-388b2a1ca8bc.herokuapp.com/api/v1';

  final List<Map<String, dynamic>> _services = [
    {'name': 'Buffet Service', 'price': 1200, 'availability': true},
    {'name': 'Table Setup', 'price': 500, 'availability': true},
    {'name': 'Waitstaff Service', 'price': 800, 'availability': false},
    {'name': 'Decor Service', 'price': 1500, 'availability': true},
  ];

  @override
  void initState() {
    super.initState();
    Hive.initFlutter();
  }

  Future<void> _submitOrder() async {
    if (_formKey.currentState!.validate()) {
      final bookingData = {
        "event_name": _selectedService,
        "event_date": _selectedDate?.toIso8601String(),
        "event_time": "${_selectedTime?.hour}:${_selectedTime?.minute}",
        "event_location": _eventLocation,
        "guest_count": _guestCount,
        "special_instructions": _notes,
      };

      final token = await _getToken(); // Get stored JWT token

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/bookings'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(bookingData),
        );

        if (response.statusCode == 201) {
          _showSuccessDialog();
        } else {
          _showErrorDialog('Failed to place order. Please try again.');
        }
      } catch (e) {
        _showErrorDialog('An error occurred while placing the order: $e');
      }
    }
  }

  Future<String?> _getToken() async {
    // Retrieve stored JWT token for authenticated requests
    var box = await Hive.openBox('authBox');
    return box.get('jwt_token');
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Order Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Your order has been placed successfully!'),
                const SizedBox(height: 10),
                Text('Service: $_selectedService'),
                Text('Guest Count: $_guestCount'),
                Text(
                    'Date: ${_selectedDate?.day}/${_selectedDate?.month}/${_selectedDate?.year}'),
                Text('Time: ${_selectedTime?.hour}:${_selectedTime?.minute}'),
                Text('Event Location: $_eventLocation'),
                Text('Special Requests: $_notes'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
        title:
            const Text('Place an Order', style: TextStyle(color: Colors.white)),
        leading: widget.fromBottomNavBar
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available Services',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildServiceSelection(),
              const SizedBox(height: 20),
              _buildGuestCountSelector(),
              const SizedBox(height: 20),
              _buildDateTimePickers(),
              const SizedBox(height: 20),
              _buildEventLocationField(),
              const SizedBox(height: 20),
              _buildNotesField(),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 30),
                  ),
                  onPressed: _submitOrder,
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: const Text('Submit Order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceSelection() {
    return Column(
      children: _services.map((service) {
        return ListTile(
          leading: Icon(
            service['availability']
                ? Icons.check_circle_outline
                : Icons.cancel_outlined,
            color: service['availability'] ? Colors.green : Colors.red,
          ),
          title: Text(service['name']),
          subtitle: Text('Price: \$${service['price']}'),
          trailing: Radio<String>(
            value: service['name'],
            groupValue: _selectedService,
            onChanged: service['availability']
                ? (value) {
                    setState(() {
                      _selectedService = value!;
                    });
                  }
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGuestCountSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Guest Count',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () {
                setState(() {
                  if (_guestCount > 0) _guestCount--;
                });
              },
            ),
            Text('$_guestCount', style: const TextStyle(fontSize: 16)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                setState(() {
                  _guestCount++;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimePickers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Date & Time',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  _selectedDate == null
                      ? 'Pick Date'
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                ),
                onPressed: () {
                  _pickDate(context);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.access_time_outlined),
                label: Text(
                  _selectedTime == null
                      ? 'Pick Time'
                      : '${_selectedTime!.hour}:${_selectedTime!.minute}',
                ),
                onPressed: () {
                  _pickTime(context);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEventLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Location',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter the event location...',
          ),
          onChanged: (value) {
            _eventLocation = value;
          },
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Special Requests / Notes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter any special requests for the event...',
          ),
          maxLines: 4,
          onChanged: (value) {
            _notes = value;
          },
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
}
