import 'package:flutter/material.dart';

void main() {
  runApp(const DashboardPage());
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFF00BFA5), // Teal accent color
        scaffoldBackgroundColor: const Color(0xFFF9F9F9), // Light grey background
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF00D7A3), // Teal for buttons and accents
        ),
      ),
      home: const Dashboard(),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catering Manager Dashboard'),
        backgroundColor: const Color(0xFF00BFA5), // Teal green theme color
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Actions Grid
              const Text('Quick Actions',
                  style: TextStyle(fontSize: 16.0, color: Colors.black87, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3, 
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,

                physics: const NeverScrollableScrollPhysics(), // Disable scrolling in GridView
                children: [
                  _quickActionButton(context, Icons.receipt_long, 'View Orders',
                      const Color(0xFF81C784)), // Light Green
                  _quickActionButton(context, Icons.calendar_today, 'View Bookings',
                      const Color(0xFF4FC3F7)), // Light Blue
                  _quickActionButton(context, Icons.assignment_ind, 'Assign Tasks',
                      const Color(0xFFFFB74D)), // Light Orange
                  _quickActionButton(context, Icons.check_circle, 'Confirm Tasks',
                      const Color(0xFF00BFA5)), // Teal
                  _quickActionButton(context, Icons.update, 'Provide Updates',
                      const Color(0xFF9575CD)), // Light Purple
                  _quickActionButton(context, Icons.chat_bubble, 'Communicate',
                      const Color(0xFFFF8A80)), // Light Red
                ],
              ),
              const SizedBox(height: 20),
              _bookingsCard(),
              const SizedBox(height: 20),
              _pendingOrdersCard(),
              const SizedBox(height: 20),
              _notificationsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickActionButton(
      BuildContext context, IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        // Define actions when buttons are clicked
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 10),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _bookingsCard() {
    return _infoCard(
      'Upcoming Bookings',

      [
        _bookingRow('Wedding Reception', 'June 15, 2023', '150 guests',
            'Confirmed', const Color(0xFF81C784)),
        _bookingRow('Corporate Luncheon', 'June 18, 2023', '75 guests',
            'Confirmed', const Color(0xFF81C784)),
        _bookingRow('Birthday Party', 'June 20, 2023', '50 guests', 'Pending',
            const Color(0xFFFFB74D)),
        _bookingRow('Charity Gala', 'June 25, 2023', '200 guests', 'Confirmed',
            const Color(0xFF81C784)),
        _bookingRow('Product Launch', 'June 30, 2023', '100 guests', 'Pending',
            const Color(0xFFFFB74D)),
      ],
    );
  }

  Widget _pendingOrdersCard() {
    return _infoCard(
      'Pending Orders',
      [
        _orderRow('#1234', 'Wedding Reception', 'June 15, 2023', 'In Progress',
            const Color(0xFF81C784)),
        _orderRow('#1235', 'Corporate Luncheon', 'June 18, 2023', 'Pending',
            const Color(0xFFFFB74D)),
        _orderRow('#1236', 'Birthday Party', 'June 20, 2023', 'Pending',
            const Color(0xFFFFB74D)),
      ],
    );
  }

  Widget _notificationsCard() {
    return _infoCard(
      'Recent Notifications',
      [
        _notificationRow('New Booking: Corporate Luncheon', '10 minutes ago'),
        _notificationRow(
            'Task Completed: Setup for Wedding Reception', '1 hour ago'),
      ],
    );
  }

  Widget _infoCard(String title, List<Widget> children) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 16, color: Colors.black87)),
            const SizedBox(height: 10),
            Column(children: children),
          ],
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
            Text(event, style: const TextStyle(color: Colors.black87)),
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
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(orderId, style: const TextStyle(color: Colors.black87)),
            Text('$event • \n$date', style: TextStyle(color: Colors.grey[600])),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(message, style: const TextStyle(color: Colors.black87)),
        Text(time, style: TextStyle(color: Colors.grey[600])),
      ],
    ),
  );
}
}

