import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/report_provider.dart';
import '../widgets/metric_card.dart';
import '../utils/currency_formatter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportProvider>(context, listen: false).loadDashboardMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<ReportProvider>(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 1100 ? 3 : 1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3.8,
            children: [
              MetricCard(
                title: 'Today Sale',
                value: CurrencyFormatter.format(reportProvider.totalSales),
                icon: Icons.currency_rupee,
                color: Colors.orangeAccent,
              ),
              MetricCard(
                title: 'Today Expenses',
                value: CurrencyFormatter.format(reportProvider.totalExpenses),
                icon: Icons.money_off,
                color: Colors.redAccent,
              ),
              MetricCard(
                title: 'Net Profit',
                value: CurrencyFormatter.format(reportProvider.totalSales - reportProvider.totalExpenses),
                icon: Icons.trending_up,
                color: Colors.greenAccent,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Hourly Sales', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 260,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 1200),
                          FlSpot(2, 1750),
                          FlSpot(4, 2100),
                          FlSpot(6, 1800),
                          FlSpot(8, 2400),
                          FlSpot(10, 2600),
                          FlSpot(12, 2900),
                        ],
                        isCurved: true,
                        color: Colors.orangeAccent,
                        barWidth: 4,
                        dotData: FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _DashboardSummaryCard(title: 'Peak Hour', value: '7:00 PM'),
              _DashboardSummaryCard(title: 'Pending Deliveries', value: '4'),
              _DashboardSummaryCard(title: 'Low Stock Alerts', value: '2'),
              _DashboardSummaryCard(title: 'Open Bills', value: '1'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardSummaryCard extends StatelessWidget {
  final String title;
  final String value;

  const _DashboardSummaryCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
