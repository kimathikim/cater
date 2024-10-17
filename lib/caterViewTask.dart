import 'package:flutter/material.dart';

void main() {
  runApp(const AssignedTasksApp());
}

class AssignedTasksApp extends StatelessWidget {
  const AssignedTasksApp({super.key});

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
      home: const AssignedTasksPage(),
    );
  }
}

class AssignedTasksPage extends StatefulWidget {
  const AssignedTasksPage({super.key});

  @override
  _AssignedTasksPageState createState() => _AssignedTasksPageState();
}

class _AssignedTasksPageState extends State<AssignedTasksPage> {
  final List<Map<String, dynamic>> _tasks = [
    {
      'task': 'Setup for Corporate Event',
      'date': 'Dec 25, 2023',
      'location': 'Nairobi, Kenya',
      'instructions': 'Setup tables, chairs, and audio equipment',
      'status': 'Pending',
    },
    {
      'task': 'Decorate for Wedding Reception',
      'date': 'Jan 15, 2024',
      'location': 'Mombasa, Kenya',
      'instructions': 'Arrange flowers and set up lighting',
      'status': 'Pending',
    },
    {
      'task': 'Catering for Product Launch',
      'date': 'Feb 10, 2024',
      'location': 'Nairobi, Kenya',
      'instructions': 'Serve refreshments and manage buffet',
      'status': 'Pending',
    },
  ];

  String _taskUpdate = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        elevation: 0,
        title:
            const Text('Assigned Tasks', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContainer(
              title: 'Assigned Tasks',
              child: _buildTasksList(),
            ),
            const SizedBox(height: 20),
            _buildContainer(
              title: 'Add Task Update',
              child: _buildTaskUpdateForm(),
            ),
            const SizedBox(height: 20),
            _buildContainer(
              title: 'Notifications',
              child: _buildNotifications(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContainer({required String title, required Widget child}) {
    return Container(
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

  Widget _buildTasksList() {
    return Column(
      children: _tasks.map((task) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task: ${task['task']}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('Date: ${task['date']}'),
                Text('Location: ${task['location']}'),
                Text('Instructions: ${task['instructions']}'),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _updateTaskStatus(task, 'In Progress');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                      ),
                      child: const Text('In Progress'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        _updateTaskStatus(task, 'Completed');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BFA5),
                      ),
                      child: const Text('Completed'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTaskUpdateForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter Update or Notes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter task update or notes...',
          ),
          maxLines: 4,
          onChanged: (value) {
            setState(() {
              _taskUpdate = value;
            });
          },
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFA5),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            ),
            onPressed: _submitTaskUpdate,
            icon: const Icon(Icons.update),
            label: const Text('Submit Update'),
          ),
        ),
      ],
    );
  }

  Widget _buildNotifications() {
    // Dummy notification for task updates
    return const Column(
      children: [
        ListTile(
          leading: Icon(Icons.notifications, color: Colors.blue),
          title: Text('Task Update'),
          subtitle:
              Text('Task "Setup for Corporate Event" marked as completed.'),
        ),
        ListTile(
          leading: Icon(Icons.notifications, color: Colors.blue),
          title: Text('New Task Assigned'),
          subtitle: Text(
              'You have been assigned a new task for "Wedding Reception."'),
        ),
      ],
    );
  }

  void _updateTaskStatus(Map<String, dynamic> task, String status) {
    setState(() {
      task['status'] = status;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Task "${task['task']}" marked as $status.'),
      duration: const Duration(seconds: 2),
    ));
  }

  void _submitTaskUpdate() {
    if (_taskUpdate.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Task update submitted successfully!'),
        duration: Duration(seconds: 2),
      ));
      setState(() {
        _taskUpdate = '';
      });
    }
  }
}
