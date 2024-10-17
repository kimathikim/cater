import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';
import 'taskassign.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  runApp(const EventSchedulingApp());
}

class EventSchedulingApp extends StatelessWidget {
  const EventSchedulingApp({super.key});

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
      home: const EventSchedulingPage(),
    );
  }
}

class EventSchedulingPage extends StatefulWidget {
  const EventSchedulingPage({super.key});

  @override
  _EventSchedulingPageState createState() => _EventSchedulingPageState();
}

class _EventSchedulingPageState extends State<EventSchedulingPage> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  final TextEditingController _eventController = TextEditingController();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _addDummyEvents();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _addDummyEvents() {
    setState(() {
      _events = {
        DateTime(2023, 12, 25): [
          {
            'event': 'Corporate Event',
            'time': const TimeOfDay(hour: 14, minute: 30)
          }
        ],
      };
    });
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  Future<void> _addEvent() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null && _eventController.text.isNotEmpty) {
      setState(() {
        if (_events[_selectedDay] != null) {
          _events[_selectedDay]!.add({
            'event': _eventController.text,
            'time': selectedTime,
          });
        } else {
          _events[_selectedDay] = [
            {'event': _eventController.text, 'time': selectedTime}
          ];
        }
      });

      _scheduleNotification(_selectedDay, _eventController.text, selectedTime);
      _eventController.clear();
    }
  }

  void _deleteEvent(String event, Map<String, dynamic> eventData) {
    setState(() {
      _events[_selectedDay]?.remove(eventData);
      if (_events[_selectedDay]?.isEmpty ?? true) {
        _events.remove(_selectedDay);
      }
    });
  }

  Future<void> _scheduleNotification(
      DateTime dateTime, String event, TimeOfDay timeOfDay) async {
    final DateTime scheduledDateTime = DateTime(dateTime.year, dateTime.month,
        dateTime.day, timeOfDay.hour, timeOfDay.minute);

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your_channel_id', 'your_channel_name',
            'your_channel_description', // Add a description for your channel
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      const Uuid().v4().hashCode,
      'Upcoming Event',
      event,
      tz.TZDateTime.from(scheduledDateTime, tz.local).subtract(
          const Duration(minutes: 30)), // Notify 30 minutes before event
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void _openAssignTaskPage(String event) {
    // Navigate to a task assignment page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TaskAssignmentPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        elevation: 0,
        title: const Text('Event Scheduling',
            style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
            headerStyle: const HeaderStyle(formatButtonVisible: false),
          ),
          const SizedBox(height: 16),
          ..._getEventsForDay(_selectedDay).map((eventData) {
            final String event = eventData['event'];
            final TimeOfDay time = eventData['time'];
            return ListTile(
              title: Text('$event at ${time.format(context)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.task_alt),
                    onPressed: () => _openAssignTaskPage(event),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteEvent(event, eventData),
                  ),
                ],
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _eventController,
              decoration: InputDecoration(
                labelText: 'Add Event',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addEvent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AssignTaskPage extends StatelessWidget {
  final String event;
  const AssignTaskPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Task for $event'),
        backgroundColor: const Color(0xFF00BFA5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Assign tasks for $event'),
            const SizedBox(height: 20),
            // Placeholder for task assignment logic
            ElevatedButton(
              onPressed: () {
                // Task assignment logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
              ),
              child: const Text('Assign Task'),
            ),
          ],
        ),
      ),
    );
  }
}
