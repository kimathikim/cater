import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const AdminPanelApp());
}

class AdminPanelApp extends StatelessWidget {
  const AdminPanelApp({super.key});

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
      home: const AdminPanelPage(),
    );
  }
}

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        title: const Text('Admin Panel', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewSection(),
            const SizedBox(height: 20),
            _buildUserManagementSection(),
            const SizedBox(height: 20),
            _buildAnalyticsSection(),
            const SizedBox(height: 20),
            _buildServiceConfigurationSection(),
            const SizedBox(height: 20),
            _buildLogsAndMonitoringSection(),
          ],
        ),
      ),
    );
  }

  // Overview of system modules
  Widget _buildOverviewSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildOverviewCard(
                  FontAwesomeIcons.clipboardList,
                  '25 Orders This Week',
                  const Color(0xFF00BFA5),
                ),
                _buildOverviewCard(
                  FontAwesomeIcons.users,
                  '15 New Users',
                  Colors.orange,
                ),
                _buildOverviewCard(
                  FontAwesomeIcons.calendarCheck,
                  '12 Bookings',
                  Colors.blue,
                ),
                _buildOverviewCard(
                  FontAwesomeIcons.tasks,
                  '5 Events',
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(IconData icon, String label, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // User management section
  Widget _buildUserManagementSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Management',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildManagementButton(
                  FontAwesomeIcons.userPlus,
                  'Add User',
                  Colors.green,
                  () {
                    // Add User logic
                  },
                ),
                _buildManagementButton(
                  FontAwesomeIcons.userMinus,
                  'Remove User',
                  Colors.red,
                  () {
                    // Remove User logic
                  },
                ),
                _buildManagementButton(
                  FontAwesomeIcons.userShield,
                  'Assign Role',
                  Colors.blue,
                  () {
                    // Assign Role logic
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementButton(
      IconData icon, String label, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    );
  }

  // Analytics section
  Widget _buildAnalyticsSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Analytics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            AspectRatio(
              aspectRatio: 2,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true, getTitlesWidget: _getBottomTitles),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(toY: 10, color: Colors.blue)
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(toY: 15, color: Colors.orange)
                    ]),
                    BarChartGroupData(x: 2, barRods: [
                      BarChartRodData(toY: 12, color: Colors.purple)
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    switch (value.toInt()) {
      case 0:
        return const Text('Orders', style: style);
      case 1:
        return const Text('Users', style: style);
      case 2:
        return const Text('Bookings', style: style);
      default:
        return const Text('');
    }
  }

  // Service configuration section
  Widget _buildServiceConfigurationSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildManagementButton(
                  FontAwesomeIcons.cog,
                  'Configure Pricing',
                  Colors.blueGrey,
                  () {
                    // Configure Pricing logic
                  },
                ),
                _buildManagementButton(
                  FontAwesomeIcons.calendarAlt,
                  'Manage Availability',
                  Colors.teal,
                  () {
                    // Manage Availability logic
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Logs and monitoring section
  Widget _buildLogsAndMonitoringSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Logs & Monitoring',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading:
                  const Icon(FontAwesomeIcons.clipboard, color: Colors.red),
              title: const Text('View System Logs'),
              onTap: () {
                // View System Logs logic
              },
            ),
            ListTile(
              leading:
                  const Icon(FontAwesomeIcons.chartLine, color: Colors.purple),
              title: const Text('Activity Monitoring'),
              onTap: () {
                // Activity Monitoring logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
