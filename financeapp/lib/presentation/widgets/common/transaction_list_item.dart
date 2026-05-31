import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../screens/transactions/transaction_bottom_sheet.dart';

class TransactionListItem extends ConsumerWidget {
  final TransactionEntity transaction;
  final String userId;
  final int index;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.userId,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFmt = DateFormat('dd/MM/yy', 'pt_BR');
    final isIncome = transaction.isIncome;
    final color = isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.expenseColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white),
            SizedBox(height: 4),
            Text('Excluir', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) {
        ref.read(transactionNotifierProvider.notifier).deleteTransaction(transaction.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Transação removida'),
            backgroundColor: Colors.grey.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_categoryIcon(transaction.category), color: color, size: 22),
          ),
          title: Text(
            transaction.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${_categoryLabel(transaction.category)} • ${dateFmt.format(transaction.date)}',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'} ${fmt.format(transaction.amount)}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              Icon(
                isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: color,
                size: 14,
              ),
            ],
          ),
          onTap: () => _showOptions(context, ref),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 60))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1);
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir transação'),
        content: Text('Deseja remover "${transaction.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.expenseColor),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransactionBottomSheet(
        userId: userId,
        editTransaction: transaction,
      ),
    );
  }

  IconData _categoryIcon(TransactionCategory c) {
    const icons = {
      TransactionCategory.salary: Icons.payments_outlined,
      TransactionCategory.food: Icons.restaurant_outlined,
      TransactionCategory.transport: Icons.directions_car_outlined,
      TransactionCategory.health: Icons.favorite_border,
      TransactionCategory.entertainment: Icons.sports_esports_outlined,
      TransactionCategory.education: Icons.school_outlined,
      TransactionCategory.housing: Icons.home_outlined,
      TransactionCategory.investment: Icons.trending_up,
      TransactionCategory.other: Icons.category_outlined,
    };
    return icons[c] ?? Icons.category_outlined;
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
}
