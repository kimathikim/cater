import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'booking_detail_page.dart'; // Import the detail page

class ManagerBookingsPage extends StatefulWidget {
  const ManagerBookingsPage({super.key});

  @override
  _ManagerBookingsPageState createState() => _ManagerBookingsPageState();
}

class _ManagerBookingsPageState extends State<ManagerBookingsPage> {
  final String baseUrl =
      'https://catermanage-388b2a1ca8bc.herokuapp.com/api/v1';
  bool _isLoading = false;
  List<Map<String, dynamic>> _bookings = [];
  String? token;
  int _page = 1;
  bool _hasMore = true;
  String _selectedStatus = 'All';
  DateTime? _selectedDate;
  bool _isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    Hive.initFlutter();
    _fetchBookings();
  }

  Future<void> _fetchBookings({bool isLoadMore = false}) async {
    if (_isFetchingMore) return;

    setState(() {
      _isLoading = !isLoadMore;
      _isFetchingMore = isLoadMore;
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

      String filterQuery = '';
      if (_selectedStatus != 'All') {
        filterQuery += '&status=$_selectedStatus';
      }
      if (_selectedDate != null) {
        filterQuery += '&date=${_selectedDate!.toIso8601String()}';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/bookings/all?page=$_page$filterQuery'),
        headers: headers,
      );

      print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> newBookings =
            List<Map<String, dynamic>>.from(data['bookings'][0]);

        final userProfileResponse = await http.get(
          Uri.parse('$baseUrl/profile'),
          headers: headers,
        );

        if (userProfileResponse.statusCode == 200) {
          final userProfile = json.decode(userProfileResponse.body)['user'];
          print(userProfileResponse.body);

          for (var booking in newBookings) {
            booking['userProfile'] = userProfile;
          }

          setState(() {
            if (isLoadMore) {
              _bookings.addAll(newBookings);
            } else {
              _bookings = newBookings;
            }
            _hasMore = newBookings.isNotEmpty;
            if (_hasMore) {
              _page++;
            }
          });
        } else {
          _showErrorDialog("Data Error", "Failed to fetch user profile.");
        }
      } else {
        _showErrorDialog("Data Error", "Failed to fetch bookings.");
      }
    } catch (e) {
      _showErrorDialog("Network Error", "An error occurred: $e");
    }

    setState(() {
      _isLoading = false;
      _isFetchingMore = false;
    });
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _page = 1;
        _fetchBookings();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        elevation: 0,
        title:
            const Text('All Bookings', style: TextStyle(color: Colors.white)),
        actions: [
          DropdownButton<String>(
            dropdownColor: Colors.white,
            value: _selectedStatus,
            icon: const Icon(Icons.filter_list, color: Colors.white),
            underline: const SizedBox(),
            items: ['All', 'Pending', 'Confirmed', 'Completed']
                .map((status) => DropdownMenuItem<String>(
                      value: status,
                      child: Text(
                        status,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ))
                .toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedStatus = newValue!;
                _page = 1;
                _fetchBookings();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.date_range, color: Colors.white),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (_hasMore &&
                    !_isFetchingMore &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  _fetchBookings(isLoadMore: true);
                  return true;
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _bookings.length,
                itemBuilder: (ctx, index) {
                  final booking = _bookings[index];
                  print(booking);
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BookingDetailPage(booking: booking),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Event: ${booking['event_name']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Date: ${booking['event_date']}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(booking['status'])
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    booking['status'],
                                    style: TextStyle(
                                      color: _getStatusColor(booking['status']),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Guests: ${booking['guest_count']}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFFFB74D); // Orange color
      case 'Confirmed':
        return const Color(0xFF81C784); // Green color
      case 'Completed':
        return const Color(0xFF00BFA5); // Teal color
      default:
        return Colors.grey; // Default color
    }
  }
}
