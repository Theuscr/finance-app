import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../widgets/skeleton/transaction_skeleton.dart';

class ChartsScreen extends ConsumerStatefulWidget {
  final String userId;
  const ChartsScreen({super.key, required this.userId});

  @override
  ConsumerState<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends ConsumerState<ChartsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider(widget.userId));

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Smart',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const TextSpan(
                text: 'Wallet',
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryGreen,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Por Categoria'),
            Tab(text: 'Por Mês'),
          ],
        ),
      ),
      body: transactionsAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: List.generate(4, (_) => const TransactionSkeleton()),
        ),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (transactions) => TabBarView(
          controller: _tabController,
          children: [
            _CategoryChart(transactions: transactions),
            _MonthlyChart(transactions: transactions),
          ],
        ),
      ),
    );
  }
}

class _CategoryChart extends StatefulWidget {
  final List<TransactionEntity> transactions;
  const _CategoryChart({required this.transactions});

  @override
  State<_CategoryChart> createState() => _CategoryChartState();
}

class _CategoryChartState extends State<_CategoryChart> {
  int _touchedIndex = -1;
  TransactionType _filter = TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final filtered = widget.transactions.where((t) => t.type == _filter).toList();

    final Map<TransactionCategory, double> byCategory = {};
    for (final t in filtered) {
      byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount;
    }
    final total = byCategory.values.fold(0.0, (a, b) => a + b);
    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ChipButton(
                    label: 'Despesas',
                    selected: _filter == TransactionType.expense,
                    color: AppTheme.expenseColor,
                    onTap: () => setState(() => _filter = TransactionType.expense),
                  ),
                ),
                Expanded(
                  child: _ChipButton(
                    label: 'Receitas',
                    selected: _filter == TransactionType.income,
                    color: AppTheme.incomeColor,
                    onTap: () => setState(() => _filter = TransactionType.income),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey.shade600),
                  const SizedBox(height: 12),
                  Text('Sem dados', style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            )
          else ...[
            SizedBox(
              height: 240,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        _touchedIndex = response?.touchedSection?.touchedSectionIndex ?? -1;
                      });
                    },
                  ),
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: entries.asMap().entries.map((e) {
                    final isTouched = e.key == _touchedIndex;
                    final color = AppTheme.chartColors[e.key % AppTheme.chartColors.length];
                    final pct = total > 0 ? e.value.value / total * 100 : 0;
                    return PieChartSectionData(
                      value: e.value.value,
                      color: color,
                      radius: isTouched ? 70 : 55,
                      title: '${pct.toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ).animate().fadeIn(delay: 200.ms),
            ),
            const SizedBox(height: 24),
            ...entries.asMap().entries.map((e) {
              final color = AppTheme.chartColors[e.key % AppTheme.chartColors.length];
              final pct = total > 0 ? e.value.value / total * 100 : 0;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),
                    Text(_categoryLabel(e.value.key),
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    const Spacer(),
                    Text(fmt.format(e.value.value),
                        style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Text('${pct.toStringAsFixed(0)}%',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ).animate(delay: Duration(milliseconds: e.key * 60)).fadeIn().slideX(begin: 0.1);
            }),
          ],
        ],
      ),
    );
  }
}

class _MonthlyChart extends StatelessWidget {
  final List<TransactionEntity> transactions;
  const _MonthlyChart({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final now = DateTime.now();

    final months = List.generate(6, (i) {
      return DateTime(now.year, now.month - (5 - i));
    });

    final incomeByMonth = <int, double>{};
    final expenseByMonth = <int, double>{};
    for (final m in months) {
      final key = m.month + m.year * 100;
      incomeByMonth[key] = 0;
      expenseByMonth[key] = 0;
    }
    for (final t in transactions) {
      final key = t.date.month + t.date.year * 100;
      if (incomeByMonth.containsKey(key)) {
        if (t.isIncome) incomeByMonth[key] = (incomeByMonth[key] ?? 0) + t.amount;
        if (t.isExpense) expenseByMonth[key] = (expenseByMonth[key] ?? 0) + t.amount;
      }
    }

    final keys = months.map((m) => m.month + m.year * 100).toList();
    final maxY = [...incomeByMonth.values, ...expenseByMonth.values]
        .fold(0.0, (a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Últimos 6 Meses',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: maxY > 0 ? maxY * 1.2 : 100,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= months.length) return const SizedBox();
                          return Text(
                            DateFormat('MMM', 'pt_BR').format(months[idx]),
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(keys.length, (i) {
                    final k = keys[i];
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: incomeByMonth[k] ?? 0,
                          color: AppTheme.incomeColor,
                          width: 10,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                        BarChartRodData(
                          toY: expenseByMonth[k] ?? 0,
                          color: AppTheme.expenseColor,
                          width: 10,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }),
                ),
              ).animate().fadeIn(delay: 200.ms),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Legend(color: AppTheme.incomeColor, label: 'Receitas'),
              const SizedBox(width: 20),
              _Legend(color: AppTheme.expenseColor, label: 'Despesas'),
            ],
          ),
          const SizedBox(height: 24),
          ...months.reversed.map((m) {
            final k = m.month + m.year * 100;
            final inc = incomeByMonth[k] ?? 0;
            final exp = expenseByMonth[k] ?? 0;
            final bal = inc - exp;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    DateFormat('MMMM yyyy', 'pt_BR').format(m),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    fmt.format(bal),
                    style: TextStyle(
                      color: bal >= 0 ? AppTheme.incomeColor : AppTheme.expenseColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _ChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ChipButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

String _categoryLabel(TransactionCategory c) {
  const labels = {
    TransactionCategory.salary: 'Salário',
    TransactionCategory.food: 'Alimentação',
    TransactionCategory.transport: 'Transporte',
    TransactionCategory.health: 'Saúde',
    TransactionCategory.entertainment: 'Lazer',
    TransactionCategory.education: 'Educação',
    TransactionCategory.housing: 'Moradia',
    TransactionCategory.investment: 'Investimento',
    TransactionCategory.other: 'Outros',
  };
  return labels[c] ?? c.name;
}