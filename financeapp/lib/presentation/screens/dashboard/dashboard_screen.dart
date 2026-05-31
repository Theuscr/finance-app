import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../viewmodels/news_viewmodel.dart';
import '../../widgets/common/balance_card.dart';
import '../../widgets/common/transaction_list_item.dart';
import '../../widgets/common/news_card.dart';
import '../../widgets/skeleton/transaction_skeleton.dart';
import '../../widgets/skeleton/news_skeleton.dart';
import '../transactions/transaction_bottom_sheet.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _currentTab = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authViewModelProvider);

    return userAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const LoginScreen(),
      data: (user) {
        if (user == null) return const LoginScreen();
        return _buildScaffold(context, user.id, user.name);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, String userId, String userName) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildAppBarBackground(context, userId, userName),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () => _confirmLogout(context),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.accentColor,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              onTap: (i) => setState(() => _currentTab = i),
              tabs: const [
                Tab(text: 'Início'),
                Tab(text: 'Transações'),
                Tab(text: 'Notícias'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _HomeTab(userId: userId),
            _TransactionsTab(userId: userId),
            const _NewsTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddTransaction(context, userId),
        icon: const Icon(Icons.add),
        label: const Text('Nova transação'),
      ),
    );
  }

  Widget _buildAppBarBackground(BuildContext context, String userId, String userName) {
    final balance = ref.watch(balanceProvider(userId));
    final income = ref.watch(totalIncomeProvider(userId));
    final expense = ref.watch(totalExpenseProvider(userId));
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, Color(0xFF2D3499)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Olá, ${userName.split(' ').first}! 👋',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            fmt.format(balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.3),
          const SizedBox(height: 8),
          Row(
            children: [
              _MiniStat(
                icon: Icons.arrow_downward_rounded,
                label: 'Receitas',
                value: fmt.format(income),
                color: AppTheme.incomeColor,
              ),
              const SizedBox(width: 24),
              _MiniStat(
                icon: Icons.arrow_upward_rounded,
                label: 'Despesas',
                value: fmt.format(expense),
                color: AppTheme.expenseColor,
              ),
            ],
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

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).logout();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.expenseColor),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

// ────────────────────────── TABS ──────────────────────────

class _HomeTab extends ConsumerWidget {
  final String userId;
  const _HomeTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider(userId));

    return transactionsAsync.when(
      loading: () => ListView(
        padding: const EdgeInsets.all(16),
        children: List.generate(5, (_) => const TransactionSkeleton()),
      ),
      error: (e, _) => Center(child: Text('Erro: $e')),
      data: (transactions) {
        final recent = transactions.take(5).toList();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BalanceCard(userId: userId),
            const SizedBox(height: 20),
            _SectionHeader(
              title: 'Últimas Transações',
              onSeeAll: () {},
            ),
            const SizedBox(height: 8),
            if (recent.isEmpty)
              _EmptyState()
            else
              ...recent.asMap().entries.map((e) => TransactionListItem(
                    transaction: e.value,
                    userId: userId,
                    index: e.key,
                  )),
          ],
        );
      },
    );
  }
}

class _TransactionsTab extends ConsumerWidget {
  final String userId;
  const _TransactionsTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(transactionFilterProvider);
    final transactions = ref.watch(filteredTransactionsProvider(userId));
    final transactionsAsync = ref.watch(transactionsProvider(userId));

    return Column(
      children: [
        // Filter chips
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _FilterChip(
                label: 'Todas',
                selected: filter == null,
                onTap: () => ref.read(transactionFilterProvider.notifier).state = null,
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Receitas',
                selected: filter == TransactionType.income,
                color: AppTheme.incomeColor,
                onTap: () => ref.read(transactionFilterProvider.notifier).state =
                    TransactionType.income,
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Despesas',
                selected: filter == TransactionType.expense,
                color: AppTheme.expenseColor,
                onTap: () => ref.read(transactionFilterProvider.notifier).state =
                    TransactionType.expense,
              ),
            ],
          ),
        ),
        // List
        Expanded(
          child: transactionsAsync.when(
            loading: () => ListView(
              padding: const EdgeInsets.all(16),
              children: List.generate(8, (_) => const TransactionSkeleton()),
            ),
            error: (e, _) => Center(child: Text('Erro: $e')),
            data: (_) {
              if (transactions.isEmpty) return _EmptyState();
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: transactions.length,
                itemBuilder: (ctx, i) => TransactionListItem(
                  transaction: transactions[i],
                  userId: userId,
                  index: i,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NewsTab extends ConsumerWidget {
  const _NewsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsProvider);

    return newsAsync.when(
      loading: () => ListView(
        padding: const EdgeInsets.all(16),
        children: List.generate(4, (_) => const NewsSkeleton()),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Sem conexão com a internet', style: TextStyle(color: Colors.grey.shade500)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(newsProvider),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
      data: (articles) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: articles.length,
        itemBuilder: (ctx, i) => NewsCard(article: articles[i], index: i),
      ),
    );
  }
}

// ────────────────────────── HELPERS ──────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text('Ver todas', style: TextStyle(color: AppTheme.primaryColor)),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Nenhuma transação ainda',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Toque no botão + para adicionar',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? c : c.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : c,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