// import 'package:flutter/material.dart';
//
// class DashboardPage extends StatelessWidget {
//   const DashboardPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1E1A44), // Dark purple background
//       appBar: AppBar(
//         title: const Text('Booking System'),
//         backgroundColor: const Color(0xFF1E1A44), // Matching the background
//         elevation: 0,
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
//         backgroundColor: const Color(0xFF8C71F7),
//         onPressed: () {
//           // Add booking form logic here
//         },
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }
//
//   Widget _buildBookingItem(String title, String date, String status) {
//     IconData statusIcon;
//     Color statusColor;
//     String statusText;
//
//     switch (status) {
//       case 'Pending':
//         statusIcon = Icons.hourglass_bottom;
//         statusColor = Colors.orange;
//         statusText = 'Pending';
//         break;
//       case 'Confirmed':
//         statusIcon = Icons.check_circle_outline;
//         statusColor = Colors.blue;
//         statusText = 'Confirmed';
//         break;
//       case 'Completed':
//         statusIcon = Icons.check_circle;
//         statusColor = Colors.green;
//         statusText = 'Completed';
//         break;
//       default:
//         statusIcon = Icons.info_outline;
//         statusColor = Colors.grey;
//         statusText = 'Unknown';
//     }
//
//     return Card(
//       color: const Color(0xFF3C347B), // Card color (lighter purple)
//       elevation: 3,
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.event_note, size: 40, color: Colors.white),
//                 const SizedBox(width: 16),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       date,
//                       style: const TextStyle(
//                         color: Colors.white70,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             Chip(
//               label: Text(
//                 statusText,
//                 style: const TextStyle(color: Colors.white),
//               ),
//               avatar: Icon(statusIcon, color: Colors.white),
//               backgroundColor: statusColor,
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//

// import 'package:flutter/material.dart';
//
// class DashboardPage extends StatelessWidget {
//   const DashboardPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1E1A44), // Dark purple background
//       appBar: AppBar(
//         title: const Text('Dashboard'),
//         backgroundColor: const Color(0xFF1E1A44), // Matching background color
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.menu),
//             onPressed: () {
//               // Menu action
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             _buildDashboardCard(
//               title: 'Place Orders',
//               description:
//                   'Hypermanly catering order. Leave some details to help your caterers.',
//               buttonText: 'Make Bookings',
//               icon: Icons.shopping_cart_outlined,
//               onButtonPressed: () {
//                 // Navigate to place orders
//               },
//             ),
//             const SizedBox(height: 16),
//             _buildDashboardCard(
//               title: 'Make Bookings',
//               description:
//                   'Elucidate on booking salient. Leave feedback or mind all events.',
//               buttonText: 'Provide Feedback',
//               icon: Icons.calendar_today_outlined,
//               onButtonPressed: () {
//                 // Navigate to make bookings
//               },
//             ),
//             const SizedBox(height: 16),
//             _buildDashboardCard(
//               title: 'Communicate',
//               description:
//                   'Unifying a dialogue with the catering managers and caterers.',
//               buttonText: 'Chat',
//               icon: Icons.chat_outlined,
//               onButtonPressed: () {
//                 // Navigate to communication
//               },
//             ),
//             const SizedBox(height: 16),
//             _buildNotificationCard(),
//             const SizedBox(height: 16),
//             _buildDashboardCard(
//               title: 'View Bookings/Orders',
//               description: 'Preview all bookings and order status.',
//               buttonText: 'View',
//               icon: Icons.view_list_outlined,
//               onButtonPressed: () {
//                 // Navigate to view bookings and orders
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDashboardCard({
//     required String title,
//     required String description,
//     required String buttonText,
//     required IconData icon,
//     required VoidCallback onButtonPressed,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF3C347B), // Lighter purple for cards
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, size: 40, color: Colors.white),
//                 const SizedBox(width: 16),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               description,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Colors.white70,
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF8C71F7), // Button color
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 minimumSize: const Size(150, 40),
//               ),
//               onPressed: onButtonPressed,
//               child: Text(
//                 buttonText,
//                 style: const TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNotificationCard() {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF3C347B), // Lighter purple for cards
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: const Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.notifications_none_outlined,
//                     size: 40, color: Colors.white),
//                 SizedBox(width: 16),
//                 Text(
//                   'Notifications',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8),
//             Text(
//               '1 Unread message\n2 Pending orders\n3 Upcoming bookings',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.white70,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
