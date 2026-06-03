import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/goal_entity.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/goal_viewmodel.dart';

class GoalsScreen extends ConsumerWidget {
  final String userId;
  const GoalsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider(userId));

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
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            color: AppTheme.primaryGreen,
            onPressed: () => _showAddGoal(context, ref),
          ),
        ],
      ),
      body: goalsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (goals) {
          if (goals.isEmpty) {
            return _EmptyGoals(onAdd: () => _showAddGoal(context, ref));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (ctx, i) => _GoalCard(goal: goals[i], index: i),
          );
        },
      ),
    );
  }

  void _showAddGoal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddGoalSheet(userId: userId),
    );
  }
}

class _GoalCard extends ConsumerWidget {
  final GoalEntity goal;
  final int index;
  const _GoalCard({required this.goal, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final pct = (goal.progress * 100).toStringAsFixed(0);
    final daysLeft = goal.deadline.difference(DateTime.now()).inDays;

    return Dismissible(
      key: Key(goal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.expenseColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Excluir meta'),
          content: Text('Deseja remover "${goal.title}"?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppTheme.expenseColor),
              child: const Text('Excluir'),
            ),
          ],
        ),
      ),
      onDismissed: (_) =>
          ref.read(goalNotifierProvider.notifier).deleteGoal(goal.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: goal.isCompleted
              ? Border.all(color: AppTheme.primaryGreen, width: 1.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(goal.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      Text(
                        goal.isCompleted
                            ? '✅ Meta concluída!'
                            : daysLeft > 0
                                ? '$daysLeft dias restantes'
                                : 'Prazo encerrado',
                        style: TextStyle(
                          color: goal.isCompleted
                              ? AppTheme.primaryGreen
                              : daysLeft <= 7
                                  ? AppTheme.expenseColor
                                  : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$pct%',
                        style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w700,
                            fontSize: 18)),
                    Text(fmt.format(goal.targetAmount),
                        style:
                            TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: goal.progress,
                backgroundColor: AppTheme.primaryGreen.withOpacity(0.15),
                valueColor:
                    const AlwaysStoppedAnimation(AppTheme.primaryGreen),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(fmt.format(goal.currentAmount),
                    style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                Text('Faltam ${fmt.format(goal.remaining)}',
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
            if (!goal.isCompleted) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _addToGoal(context, ref),
                  icon: const Icon(Icons.add,
                      size: 16, color: AppTheme.primaryGreen),
                  label: const Text('Adicionar valor',
                      style: TextStyle(
                          color: AppTheme.primaryGreen, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ).animate(delay: Duration(milliseconds: index * 80)).fadeIn().slideY(begin: 0.1),
    );
  }

  void _addToGoal(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Adicionar a "${goal.title}"'),
        content: TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Valor (R\$)'),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final v =
                  double.tryParse(controller.text.replaceAll(',', '.'));
              if (v != null && v > 0) {
                await ref
                    .read(goalNotifierProvider.notifier)
                    .addToGoal(goal.id, v);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}

class _AddGoalSheet extends ConsumerStatefulWidget {
  final String userId;
  const _AddGoalSheet({required this.userId});

  @override
  ConsumerState<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends ConsumerState<_AddGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));
  String _emoji = '🎯';
  bool _loading = false;

  final _emojis = ['🎯', '🏠', '✈️', '🚗', '📱', '💻', '🎓', '💍', '🏋️', '🌴'];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text('Nova Meta',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _emojis
                    .map((e) => GestureDetector(
                          onTap: () => setState(() => _emoji = e),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: _emoji == e
                                  ? AppTheme.primaryGreen.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: _emoji == e
                                  ? Border.all(color: AppTheme.primaryGreen)
                                  : null,
                            ),
                            child: Center(
                                child: Text(e,
                                    style:
                                        const TextStyle(fontSize: 22))),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Título da meta',
                        prefixIcon: Icon(Icons.flag_outlined)),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: const InputDecoration(
                        labelText: 'Valor alvo',
                        prefixIcon: Icon(Icons.attach_money),
                        prefixText: 'R\$ '),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Campo obrigatório';
                      if (double.tryParse(v.replaceAll(',', '.')) == null)
                        return 'Valor inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _deadline,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now()
                            .add(const Duration(days: 365 * 10)),
                      );
                      if (picked != null) setState(() => _deadline = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .inputDecorationTheme
                            .fillColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 20, color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                              'Prazo: ${DateFormat('dd/MM/yyyy').format(_deadline)}',
                              style: const TextStyle(fontSize: 14)),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down,
                              color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.black))
                        : const Text('Criar Meta'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final amount =
        double.parse(_amountCtrl.text.replaceAll(',', '.'));
    final success =
        await ref.read(goalNotifierProvider.notifier).addGoal(
              userId: widget.userId,
              title: _titleCtrl.text.trim(),
              targetAmount: amount,
              deadline: _deadline,
              emoji: _emoji,
            );
    if (!mounted) return;
    setState(() => _loading = false);
    if (success) Navigator.pop(context);
  }
}

class _EmptyGoals extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyGoals({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎯', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text('Nenhuma meta ainda',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Crie sua primeira meta financeira!',
              style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Criar Meta'),
          ),
        ],
      ),
    );
  }
}