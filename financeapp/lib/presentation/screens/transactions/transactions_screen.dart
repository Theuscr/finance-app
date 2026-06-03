import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../widgets/common/transaction_list_item.dart';
import '../../widgets/skeleton/transaction_skeleton.dart';
import '../transactions/transaction_bottom_sheet.dart';

class TransactionsScreen extends ConsumerWidget {
  final String userId;
  const TransactionsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(transactionFilterProvider);
    final transactionsAsync = ref.watch(transactionsProvider(userId));
    final filtered = ref.watch(filteredTransactionsProvider(userId));

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
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            color: AppTheme.primaryGreen,
            onPressed: () => _openAdd(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Todas',
                  selected: filter == null,
                  color: AppTheme.primaryGreen,
                  onTap: () =>
                      ref.read(transactionFilterProvider.notifier).state = null,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Receitas',
                  selected: filter == TransactionType.income,
                  color: AppTheme.incomeColor,
                  onTap: () => ref
                      .read(transactionFilterProvider.notifier)
                      .state = TransactionType.income,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Despesas',
                  selected: filter == TransactionType.expense,
                  color: AppTheme.expenseColor,
                  onTap: () => ref
                      .read(transactionFilterProvider.notifier)
                      .state = TransactionType.expense,
                ),
              ],
            ),
          ),
        ),
      ),
      body: transactionsAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: List.generate(8, (_) => const TransactionSkeleton()),
        ),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (_) {
          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64, color: Colors.grey.shade600),
                  const SizedBox(height: 16),
                  Text('Nenhuma transação',
                      style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (ctx, i) => TransactionListItem(
              transaction: filtered[i],
              userId: userId,
              index: i,
            ),
          );
        },
      ),
    );
  }

  void _openAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransactionBottomSheet(userId: userId),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}