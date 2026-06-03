import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../viewmodels/news_viewmodel.dart';
import '../../widgets/common/transaction_list_item.dart';
import '../../widgets/skeleton/transaction_skeleton.dart';
import '../../widgets/skeleton/news_skeleton.dart';
import '../../widgets/common/news_card.dart';
import '../transactions/transaction_bottom_sheet.dart';

class HomeScreen extends ConsumerWidget {
  final String userId;
  final String userName;

  const HomeScreen({super.key, required this.userId, required this.userName});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bom dia';
    if (h < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final balance = ref.watch(balanceProvider(userId));
    final income = ref.watch(totalIncomeProvider(userId));
    final expense = ref.watch(totalExpenseProvider(userId));
    final transactionsAsync = ref.watch(transactionsProvider(userId));
    final newsAsync = ref.watch(newsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1A1A1A), const Color(0xFF0A0A0A)]
                      : [AppTheme.primaryGreen.withOpacity(0.1), Colors.white],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_greeting()}, ${userName.split(' ').first}! 👋',
                            style: TextStyle(
                              color: isDark ? Colors.grey : Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Smart',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const TextSpan(
                                  text: 'Wallet',
                                  style: TextStyle(
                                    color: AppTheme.primaryGreen,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _openAddTransaction(context, userId),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.add, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryGreen, AppTheme.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Saldo Total',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          fmt.format(balance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _BalanceStat(
                                icon: Icons.arrow_downward_rounded,
                                label: 'Receitas',
                                value: fmt.format(income),
                                color: Colors.white,
                              ),
                            ),
                            Container(width: 1, height: 36, color: Colors.white24),
                            Expanded(
                              child: _BalanceStat(
                                icon: Icons.arrow_upward_rounded,
                                label: 'Despesas',
                                value: fmt.format(expense),
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Últimas Transações',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Ver todas',
                        style: TextStyle(color: AppTheme.primaryGreen, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),

          transactionsAsync.when(
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, __) => const TransactionSkeleton(),
                childCount: 3,
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(child: Text('Erro: $e')),
            ),
            data: (transactions) {
              final recent = transactions.take(5).toList();
              if (recent.isEmpty) {
                return SliverToBoxAdapter(
                  child: _EmptyTransactions(
                    onAdd: () => _openAddTransaction(context, userId),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => TransactionListItem(
                      transaction: recent[i],
                      userId: userId,
                      index: i,
                    ),
                    childCount: recent.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text('Notícias Financeiras',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),

          newsAsync.when(
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, __) => const NewsSkeleton(),
                childCount: 3,
              ),
            ),
            error: (_, __) => SliverToBoxAdapter(
              child: _NewsError(onRetry: () => ref.invalidate(newsProvider)),
            ),
            data: (articles) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => NewsCard(article: articles[i], index: i),
                  childCount: articles.length,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openAddTransaction(BuildContext context, String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransactionBottomSheet(userId: userId),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _BalanceStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color.withOpacity(0.8), size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 11)),
            Text(value, style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyTransactions({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 56, color: Colors.grey.shade600),
          const SizedBox(height: 12),
          Text('Nenhuma transação ainda',
              style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, color: AppTheme.primaryGreen),
            label: const Text('Adicionar agora',
                style: TextStyle(color: AppTheme.primaryGreen)),
          ),
        ],
      ),
    );
  }
}

class _NewsError extends StatelessWidget {
  final VoidCallback onRetry;
  const _NewsError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.wifi_off_rounded, size: 40, color: Colors.grey.shade600),
          const SizedBox(height: 8),
          Text('Sem conexão', style: TextStyle(color: Colors.grey.shade500)),
          TextButton(
            onPressed: onRetry,
            child: const Text('Tentar novamente',
                style: TextStyle(color: AppTheme.primaryGreen)),
          ),
        ],
      ),
    );
  }
}