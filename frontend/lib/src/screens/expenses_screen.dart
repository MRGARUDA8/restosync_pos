import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/currency_formatter.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _category = 'Rent';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen: false).loadExpenses();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitExpense() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (_nameController.text.isEmpty || amount <= 0 || !authProvider.isLoggedIn) {
      return;
    }
    await expenseProvider.addExpense(
      name: _nameController.text,
      category: _category,
      amount: amount,
      date: DateTime.now(),
      notes: _notesController.text,
      userId: authProvider.user!.id,
    );
    if (!mounted) return;
    _nameController.clear();
    _amountController.clear();
    _notesController.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense added')));
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Expenses', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text('Add Expense', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Expense Name', border: OutlineInputBorder())),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                        initialValue: _category,
                          decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'Rent', child: Text('Rent')),
                            DropdownMenuItem(value: 'Electricity', child: Text('Electricity')),
                            DropdownMenuItem(value: 'Gas', child: Text('Gas')),
                            DropdownMenuItem(value: 'Staff Salary', child: Text('Staff Salary')),
                            DropdownMenuItem(value: 'Raw Material', child: Text('Raw Material')),
                            DropdownMenuItem(value: 'Maintenance', child: Text('Maintenance')),
                            DropdownMenuItem(value: 'Marketing', child: Text('Marketing')),
                            DropdownMenuItem(value: 'Other', child: Text('Other')),
                          ],
                          onChanged: (value) {
                            if (value != null) setState(() => _category = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder())),
                        const SizedBox(height: 12),
                        TextField(controller: _notesController, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder())),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _submitExpense, child: const Text('Add Expense')),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: expenseProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Recent Expenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: expenseProvider.expenses.length,
                                  itemBuilder: (context, index) {
                                    final expense = expenseProvider.expenses[index];
                                    return ListTile(
                                      title: Text(expense.name),
                                      subtitle: Text(expense.category),
                                      trailing: Text(CurrencyFormatter.format(expense.amount)),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
