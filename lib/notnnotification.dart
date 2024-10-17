import 'package:flutter/material.dart';

void main() {
  runApp(const BudgetAndGuestManagementApp());
}

class BudgetAndGuestManagementApp extends StatelessWidget {
  const BudgetAndGuestManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFF00BFA5),
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BFA5),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const BudgetAndGuestManagementPage(),
    );
  }
}

class BudgetAndGuestManagementPage extends StatefulWidget {
  const BudgetAndGuestManagementPage({super.key});

  @override
  _BudgetAndGuestManagementPageState createState() => _BudgetAndGuestManagementPageState();
}

class _BudgetAndGuestManagementPageState extends State<BudgetAndGuestManagementPage> {
  double _budget = 5000;
  double _foodCost = 1500;
  double _venueCost = 1000;
  double _decorationCost = 500;
  double _laborCost = 500;

  List<String> _guests = ["John Doe", "Jane Smith", "Robert Johnson"];

  final _guestController = TextEditingController();
  final _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _budgetController.text = _budget.toString();
  }

  double get _totalExpenses {
    return _foodCost + _venueCost + _decorationCost + _laborCost;
  }

  double get _remainingBudget {
    return _budget - _totalExpenses;
  }

  void _addGuest(String guestName) {
    if (guestName.isNotEmpty) {
      setState(() {
        _guests.add(guestName);
        _guestController.clear();
      });
    }
  }

  void _removeGuest(int index) {
    setState(() {
      _guests.removeAt(index);
    });
  }

  void _updateBudget() {
    setState(() {
      _budget = double.tryParse(_budgetController.text) ?? _budget;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget & Guest Management'),
        backgroundColor: const Color(0xFF00BFA5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Event Budget',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Budget',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) => _updateBudget(),
              ),
              const SizedBox(height: 20),
              const Text(
                'Estimated Costs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              _buildCostRow('Food', _foodCost),
              _buildCostRow('Venue', _venueCost),
              _buildCostRow('Decorations', _decorationCost),
              _buildCostRow('Labor', _laborCost),
              const SizedBox(height: 20),
              _buildBudgetSummary(),
              const SizedBox(height: 30),
              const Text(
                'Guest List',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              _buildGuestList(),
              const SizedBox(height: 20),
              _buildAddGuestSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Display the cost for each item
  Widget _buildCostRow(String label, double cost) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          Text('\$$cost', style: const TextStyle(fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }

  // Display total expenses and remaining budget
  Widget _buildBudgetSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budget Summary',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 10),
        _buildCostRow('Total Expenses', _totalExpenses),
        _buildCostRow('Remaining Budget', _remainingBudget),
      ],
    );
  }

  // Display the guest list with remove options
  Widget _buildGuestList() {
    return _guests.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: _guests.length,
            itemBuilder: (context, index) {
              final guest = _guests[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
                child: ListTile(
                  title: Text(guest),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      _removeGuest(index);
                    },
                  ),
                ),
              );
            },
          )
        : const Center(child: Text('No guests added', style: TextStyle(color: Colors.black54)));
  }

  // Section to add new guests
  Widget _buildAddGuestSection() {
    return Column(
      children: [
        TextField(
          controller: _guestController,
          decoration: const InputDecoration(
            labelText: 'Add Guest',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () {
            _addGuest(_guestController.text);
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Guest'),
        ),
      ],
    );
  }
}

