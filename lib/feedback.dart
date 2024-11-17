import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FeedbackPage extends StatefulWidget {
  final int bookingId;

  const FeedbackPage({super.key, required this.bookingId});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  double _rating = 5.0;
  String _feedbackText = '';
  bool _isLoading = false;
  List<Map<String, dynamic>> _pastFeedback = [];

  final String baseUrl = 'https://catermanage-388b2a1ca8bc.herokuapp.com/api/v1';
  String? token;

  @override
  void initState() {
    super.initState();
    Hive.initFlutter();
    _fetchPastFeedback();
  }

  Future<void> _fetchPastFeedback() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var box = await Hive.openBox('authBox');
      token = box.get('token');

      if (token == null) {
        _showErrorDialog('User not authenticated. Please log in again.');
        return;
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/bookings/${widget.bookingId}/feedback'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final feedbackData = json.decode(response.body);

        setState(() {
          _pastFeedback = List<Map<String, dynamic>>.from(feedbackData['feedbacks']);
        });
      } else {
        _showErrorDialog('Failed to fetch past feedback.');
      }
    } catch (e) {
      _showErrorDialog('Error fetching feedback: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _submitFeedback() async {
    if (_feedbackText.isEmpty) {
      _showErrorDialog('Please enter your feedback before submitting.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var box = await Hive.openBox('authBox');
      token = box.get('token');

      if (token == null) {
        _showErrorDialog('User not authenticated. Please log in again.');
        return;
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      Map<String, dynamic> body = {
        'rating': _rating,
        'feedback': _feedbackText,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/bookings/${widget.bookingId}/feedback'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        setState(() {
          _pastFeedback.insert(0, {
            'rating': _rating,
            'feedback': _feedbackText,
            'response': null,
          });
          _feedbackText = '';
          _rating = 5.0;
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Feedback submitted successfully!'),
          duration: Duration(seconds: 2),
        ));
      } else {
        _showErrorDialog('Failed to submit feedback.');
      }
    } catch (e) {
      _showErrorDialog('Error submitting feedback: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        backgroundColor: const Color(0xFF00BFA5),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Provide feedback for booking ID: ${widget.bookingId}'),
                  const SizedBox(height: 20),
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
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
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
        RatingBar.builder(
          initialRating: _rating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
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
        const SizedBox(height: 10),
        TextField(
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Enter your feedback here...',
            border: OutlineInputBorder(),
          ),
          onChanged: (text) {
            setState(() {
              _feedbackText = text;
            });
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _submitFeedback,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BFA5),
          ),
          child: const Text('Submit Feedback'),
        ),
      ],
    );
  }

  Widget _buildPastFeedbackList() {
    if (_pastFeedback.isEmpty) {
      return const Text('No past feedback available.');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _pastFeedback.length,
      itemBuilder: (context, index) {
        final feedback = _pastFeedback[index];
        return ListTile(
          title: Row(
            children: [
              Text('Rating: ${feedback['rating']}'),
              const SizedBox(width: 10),
              RatingBarIndicator(
                rating: feedback['rating'],
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 20.0,
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Feedback: ${feedback['feedback']}'),
              if (feedback['response'] != null) ...[
                const SizedBox(height: 5),
                Text('Response: ${feedback['response']}', style: const TextStyle(color: Colors.green)),
              ],
            ],
          ),
        );
      },
    );
  }
}

