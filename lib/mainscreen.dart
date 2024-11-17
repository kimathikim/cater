import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'clientDash.dart';
import 'clientBooking.dart';
import 'clientOrder.dart';
import 'package:cater/event.dart';
import 'notification.dart';
import 'communication.dart';

// MainScreen with BottomNavigationBar
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // List of pages that will be displayed in BottomNavigationBar
  final List<Widget> _children = [
    const ClientDashboard(),
    const ClientBookingApp(fromBottomNavBar: true),
    const EventSchedulingPage(),
    const NotificationsApp(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF00BFA5),
        currentIndex: _currentIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black54,
        iconSize: 30,
        onTap: onTabTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online_rounded),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_available_rounded),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active_rounded),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            label: 'Messages',
          ),
        ],
      ),
    );
  }
}
