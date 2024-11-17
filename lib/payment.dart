import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Icon library

class PaymentApp extends StatelessWidget {
  const PaymentApp({super.key});

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
      home: const PaymentPage(booking: {'id': 1, 'amount': 100.0}),
    );
  }
}

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> booking;

  const PaymentPage({super.key, required this.booking});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Map<String, dynamic> booking;
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  String selectedPaymentMethod = 'MPesa'; // Default payment method
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    booking = widget.booking;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        elevation: 0,
        title: const Text('Payment', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderDetails(),
            const SizedBox(height: 20),
            _buildPaymentOptions(),
            const SizedBox(height: 20),
            if (selectedPaymentMethod == 'Credit Card') _buildCreditCardForm(),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA5),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                ),
                onPressed: _processPayment,
                icon: const Icon(FontAwesomeIcons.moneyCheckAlt),
                label: const Text('Pay Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(FontAwesomeIcons.receipt,
                size: 40, color: Color(0xFF00BFA5)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Order Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('Event: Wedding Event, Dec 25, 2023'),
                Text('Total Cost: \$500'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Payment Method',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildPaymentOption('MPesa', FontAwesomeIcons.mobileAlt),
        _buildPaymentOption('Credit Card', FontAwesomeIcons.creditCard),
        _buildPaymentOption('PayPal', FontAwesomeIcons.paypal),
        _buildPaymentOption('Bank Transfer', FontAwesomeIcons.university),
      ],
    );
  }

  Widget _buildPaymentOption(String method, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00BFA5)),
      title: Text(method),
      trailing: Radio<String>(
        value: method,
        groupValue: selectedPaymentMethod,
        onChanged: (value) {
          setState(() {
            selectedPaymentMethod = value!;
          });
        },
      ),
    );
  }

  Widget _buildCreditCardForm() {
    return CreditCardForm(
      cardNumber: cardNumber,
      expiryDate: expiryDate,
      cardHolderName: cardHolderName,
      cvvCode: cvvCode,
      onCreditCardModelChange: _onCreditCardModelChange,
      themeColor: const Color(0xFF00BFA5),
      formKey: formKey,
      cardNumberDecoration: const InputDecoration(
        labelText: 'Card Number',
        hintText: 'XXXX XXXX XXXX XXXX',
        prefixIcon: Icon(Icons.credit_card),
        border: OutlineInputBorder(),
      ),
      expiryDateDecoration: const InputDecoration(
        labelText: 'Expiry Date',
        hintText: 'MM/YY',
        prefixIcon: Icon(Icons.date_range),
        border: OutlineInputBorder(),
      ),
      cvvCodeDecoration: const InputDecoration(
        labelText: 'CVV',
        hintText: 'XXX',
        prefixIcon: Icon(Icons.lock),
        border: OutlineInputBorder(),
      ),
      cardHolderDecoration: const InputDecoration(
        labelText: 'Card Holder',
        prefixIcon: Icon(Icons.person),
        border: OutlineInputBorder(),
      ),
    );
  }

  void _onCreditCardModelChange(CreditCardModel? model) {
    setState(() {
      cardNumber = model?.cardNumber ?? '';
      expiryDate = model?.expiryDate ?? '';
      cardHolderName = model?.cardHolderName ?? '';
      cvvCode = model?.cvvCode ?? '';
      isCvvFocused = model?.isCvvFocused ?? false;
    });
  }

  void _processPayment() {
    if (selectedPaymentMethod == 'Credit Card' &&
        formKey.currentState?.validate() == true) {
      // Simulate a payment processing
      _showPaymentResult(success: true);
    } else if (selectedPaymentMethod != 'Credit Card') {
      // Simulate a payment processing for other methods
      _showPaymentResult(success: true);
    } else {
      _showPaymentResult(success: false);
    }
  }

  void _showPaymentResult({required bool success}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(success ? 'Payment Successful' : 'Payment Failed'),
        content: Text(success
            ? 'Your payment was successfully processed!'
            : 'There was an issue processing your payment. Please try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
