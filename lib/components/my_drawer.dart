import 'package:evolution_cam/components/app_widgets.dart';
import 'package:evolution_cam/configs/app_controller.dart';
import 'package:evolution_cam/configs/theme.dart';
import 'package:evolution_cam/services/auth_service.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  /// 'home' ou 'profile': decide o item destacado.
  final String page;

  const MyDrawer({Key? key, required this.page}) : super(key: key);

  void _go(BuildContext context, String route, bool alreadyHere) {
    Navigator.of(context).pop(); // fecha o menu
    if (!alreadyHere) Navigator.of(context).pushReplacementNamed(route);
  }

  Future<void> _logOut(BuildContext context) async {
    final navigator = Navigator.of(context);
    await AuthService.instance.signOut();
    navigator.pushNamedAndRemoveUntil('/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final auth = AuthService.instance;
    final name = auth.displayName;

    Widget item({
      required IconData icon,
      required IconData selectedIcon,
      required String label,
      required bool selected,
      required VoidCallback onTap,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: ListTile(
          selected: selected,
          selectedTileColor: scheme.primaryContainer,
          selectedColor: scheme.onPrimaryContainer,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          minVerticalPadding: 14,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg)),
          leading: Icon(selected ? selectedIcon : icon),
          title: Text(label,
              style: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
          onTap: onTap,
        ),
      );
    }

    return Drawer(
      backgroundColor: scheme.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                24, MediaQuery.of(context).padding.top + 28, 24, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.brandDeep, AppColors.brand],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserAvatar(name: name, email: auth.email, radius: 32),
                const SizedBox(height: 14),
                Text(
                  name.isEmpty ? 'Sem nome' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleLarge?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  auth.email ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyMedium
                      ?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          item(
            icon: Icons.photo_library_outlined,
            selectedIcon: Icons.photo_library,
            label: 'Minhas coleções',
            selected: page == 'home',
            onTap: () => _go(context, '/', page == 'home'),
          ),
          item(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: 'Perfil',
            selected: page == 'profile',
            onTap: () => _go(context, '/profile', page == 'profile'),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 8, 28, 8),
            child: Divider(),
          ),
          ListenableBuilder(
            listenable: AppController.instance,
            builder: (context, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg)),
                secondary: Icon(AppController.instance.isDarkTheme
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined),
                title: const Text('Modo escuro'),
                value: AppController.instance.isDarkTheme,
                onChanged: (_) => AppController.instance.changeTheme(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 28),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg)),
              leading: Icon(Icons.logout, color: scheme.error),
              title: Text('Sair', style: TextStyle(color: scheme.error)),
              onTap: () => _logOut(context),
            ),
          ),
        ],
      ),
    );
  }
}
