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
        primaryColor: const Color(0xFF00BFA5),
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
          bodySmall: TextStyle(color: Colors.black54),
        ),
      ),
      home: const FeedbackAndReviewsPage(),
    );
  }
}

class FeedbackAndReviewsPage extends StatefulWidget {
  const FeedbackAndReviewsPage({super.key});

  @override
  _FeedbackAndReviewsPageState createState() => _FeedbackAndReviewsPageState();
}

class _FeedbackAndReviewsPageState extends State<FeedbackAndReviewsPage> {
  double _rating = 5.0;
  String _feedbackText = '';
  final List<Map<String, dynamic>> _pastFeedback = [
    {'feedback': 'Great service', 'rating': 5.0},
    {'feedback': 'Food was delicious', 'rating': 4.5},
    {'feedback': 'Catering was on time', 'rating': 4.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        elevation: 0,
        title: const Text('Feedback & Reviews',
            style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeedbackForm(),
            const SizedBox(height: 20),
            _buildPastFeedback(),
            const SizedBox(height: 20),
            _buildAnalytics(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackForm() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Leave Feedback',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Rate the service:'),
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
            const Text('Your Feedback:'),
            const SizedBox(height: 10),
            TextField(
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                ),
                onPressed: _submitFeedback,
                icon: const Icon(Icons.send),
                label: const Text('Submit Feedback'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitFeedback() {
    if (_feedbackText.isNotEmpty) {
      setState(() {
        _pastFeedback.insert(0, {'feedback': _feedbackText, 'rating': _rating});
        _feedbackText = '';
        _rating = 5.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Feedback submitted successfully!'),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  Widget _buildPastFeedback() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Past Feedback',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ..._pastFeedback.map((feedback) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(feedback['feedback']),
                      ),
                      RatingBarIndicator(
                        rating: feedback['rating'],
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 20.0,
                        direction: Axis.horizontal,
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalytics() {
    double totalRating = 0;
    for (var feedback in _pastFeedback) {
      totalRating += feedback['rating'];
    }
    double averageRating = totalRating / _pastFeedback.length;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analytics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Average Rating: ${averageRating.toStringAsFixed(1)} stars'),
            const SizedBox(height: 10),
            const Text('Number of Reviews:'),
            Text('${_pastFeedback.length}'),
          ],
        ),
      ),
    );
  }
}
