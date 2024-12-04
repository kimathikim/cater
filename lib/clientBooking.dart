import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ClientBookingApp extends StatelessWidget {
  final bool fromBottomNavBar;

  const ClientBookingApp({Key? key, this.fromBottomNavBar = true})
      : super(key: key);

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
      home: BookingSystemPage(fromBottomNavBar: fromBottomNavBar),
    );
  }
}

class BookingSystemPage extends StatefulWidget {
  final bool fromBottomNavBar;

  const BookingSystemPage({Key? key, this.fromBottomNavBar = false})
      : super(key: key);

  @override
  _BookingSystemPageState createState() => _BookingSystemPageState();
}

class _BookingSystemPageState extends State<BookingSystemPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _eventName = '';
  String _eventLocation = '';
  int _guestCount = 50;
  String _specialInstructions = '';
  double _totalCost = 0.0;

  // Services with pricing (in dollars per guest)
  final List<Map<String, dynamic>> _services = [
    {'name': 'Buffet Service', 'pricePerGuest': 20.0, 'selected': false},
    {'name': 'Plated Dinner', 'pricePerGuest': 25.0, 'selected': false},
    {'name': 'Cocktail Reception', 'pricePerGuest': 15.0, 'selected': false},
    {'name': 'Beverage Service', 'pricePerGuest': 10.0, 'selected': false},
  ];

  // Event Setup options (fixed price)
  final List<Map<String, dynamic>> _eventSetup = [
    {'name': 'Tent Setup', 'price': 500.0, 'selected': false},
    {'name': 'Stage Setup', 'price': 300.0, 'selected': false},
    {'name': 'Lighting & Sound', 'price': 400.0, 'selected': false},
    {'name': 'Tables & Chairs', 'price': 250.0, 'selected': false},
    {'name': 'Decorations', 'price': 350.0, 'selected': false},
  ];

  // Entertainment options (fixed price)
  final List<Map<String, dynamic>> _entertainment = [
    {'name': 'DJ/Live Band', 'price': 600.0, 'selected': false},
    {'name': 'Photo Booth', 'price': 200.0, 'selected': false},
    {'name': 'Master of Ceremony', 'price': 300.0, 'selected': false},
    {'name': 'Fireworks Display', 'price': 800.0, 'selected': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        elevation: 0,
        leading: widget.fromBottomNavBar
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
        title: const Text('Book Catering & Event Services',
            style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEventNameField(),
                  _buildEventDetails(),
                  _buildSpecialInstructionsField(),
                  _buildServicesSelection(),
                  _buildEventSetupSelection(),
                  _buildEntertainmentSelection(),
                  _buildPriceBreakdown(),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
          _buildFloatingTotalCost(),
        ],
      ),
    );
  }

  Widget _buildEventNameField() {
    return _buildContainer(
      title: 'Event Name',
      child: TextFormField(
        style: const TextStyle(color: Colors.black),
        decoration: const InputDecoration(
          labelText: 'Name of the Event',
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) => _eventName = value,
      ),
    );
  }

  Widget _buildEventDetails() {
    return _buildContainer(
      title: 'Event Details',
      child: Column(
        children: [
          TextFormField(
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              labelText: 'Event Location',
              labelStyle: TextStyle(color: Colors.black),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _eventLocation = value,
          ),
          const SizedBox(height: 10),
          _buildNumberPicker('Guest Count:', _guestCount, (newValue) {
            setState(() {
              _guestCount = newValue;
              _calculateTotalCost();
            });
          }),
          _buildDateTimePickers(),
        ],
      ),
    );
  }

  Widget _buildSpecialInstructionsField() {
    return _buildContainer(
      title: 'Special Instructions',
      child: TextFormField(
        style: const TextStyle(color: Colors.black),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter any special instructions for the event...',
        ),
        maxLines: 4,
        onChanged: (value) => _specialInstructions = value,
      ),
    );
  }

  Widget _buildServicesSelection() {
    return _buildContainer(
      title: 'Select Catering Services (Price per Guest)',
      child: Column(
        children: _services.map((service) {
          return CheckboxListTile(
            title: Text(
              '${service['name']} (\$${service['pricePerGuest']} per guest)',
              style: const TextStyle(color: Colors.black),
            ),
            value: service['selected'],
            onChanged: (bool? value) {
              setState(() {
                service['selected'] = value ?? false;
                _calculateTotalCost();
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEventSetupSelection() {
    return _buildContainer(
      title: 'Select Event Setup Options (Fixed Price)',
      child: Column(
        children: _eventSetup.map((setup) {
          return CheckboxListTile(
            title: Text(
              '${setup['name']} (\$${setup['price']})',
              style: const TextStyle(color: Colors.black),
            ),
            value: setup['selected'],
            onChanged: (bool? value) {
              setState(() {
                setup['selected'] = value ?? false;
                _calculateTotalCost();
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEntertainmentSelection() {
    return _buildContainer(
      title: 'Select Entertainment Options (Fixed Price)',
      child: Column(
        children: _entertainment.map((entertainment) {
          return CheckboxListTile(
            title: Text(
              '${entertainment['name']} (\$${entertainment['price']})',
              style: const TextStyle(color: Colors.black),
            ),
            value: entertainment['selected'],
            onChanged: (bool? value) {
              setState(() {
                entertainment['selected'] = value ?? false;
                _calculateTotalCost();
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return _buildContainer(
      title: 'Price Breakdown',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._services
              .where((service) => service['selected'])
              .map((service) => Text(
                    '${service['name']} (\$${service['pricePerGuest']} per guest) x $_guestCount guests = \$${service['pricePerGuest'] * _guestCount}',
                    style: const TextStyle(color: Colors.black),
                  )),
          ..._eventSetup
              .where((setup) => setup['selected'])
              .map((setup) => Text(
                    '${setup['name']} = \$${setup['price']}',
                    style: const TextStyle(color: Colors.black),
                  )),
          ..._entertainment
              .where((entertainment) => entertainment['selected'])
              .map((entertainment) => Text(
                    '${entertainment['name']} = \$${entertainment['price']}',
                    style: const TextStyle(color: Colors.black),
                  )),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00BFA5),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        ),
        onPressed: _submitBooking,
        icon: const Icon(Icons.calendar_today_outlined),
        label: const Text('Submit Booking'),
      ),
    );
  }

  Widget _buildFloatingTotalCost() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Material(
        color: Colors.white,
        elevation: 6.0,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Total Cost: \$$_totalCost',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildContainer({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildNumberPicker(
      String label, int value, ValueChanged<int> onChanged) {
    return Row(
      children: [
        Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 16, color: Colors.black))),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: () => onChanged(value > 0 ? value - 1 : 0),
        ),
        Text('$value',
            style: const TextStyle(fontSize: 16, color: Colors.black)),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => onChanged(value + 1),
        ),
      ],
    );
  }
void _pickDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (selectedDate != null && selectedDate != _selectedDate) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }
  
  Widget _buildDateTimePickers() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: TextButton.icon(
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(_selectedDate == null
                ? 'Pick Date'
                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
            onPressed: () => _pickDate(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextButton.icon(
            icon: const Icon(Icons.access_time_outlined),
            label: Text(_selectedTime == null
                ? 'Pick Time'
                : '${_selectedTime!.hour}:${_selectedTime!.minute}'),
            onPressed: () => _pickTime(context),
          ),
        ),
      ],
    );
  }
  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (selectedTime != null && selectedTime != _selectedTime) {
      setState(() {
        _selectedTime = selectedTime;
      });
    }
  }

  void _calculateTotalCost() {
    _totalCost = _services.fold(0.0, (total, service) {
      return total + ((service['selected'] ?? false) ? (service['pricePerGuest'] * _guestCount) : 0.0);
    }) +
    _eventSetup.fold(0.0, (total, setup) {
      return total + ((setup['selected'] ?? false) ? setup['price'] : 0.0);
    }) +
    _entertainment.fold(0.0, (total, entertainment) {
      return total + ((entertainment['selected'] ?? false) ? entertainment['price'] : 0.0);
    });
  }

void _submitBooking() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() {});

  // Retrieve the token from Hive
  var box = await Hive.openBox('authBox');
  String? token = box.get('token');

  if (token == null) {
    _showDialog('Authentication Error', 'No token found. Please log in again.');
    return;
  }

  List<Map<String, dynamic>> selectedServices = _services
      .where((service) => service['selected'] == true)
      .map((service) => {
            'name': service['name'],
            'price': service['pricePerGuest'],
            'quantity': _guestCount,
          })
      .toList();

  final url = Uri.parse('https://web-production-3e0c9.up.railway.app/api/v1/bookings');
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  final body = json.encode({
    'services': selectedServices,
    'event_name': _eventName,
    'event_location': _eventLocation,
    'guest_count': _guestCount,
    'special_instructions': _specialInstructions,
    'date': _selectedDate?.toIso8601String(),
    'time': _selectedTime != null
        ? '${_selectedTime!.hour}:${_selectedTime!.minute}'
        : null,
    'total_cost': _totalCost,
  });

  try {
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 201) {
      _showDialog('Booking Confirmation', 'Your booking has been submitted successfully!');
    } else {
      _showDialog('Booking Error', 'Failed to create booking. Please try again.');
    }
  } catch (e) {
    _showDialog('Network Error', 'An error occurred: $e');
  } finally {
    setState(() {});
  }
}
  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

}
