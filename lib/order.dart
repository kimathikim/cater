import 'package:flutter/material.dart';

class OrderManagementPage extends StatelessWidget {
  const OrderManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildOrderItem('Order #1234', 'Catering for 100 people', 'Pending'),
          _buildOrderItem('Order #5678', 'Lunch Buffet', 'Completed'),
        ],
      ),
    );
  }

  Widget _buildOrderItem(String orderId, String details, String status) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(orderId),
        subtitle: Text(details),
        trailing: Text(
          status,
          style: TextStyle(
            color: status == 'Completed'
                ? Colors.green
                : (status == 'Pending' ? Colors.orange : Colors.blue),
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          // Navigate to order details page
        },
      ),
    );
  }
}
