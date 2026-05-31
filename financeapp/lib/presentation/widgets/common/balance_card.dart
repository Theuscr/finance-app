import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../viewmodels/transaction_viewmodel.dart';

class BalanceCard extends ConsumerWidget {
  final String userId;
  const BalanceCard({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final income = ref.watch(totalIncomeProvider(userId));
    final expense = ref.watch(totalExpenseProvider(userId));
    final total = income + expense;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo do Mês',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            if (total == 0)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Sem dados ainda',
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                ),
              )
            else
              SizedBox(
                height: 160,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              value: income,
                              color: AppTheme.incomeColor,
                              title: '',
                              radius: 30,
                            ),
                            PieChartSectionData(
                              value: expense,
                              color: AppTheme.expenseColor,
                              title: '',
                              radius: 30,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _LegendItem(
                            color: AppTheme.incomeColor,
                            label: 'Receitas',
                            value: income,
                            total: total,
                          ),
                          const SizedBox(height: 16),
                          _LegendItem(
                            color: AppTheme.expenseColor,
                            label: 'Despesas',
                            value: expense,
                            total: total,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final double value;
  final double total;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final pct = total > 0 ? (value / total * 100).toStringAsFixed(0) : '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const Spacer(),
            Text('$pct%', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          fmt.format(value),
          style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 16),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: total > 0 ? value / total : 0,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
