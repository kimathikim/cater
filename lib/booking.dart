import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1A44), // Dark purple background
      appBar: AppBar(
        title: const Text('Booking System'),
        backgroundColor: const Color(0xFF1E1A44), // Matching the background
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildBookingItem(
              'Catering for Wedding', 'December 10, 2023', 'Pending'),
          _buildBookingItem(
              'Corporate Lunch Event', 'November 23, 2023', 'Confirmed'),
          _buildBookingItem(
              'Private Birthday Party', 'January 5, 2024', 'Completed'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8C71F7),
        onPressed: () {
          // Add booking form logic here
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBookingItem(String title, String date, String status) {
    IconData statusIcon;
    Color statusColor;
    String statusText;

    switch (status) {
      case 'Pending':
        statusIcon = Icons.hourglass_bottom;
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
      case 'Confirmed':
        statusIcon = Icons.check_circle_outline;
        statusColor = Colors.blue;
        statusText = 'Confirmed';
        break;
      case 'Completed':
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        statusText = 'Completed';
        break;
      default:
        statusIcon = Icons.info_outline;
        statusColor = Colors.grey;
        statusText = 'Unknown';
    }

    return Card(
      color: const Color(0xFF3C347B), // Card color (lighter purple)
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.event_note, size: 40, color: Colors.white),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      date,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Chip(
              label: Text(
                statusText,
                style: const TextStyle(color: Colors.white),
              ),
              avatar: Icon(statusIcon, color: Colors.white),
              backgroundColor: statusColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
//
// class BookingPage extends StatelessWidget {
//   const BookingPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Booking System'),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16.0),
//         children: [
//           _buildBookingItem(
//               'Catering for Wedding', 'December 10, 2023', 'Pending'),
//           _buildBookingItem(
//               'Corporate Lunch Event', 'November 23, 2023', 'Confirmed'),
//           _buildBookingItem(
//               'Private Birthday Party', 'January 5, 2024', 'Completed'),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Add booking form here
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
//
//   Widget _buildBookingItem(String title, String date, String status) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: ListTile(
//         title: Text(title),
//         subtitle: Text(date),
//         trailing: Text(
//           status,
//           style: TextStyle(
//             color: status == 'Completed'
//                 ? Colors.green
//                 : (status == 'Pending' ? Colors.orange : Colors.blue),
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }
