import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

void main() {
  runApp(const FeedbackApp());
}

class FeedbackApp extends StatelessWidget {
  const FeedbackApp({super.key});

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
      home: const FeedbackPage(),
    );
  }
}

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  double _rating = 5.0;
  String _feedbackText = '';
  final List<Map<String, dynamic>> _pastFeedback = [
    {
      'rating': 5.0,
      'feedback': 'Great service, 5 stars.',
      'response':
          'Thank you for your feedback! We are glad you enjoyed our service.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.white),

        title: const Text('Feedback', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContainer(
              title: 'Submit Feedback',
              child: _buildFeedbackForm(),
            ),
            const SizedBox(height: 20),
            _buildContainer(
              title: 'Past Feedback',
              child: _buildPastFeedbackList(),
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

  Widget _buildFeedbackForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rate Our Service',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        RatingBar.builder(
          initialRating: _rating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
            setState(() {
              _rating = rating;
            });
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Your Feedback',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter your feedback here...',
          ),
          maxLines: 4,
          onChanged: (value) {
            _feedbackText = value;
          },
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFA5),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            ),
            onPressed: _submitFeedback,
            icon: const Icon(Icons.feedback_outlined),
            label: const Text('Submit Feedback'),
          ),
        ),
      ],
    );
  }

  Widget _buildPastFeedbackList() {
    return Column(
      children: _pastFeedback.map((feedback) {
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
                Row(
                  children: [
                    Text('Rating: ${feedback['rating']}'),
                    const SizedBox(width: 10),
                    RatingBarIndicator(
                      rating: feedback['rating'],
                      itemBuilder: (context, index) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 20.0,
                      direction: Axis.horizontal,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Feedback: ${feedback['feedback']}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 10),
                if (feedback['response'] != null)
                  Text(
                    'Response: ${feedback['response']}',
                    style: const TextStyle(color: Colors.green),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _submitFeedback() {
    if (_feedbackText.isNotEmpty) {
      setState(() {
        _pastFeedback.add({
          'rating': _rating,
          'feedback': _feedbackText,
          'response': null,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Feedback submitted successfully!'),
        duration: Duration(seconds: 2),
      ));

      _feedbackText = '';
    }
  }
}
