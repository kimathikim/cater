import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  double _loadingProgress = 0.0;
  bool _isLoading = false;

  final String baseUrl =
      'https://catermanage-388b2a1ca8bc.herokuapp.com/api/v1';
  String? token;

  final Map<String, bool> _foodAndBeverages = {
    'Buffet Service': false,
    'Plated Dinner': false,
    'Cocktail Reception': false,
    'Food Truck Service': false,
    'Beverage Service': false,
  };

  final Map<String, bool> _eventSetup = {
    'Tent Setup': false,
    'Stage Setup': false,
    'Lighting & Sound': false,
    'Tables & Chairs': false,
    'Decorations': false,
  };

  final Map<String, bool> _entertainment = {
    'DJ/Live Band': false,
    'Photo Booth': false,
    'Master of Ceremony': false,
    'Fireworks Display': false,
  };

  @override
  void initState() {
    super.initState();
    Hive.initFlutter();
    _loadToken();
  }

  Future<void> _loadToken() async {
    var box = await Hive.openBox('authBox');
    token = box.get('token');
    if (token == null) {
      _showDialog("Authentication Error", "User not authenticated.");
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () => Navigator.of(ctx).pop(),
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
        leading: widget.fromBottomNavBar
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
        title: const Text('Book Catering & Event Services',
            style: TextStyle(color: Colors.white)),
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(4.0),
                child: LinearProgressIndicator(
                  value: _loadingProgress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEventNameField(),
              _buildServicesContainer('Food & Beverages', _foodAndBeverages),
              _buildServicesContainer('Event Setup', _eventSetup),
              _buildServicesContainer('Entertainment', _entertainment),
              _buildEventDetails(),
              _buildSpecialInstructionsField(),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventNameField() {
    return _buildContainer(
      title: 'Event Name',
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: 'Name of the Event',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) => _eventName = value,
      ),
    );
  }

  Widget _buildServicesContainer(String title, Map<String, bool> services) {
    return _buildContainer(
      title: title,
      child: Column(
        children: services.keys.map((service) {
          return CheckboxListTile(
            title: Text(service),
            value: services[service],
            onChanged: (bool? value) {
              setState(() {
                services[service] = value ?? false;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEventDetails() {
    return _buildContainer(
      title: 'Event Details',
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Event Location',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _eventLocation = value,
          ),
          const SizedBox(height: 10),
          _buildNumberPicker('Guest Count:', _guestCount, (newValue) {
            setState(() => _guestCount = newValue);
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
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter any special instructions for the event...',
        ),
        maxLines: 4,
        onChanged: (value) => _specialInstructions = value,
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: () => onChanged(value > 0 ? value - 1 : 0),
        ),
        Text('$value', style: const TextStyle(fontSize: 16)),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => onChanged(value + 1),
        ),
      ],
    );
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

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  void _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _loadingProgress = 0.0; // Indeterminate state during network request
    });

    List<String> selectedServices = [];
    _foodAndBeverages.forEach((key, value) {
      if (value) selectedServices.add(key);
    });
    _eventSetup.forEach((key, value) {
      if (value) selectedServices.add(key);
    });
    _entertainment.forEach((key, value) {
      if (value) selectedServices.add(key);
    });

    final url = Uri.parse('$baseUrl/bookings');
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
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 201) {
        var box = await Hive.openBox('bookingsBox');
        box.add(
            json.decode(response.body)); // Save booking data for offline access
        _showDialog('Booking Confirmation',
            'Your booking has been submitted successfully!');
      } else {
        _showDialog(
            "Booking Error", "Failed to create booking. Please try again.");
      }
    } catch (e) {
      _showDialog("Network Error", "An error occurred: $e");
    } finally {
      setState(() {
        _isLoading = false;
        _loadingProgress = 0.0; // Reset progress
      });
    }
  }
}
