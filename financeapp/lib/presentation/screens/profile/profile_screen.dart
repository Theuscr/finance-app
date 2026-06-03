import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authViewModelProvider);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return userAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const LoginScreen(),
      data: (user) {
        if (user == null) return const LoginScreen();
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
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _ProfileHeader(name: user.name, email: user.email)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.1),
                const SizedBox(height: 28),

                _SectionLabel(label: 'Conta'),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.person_outline,
                      label: 'Editar perfil',
                      onTap: () => _showEditProfile(context, ref, user.name),
                    ),
                    _Divider(),
                    _SettingsTile(
                      icon: Icons.lock_outline,
                      label: 'Alterar senha',
                      onTap: () => _showChangePassword(context),
                    ),
                  ],
                ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),

                const SizedBox(height: 16),

                _SectionLabel(label: 'Preferências'),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                              color: AppTheme.primaryGreen,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              isDark ? 'Tema Escuro' : 'Tema Claro',
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                            ),
                          ),
                          Switch(
                            value: isDark,
                            onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1),

                const SizedBox(height: 16),

                _SectionLabel(label: 'Sobre'),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.info_outline,
                      label: 'Versão do app',
                      trailing: Text('1.0.0',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                      onTap: null,
                    ),
                  ],
                ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context, ref),
                    icon: const Icon(Icons.logout, color: AppTheme.expenseColor),
                    label: const Text(
                      'Sair da conta',
                      style: TextStyle(
                          color: AppTheme.expenseColor, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.expenseColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ).animate(delay: 400.ms).fadeIn(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditProfile(BuildContext context, WidgetRef ref, String currentName) {
    final ctrl = TextEditingController(text: currentName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Editar Perfil',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              TextFormField(
                controller: ctrl,
                decoration: const InputDecoration(
                    labelText: 'Nome completo',
                    prefixIcon: Icon(Icons.person_outline)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Salvar'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChangePassword(BuildContext context) {
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade600,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Alterar Senha',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: newCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Nova senha',
                      prefixIcon: Icon(Icons.lock_outline)),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Campo obrigatório';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Confirmar nova senha',
                      prefixIcon: Icon(Icons.lock_outline)),
                  validator: (v) {
                    if (v != newCtrl.text) return 'As senhas não coincidem';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Senha alterada com sucesso!'),
                          backgroundColor: AppTheme.primaryGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: const Text('Alterar Senha'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (_, a, b) => const LoginScreen(),
                  transitionsBuilder: (_, anim, __, child) =>
                      FadeTransition(opacity: anim, child: child),
                ),
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

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  const _ProfileHeader({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryGreen, AppTheme.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(email, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
      ),
      title: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey)
              : null),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, indent: 66, color: Theme.of(context).dividerColor);
  }
}