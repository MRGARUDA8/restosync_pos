import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sales Reports & Analytics', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 1100 ? 2 : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _ReportCard(title: 'Daily Sales', child: _buildBarChart()),
                _ReportCard(title: 'Monthly Sales', child: _buildLineChart()),
                _ReportCard(title: 'Expense vs Sales', child: _buildPieChart()),
                _ReportCard(title: 'Top Selling Pizzas', child: _buildBarChart()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 50),
              FlSpot(2, 85),
              FlSpot(4, 90),
              FlSpot(6, 70),
              FlSpot(8, 110),
              FlSpot(10, 130),
            ],
            isCurved: true,
            color: Colors.deepOrangeAccent,
            barWidth: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 70)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 120)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 90)]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 150)]),
          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 180)]),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(value: 45, color: Colors.green, title: 'Sales'),
          PieChartSectionData(value: 25, color: Colors.red, title: 'Expenses'),
          PieChartSectionData(value: 30, color: Colors.blue, title: 'Profit'),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ReportCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
