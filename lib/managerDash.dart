import 'package:flutter/material.dart';

class CateringDashboard extends StatelessWidget {
  const CateringDashboard({super.key});

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
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
                  onPressed: () {
                    // Notification actions
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle, color: Colors.white),
                  onPressed: () {
                    // Profile actions
                  },
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
              // Quick Actions Section
              Container(
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
                            style:
                                TextStyle(fontSize: 18, color: Colors.black)),
                        TextButton(
                            onPressed: () {}, child: const Text('View More'))
                      ],
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 20,
                      children: [
                        _quickActionButton(context, Icons.receipt_long,
                            'View Orders', const Color(0xFFB39DDB)),
                        _quickActionButton(context, Icons.calendar_today,
                            'View Bookings', const Color(0xFF00D7A3)),
                        _quickActionButton(context, Icons.assignment_ind,
                            'Assign Tasks', const Color(0xFFFF8A80)),
                        _quickActionButton(context, Icons.check_circle,
                            'Confirm Tasks', const Color(0xFF81C784)),
                        _quickActionButton(context, Icons.update,
                            'Provide Updates', const Color(0xFF4FC3F7)),
                        _quickActionButton(context, Icons.chat_bubble,
                            'Communicate', const Color(0xFFFFB74D)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Upcoming Bookings Card
              _sectionWithViewMore('Upcoming Bookings', _bookingsCard()),

              const SizedBox(height: 20),

              // Pending Orders Card
              _sectionWithViewMore('Pending Orders', _pendingOrdersCard()),

              const SizedBox(height: 20),

              // Recent Notifications Card
              _sectionWithViewMore(
                  'Recent Notifications', _notificationsCard()),
            ],
          ),
        ),
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
          onTap: () {
            // Define actions when buttons are clicked
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

  Widget _bookingsCard() {
    return _infoCard(
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
