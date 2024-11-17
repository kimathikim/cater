import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'communication.dart';

class BookingDetailPage extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingDetailPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        elevation: 0,
        title: const Text('Booking Details',
            style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailCard('Event Details', [
                _detailRow('Event', booking['event_name']),
                _detailRow('Date', booking['event_date']),
                _detailRow('Time', booking['event_time']),
                _detailRow('Location', booking['event_location']),
                _detailRow('Guests', '${booking['guest_count']}'),
              ]),
              const SizedBox(height: 20),
              _buildStatusCard('Status', booking['status'], context),
              const SizedBox(height: 20),
              _buildServiceCard('Services', booking['services']),
              const SizedBox(height: 20),
              _buildSpecialInstructionsCard(
                  'Special Instructions', booking['special_instructions']),
              const SizedBox(height: 20),
              _buildCostCard('Total Cost', booking['total_cost']),
              const SizedBox(height: 20),
              _buildCommunicationButtons(context),
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

  Widget _buildStatusCard(String title, String status, BuildContext context) {
    Color statusColor;
    switch (status) {
      case 'Pending':
        statusColor = const Color(0xFFFFB74D);
        break;
      case 'Confirmed':
        statusColor = const Color(0xFF81C784);
        break;
      case 'Completed':
        statusColor = const Color(0xFF00BFA5);
        break;
      case 'Cancelled':
        statusColor = Colors.redAccent;
        break;
      default:
        statusColor = Colors.grey;
    }

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
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showUpdateStatusDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Update Status'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunicationButtons(BuildContext context) {
    final managerId = booking['userProfile']['id'];
    final managerName = booking['userProfile']['name'];
    final clientId = booking['user_id'];
    final clientName = booking['user_name'];
    print(managerName + " " + managerId);
    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.person),
          label: const Text('Contact Client'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BFA5),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          onPressed: () {
            if (clientId != null && clientName != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommunicationApp(
                    receiverName: clientName,
                    receiverId: clientId,
                    userName: managerName,
                    id: managerId,
                  ),
                ),
              );
            }
            // } else {
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     const SnackBar(
            //       content: Text('Client information is unavailable.'),
            //     ),
            //   );
            // }
          },
        ),
      ],
    );
  }

  void _showUpdateStatusDialog(BuildContext context) {
    String selectedStatus = 'Pending';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Update Booking Status',
            style: TextStyle(color: Colors.black),
          ),
          content: DropdownButtonFormField<String>(
            value: selectedStatus,
            dropdownColor: Colors.white,
            items: ['Pending', 'Confirmed', 'Completed', 'Cancelled']
                .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(
                        status,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ))
                .toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                selectedStatus = newValue;
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _updateBookingStatus(
                    context, booking['id'], selectedStatus);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateBookingStatus(
      BuildContext context, String bookingId, String newStatus) async {
    final String apiUrl =
        'https://catermanage-388b2a1ca8bc.herokuapp.com/api/v1/bookings/$bookingId';

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

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.put(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking status updated to $newStatus')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
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
}
