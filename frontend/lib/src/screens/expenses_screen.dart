import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/currency_formatter.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  ExpenseMode? _selectedMode;
  String _searchQuery = '';
  // Default lists are now persisted in DB. UI reads from CategoryProvider.
  // Keep local search state only.
  

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<ExpenseProvider>(context, listen: false).loadExpenses();
      // load categories from DB
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
  }

  void _openCategorySelector(ExpenseMode mode) {
    setState(() {
      _selectedMode = mode;
      _searchQuery = '';
    });
  }

  void _closeCategorySelector() {
    setState(() {
      _selectedMode = null;
      _searchQuery = '';
    });
  }

  void _createCustomCategory() async {
    final type = _selectedMode == ExpenseMode.income ? 'income' : 'expense';
    final typeLabel = type;
    final controller = TextEditingController();
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final added = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Custom $typeLabel category'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Category name', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Save')),
          ],
        );
      },
    );

    if (added == true && controller.text.trim().isNotEmpty) {
      final name = controller.text.trim();
      await categoryProvider.addCategory(name: name, type: type, userId: auth.user?.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Custom $typeLabel category added')));
    }
  }


  void _onCategoryTap(String category) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);

    final nameController = TextEditingController(text: category);
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    DateTime chosenDate = DateTime.now();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Transaction', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Amount (₹)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes (optional)'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Date: ${chosenDate.toLocal().toString().split(' ')[0]}'),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: chosenDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) {
                          chosenDate = d;
                          // rebuild sheet
                          (context as Element).markNeedsBuild();
                        }
                      },
                      child: const Text('Change'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final text = nameController.text.trim();
                          final amt = double.tryParse(amountController.text.trim()) ?? 0.0;
                          if (amt <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
                            return;
                          }
                          final notes = notesController.text.trim();
                          Navigator.of(context).pop(true);
                          // perform save outside sheet to allow bottom sheet to close
                          expenseProvider.addExpense(
                            name: text.isEmpty ? category : text,
                            category: category,
                            amount: amt,
                            date: chosenDate,
                            notes: notes,
                            userId: auth.user?.id ?? '',
                          );
                        },
                        child: const Text('Save'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );

    if (saved == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final cashFlowData = _cashFlowGroups;
    final totalIncome = cashFlowData.fold<double>(0, (sum, group) => sum + group.income);
    final totalExpense = cashFlowData.fold<double>(0, (sum, group) => sum + group.expense);
    final netCashFlow = totalIncome - totalExpense;

    if (_selectedMode != null) {
      final rawCategories = (() {
        final cp = Provider.of<CategoryProvider>(context, listen: false);
        return _selectedMode == ExpenseMode.income ? cp.incomeCategories : cp.expenseCategories;
      })();
      final isIncome = _selectedMode == ExpenseMode.income;
      final filtered = rawCategories.where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF6D28D9),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _closeCategorySelector,
          ),
          title: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedMode = ExpenseMode.expense),
                  child: Text(
                    'EXPENSE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isIncome ? Colors.white70 : Colors.white,
                      fontWeight: isIncome ? FontWeight.w500 : FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedMode = ExpenseMode.income),
                  child: Text(
                    'INCOME',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isIncome ? Colors.white : Colors.white70,
                      fontWeight: isIncome ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                final value = await showDialog<String?>(
                  context: context,
                  builder: (context) {
                    final controller = TextEditingController(text: _searchQuery);
                    return AlertDialog(
                      title: const Text('Search category'),
                      content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(hintText: 'Type category name'),
                        autofocus: true,
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancel')),
                        ElevatedButton(onPressed: () => Navigator.of(context).pop(controller.text), child: const Text('Search')),
                      ],
                    );
                  },
                );
                if (value != null) {
                  setState(() {
                    _searchQuery = value.trim();
                  });
                }
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              ...filtered.map((category) {
                final color = isIncome ? Colors.green.shade600 : Colors.red.shade600;
                return GestureDetector(
                  onTap: () => _onCategoryTap(category.name),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 6)),
                          ],
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: color,
                              radius: 24,
                              child: Text(
                                category.name[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              category.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: PopupMenuButton<String>(
                          onSelected: (choice) async {
                            if (choice == 'edit') {
                              final controller = TextEditingController(text: category.name);
                              final cp = Provider.of<CategoryProvider>(context, listen: false);
                              final auth = Provider.of<AuthProvider>(context, listen: false);
                              final saved = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Edit category'),
                                    content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Name')),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                                      ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Save')),
                                    ],
                                  );
                                },
                              );
                              if (saved == true && controller.text.trim().isNotEmpty) {
                                await cp.updateCategory(id: category.id, name: controller.text.trim(), userId: auth.user?.id);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category updated')));
                                setState(() {});
                              }
                            } else if (choice == 'delete') {
                              final cp = Provider.of<CategoryProvider>(context, listen: false);
                              final auth = Provider.of<AuthProvider>(context, listen: false);
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Delete category'),
                                    content: Text('Delete "${category.name}"? This action cannot be undone.'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                                      ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
                                    ],
                                  );
                                },
                              );
                              if (confirm == true) {
                                await cp.deleteCategory(id: category.id, userId: auth.user?.id);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category deleted')));
                                setState(() {});
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                          icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              GestureDetector(
                onTap: _createCustomCategory,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 6)),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF6D28D9),
                        radius: 24,
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Custom',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF6D28D9),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        const Expanded(
                          child: Text(
                            'Cash Flow',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6D28D9)),
                            onPressed: () {},
                          ),
                          Row(
                            children: const [
                              Icon(Icons.calendar_today, color: Color(0xFF6D28D9)),
                              SizedBox(width: 8),
                              Text('26 Jul 2026 - 01 Aug 2026', style: TextStyle(color: Color(0xFF6D28D9), fontWeight: FontWeight.w600)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFF6D28D9)),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('Net Cash Flow', style: TextStyle(color: Colors.white.withAlpha(220), fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(CurrencyFormatter.format(netCashFlow), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.lightGreenAccent)),
                    const SizedBox(height: 4),
                    Text('(Total Income - Total Expense)', style: TextStyle(color: Colors.white.withAlpha(204))),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              children: [
                                const Text('Income', style: TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Text(CurrencyFormatter.format(totalIncome), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              children: [
                                const Text('Expense', style: TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Text(CurrencyFormatter.format(totalExpense), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: expenseProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 140),
                        itemCount: cashFlowData.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final group = cashFlowData[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(group.dateLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(group.dayLabel, style: const TextStyle(color: Colors.grey)),
                                  Row(
                                    children: [
                                      Text('+ ${CurrencyFormatter.format(group.income)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 12),
                                      Text('- ${CurrencyFormatter.format(group.expense)}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Column(
                                children: group.transactions.map((transaction) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: const [
                                          BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 6)),
                                        ],
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: transaction.isIncome ? Colors.green.shade50 : Colors.red.shade50,
                                          child: Text(transaction.title[0], style: TextStyle(color: transaction.isIncome ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                                        ),
                                        title: Text(transaction.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        subtitle: Text(transaction.subtitle),
                                        trailing: Text(
                                          '${transaction.isIncome ? '+' : '-'} ${CurrencyFormatter.format(transaction.amount)}',
                                          style: TextStyle(color: transaction.isIncome ? Colors.green : Colors.redAccent, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 18,
          left: 18,
          right: 18,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () => _openCategorySelector(ExpenseMode.income),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Income', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () => _openCategorySelector(ExpenseMode.expense),
                  icon: const Icon(Icons.remove, color: Colors.white),
                  label: const Text('Expense', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum ExpenseMode { income, expense }

class _CashFlowGroup {
  final String dateLabel;
  final String dayLabel;
  final double income;
  final double expense;
  final List<_CashFlowTransaction> transactions;

  _CashFlowGroup({
    required this.dateLabel,
    required this.dayLabel,
    required this.income,
    required this.expense,
    required this.transactions,
  });
}

class _CashFlowTransaction {
  final String title;
  final String subtitle;
  final double amount;
  final bool isIncome;

  _CashFlowTransaction({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
  });
}

final List<_CashFlowGroup> _cashFlowGroups = [
  _CashFlowGroup(
    dateLabel: '31 Jul 2026 (Yesterday)',
    dayLabel: 'Yesterday',
    income: 2350,
    expense: 270,
    transactions: [
      _CashFlowTransaction(title: 'Personal', subtitle: 'Hacky Pizza', amount: 50, isIncome: false),
      _CashFlowTransaction(title: 'Carry Bag Or Napkins', subtitle: 'Hacky Pizza', amount: 50, isIncome: false),
      _CashFlowTransaction(title: 'Vegetable', subtitle: 'Hacky Pizza', amount: 20, isIncome: false),
      _CashFlowTransaction(title: 'Vegetable', subtitle: 'Hacky Pizza', amount: 150, isIncome: false),
      _CashFlowTransaction(title: 'Sale', subtitle: 'Hacky Pizza', amount: 2350, isIncome: true),
    ],
  ),
  _CashFlowGroup(
    dateLabel: '30 Jul 2026',
    dayLabel: 'Two days ago',
    income: 3300,
    expense: 2078,
    transactions: [
      _CashFlowTransaction(title: 'Sale', subtitle: 'Hacky Pizza', amount: 3300, isIncome: true),
      _CashFlowTransaction(title: 'Salaries', subtitle: 'Hacky Pizza', amount: 1200, isIncome: false),
      _CashFlowTransaction(title: 'Packaging', subtitle: 'Hacky Pizza', amount: 300, isIncome: false),
      _CashFlowTransaction(title: 'Electricity', subtitle: 'Hacky Pizza', amount: 578, isIncome: false),
    ],
  ),
];
