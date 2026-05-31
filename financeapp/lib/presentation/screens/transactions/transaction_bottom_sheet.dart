import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../viewmodels/transaction_viewmodel.dart';

class TransactionBottomSheet extends ConsumerStatefulWidget {
  final String userId;
  final TransactionEntity? editTransaction;

  const TransactionBottomSheet({
    super.key,
    required this.userId,
    this.editTransaction,
  });

  @override
  ConsumerState<TransactionBottomSheet> createState() => _TransactionBottomSheetState();
}

class _TransactionBottomSheetState extends ConsumerState<TransactionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  TransactionCategory _category = TransactionCategory.other;
  DateTime _date = DateTime.now();
  bool _isLoading = false;

  bool get _isEditing => widget.editTransaction != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.editTransaction!;
      _titleController.text = t.title;
      _amountController.text = t.amount.toStringAsFixed(2).replaceAll('.', ',');
      _descriptionController.text = t.description ?? '';
      _type = t.type;
      _category = t.category;
      _date = t.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final notifier = ref.read(transactionNotifierProvider.notifier);
    final amountStr = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(amountStr) ?? 0;

    bool success;
    if (_isEditing) {
      success = await notifier.updateTransaction(
        widget.editTransaction!.copyWith(
          title: _titleController.text.trim(),
          amount: amount,
          date: _date,
          type: _type,
          category: _category,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        ),
      );
    } else {
      success = await notifier.addTransaction(
        userId: widget.userId,
        title: _titleController.text.trim(),
        amount: amount,
        date: _date,
        type: _type,
        category: _category,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Transação atualizada!' : 'Transação adicionada!'),
          backgroundColor: AppTheme.incomeColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar transação.'),
          backgroundColor: AppTheme.expenseColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) setState(() => _date = picked);
  }

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
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Text(
              _isEditing ? 'Editar Transação' : 'Nova Transação',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),

            // Type Toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TypeButton(
                      label: 'Despesa',
                      icon: Icons.arrow_upward_rounded,
                      color: AppTheme.expenseColor,
                      selected: _type == TransactionType.expense,
                      onTap: () => setState(() => _type = TransactionType.expense),
                    ),
                  ),
                  Expanded(
                    child: _TypeButton(
                      label: 'Receita',
                      icon: Icons.arrow_downward_rounded,
                      color: AppTheme.incomeColor,
                      selected: _type == TransactionType.income,
                      onTap: () => setState(() => _type = TransactionType.income),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Title field
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Amount field
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Valor',
                      prefixIcon: Icon(Icons.attach_money),
                      prefixText: 'R\$ ',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Campo obrigatório';
                      final parsed = double.tryParse(v.replaceAll(',', '.'));
                      if (parsed == null || parsed <= 0) return 'Valor inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Category dropdown
                  DropdownButtonFormField<TransactionCategory>(
                    value: _category,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: TransactionCategory.values.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(_categoryLabel(c)),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                  const SizedBox(height: 12),

                  // Date picker
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, color: Colors.grey.shade600, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('dd/MM/yyyy', 'pt_BR').format(_date),
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_drop_down, color: Colors.grey.shade500),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description (optional)
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Descrição (opcional)',
                      prefixIcon: Icon(Icons.notes),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _type == TransactionType.income
                          ? AppTheme.incomeColor
                          : AppTheme.expenseColor,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_isEditing ? 'Salvar alterações' : 'Adicionar transação'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.3, duration: 300.ms, curve: Curves.easeOut);
  }

  String _categoryLabel(TransactionCategory c) {
    const labels = {
      TransactionCategory.salary: '💰 Salário',
      TransactionCategory.food: '🍔 Alimentação',
      TransactionCategory.transport: '🚗 Transporte',
      TransactionCategory.health: '🏥 Saúde',
      TransactionCategory.entertainment: '🎮 Lazer',
      TransactionCategory.education: '📚 Educação',
      TransactionCategory.housing: '🏠 Moradia',
      TransactionCategory.investment: '📈 Investimento',
      TransactionCategory.other: '📦 Outros',
    };
    return labels[c] ?? c.name;
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
