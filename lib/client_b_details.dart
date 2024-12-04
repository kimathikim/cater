import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'communication.dart';

class BookingDetailPage extends StatefulWidget {
  final Map<String, dynamic> booking;

  const BookingDetailPage({super.key, required this.booking});

  @override
  _BookingDetailPageState createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  String? _userId;
  String? _userName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      var box = await Hive.openBox('authBox');
      String? token = box.get('token');
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('User not authenticated. Please log in.')),
        );
        return;
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse(
            'https://catermanage-388b2a1ca8bc.herokuapp.com/api/v1/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body)['user'];
        setState(() {
          _userId = userData['id'];
          _userName = userData['name'];
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch user profile.')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user profile: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        elevation: 0,
        title: const Text('Booking Details',
            style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailCard('Event Details', [
                      _detailRow('Event', widget.booking['event_name']),
                      _detailRow('Date', widget.booking['event_date']),
                      _detailRow('Time', widget.booking['event_time']),
                      _detailRow('Location', widget.booking['event_location']),
                      _detailRow('Guests', '${widget.booking['guest_count']}'),
                    ]),
                    const SizedBox(height: 20),
                    _buildServiceCard('Services', widget.booking['services']),
                    const SizedBox(height: 20),
                    _buildSpecialInstructionsCard('Special Instructions',
                        widget.booking['special_instructions']),
                    const SizedBox(height: 20),
                    _buildCostCard('Total Cost', widget.booking['total_cost']),
                    const SizedBox(height: 20),
                    _buildCommunicationButton(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> details) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(title),
            const Divider(color: Colors.grey),
            ...details,
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        const Icon(Icons.info, color: Color(0xFF00BFA5)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00BFA5),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String title, List<dynamic> services) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(title),
            const Divider(color: Colors.grey),
            if (services.isEmpty)
              const Text(
                'No services listed.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              )
            else
              Column(
                children: services.map<Widget>((service) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            service['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          '\$${service['price']} x ${service['quantity']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialInstructionsCard(String title, String? instructions) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(title),
            const Divider(color: Colors.grey),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                instructions?.isNotEmpty == true ? instructions! : 'None',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostCard(String title, dynamic cost) {
    double totalCost = cost is int ? cost.toDouble() : cost;
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(title),
            const Divider(color: Colors.grey),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '\$${totalCost.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunicationButton(BuildContext context) {
    final clientId = _userId; // The user's ID, fetched from the user profile
    final clientName =
        _userName; // The user's name, fetched from the user profile
    final managerId = widget.booking['manager_id'];
    final managerName = widget.booking['manager_name'];

    // Ensure values are not null and log for debugging
    if (clientId == null ||
        clientName == null ||
        managerId == null ||
        managerName == null) {
      print("Communication Error: One or more user details are missing.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Client or Manager information is unavailable.'),
        ),
      );
      return const SizedBox
          .shrink(); // Return an empty widget if data is not available
    }

    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.person),
          label: const Text('Contact Manager'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BFA5),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommunicationApp(
                  receiverName: managerName,
                  receiverId: managerId,
                  userName: clientName,
                  id: clientId,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
