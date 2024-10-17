import 'package:flutter/material.dart';

void main() {
  runApp(const TaskAssignmentApp());
}

class TaskAssignmentApp extends StatelessWidget {
  const TaskAssignmentApp({super.key});

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
      home: const TaskAssignmentPage(),
    );
  }
}

class TaskAssignmentPage extends StatefulWidget {
  const TaskAssignmentPage({super.key});

  @override
  _TaskAssignmentPageState createState() => _TaskAssignmentPageState();
}

class _TaskAssignmentPageState extends State<TaskAssignmentPage> {
  DateTime? _selectedDeadline;
  String _selectedCaterer = 'John Doe';
  String _taskNotes = '';
  String _taskDescription = 'Setup Venue for Wedding';

  List<String> _caterers = [
    'John Doe',
    'Jane Smith',
    'Emily Davis',
    'Michael Brown'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        elevation: 0,
        title:
            const Text('Assign Tasks', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContainer(
              title: 'Task Details',
              child: _buildTaskDetails(),
            ),
            const SizedBox(height: 20),
            _buildContainer(
              title: 'Select Caterer',
              child: _buildCatererSelection(),
            ),
            const SizedBox(height: 20),
            _buildContainer(
              title: 'Task Deadline',
              child: _buildDeadlinePicker(),
            ),
            const SizedBox(height: 20),
            _buildContainer(
              title: 'Task Notes / Instructions',
              child: _buildTaskNotesField(),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA5),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                ),
                onPressed: _assignTask,
                icon: const Icon(Icons.assignment_turned_in),
                label: const Text('Assign Task'),
              ),
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

  Widget _buildTaskDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Task Description',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        TextFormField(
          initialValue: _taskDescription,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter task description',
          ),
          onChanged: (value) {
            _taskDescription = value;
          },
        ),
      ],
    );
  }

  Widget _buildCatererSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _caterers.map((caterer) {
        return ListTile(
          title: Text(caterer),
          leading: Radio<String>(
            value: caterer,
            groupValue: _selectedCaterer,
            onChanged: (value) {
              setState(() {
                _selectedCaterer = value!;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDeadlinePicker() {
    return TextButton.icon(
      icon: const Icon(Icons.calendar_today_outlined),
      label: Text(
        _selectedDeadline == null
            ? 'Pick Deadline'
            : '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}',
      ),
      onPressed: () {
        _pickDeadline(context);
      },
    );
  }

  Widget _buildTaskNotesField() {
    return TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Enter task notes or instructions...',
      ),
      maxLines: 4,
      onChanged: (value) {
        _taskNotes = value;
      },
    );
  }

  Future<void> _pickDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  void _assignTask() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Task Assigned'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('The task has been successfully assigned.'),
                const SizedBox(height: 10),
                Text('Task: $_taskDescription'),
                Text('Caterer: $_selectedCaterer'),
                Text(
                    'Deadline: ${_selectedDeadline?.day}/${_selectedDeadline?.month}/${_selectedDeadline?.year}'),
                Text('Notes: $_taskNotes'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
