import 'package:flutter/material.dart';
import '../src/appmenu.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const Divider(color: Colors.white30),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.cyanAccent),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: trailing != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                trailing,
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
              ],
            )
          : const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF141E30),
      drawer: const MenuPrincipal(),
      appBar: AppBar(
        elevation: 6,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF121212),
        title: const Text(
          "Configuración",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.cyanAccent,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const Center(
                      child: Icon(Icons.settings, size: 100, color: Colors.cyanAccent),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Configuraciones',
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Gestiona tu cuenta y preferencias básicas.',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildSectionCard(
                  title: 'Cuenta',
                  children: [
                    if (currentUser != null)
                      _buildListTile(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        trailing: Text(
                          currentUser.email ?? 'Correo no disponible',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        onTap: () {},
                      ),
                    _buildListTile(
                      icon: Icons.person_outline,
                      title: 'Perfil',
                      onTap: () {
                        Navigator.pushNamed(context, "/profile");
                      },
                    ),
                    _buildListTile(
                      icon: Icons.lock_outline,
                      title: 'Privacidad',
                      onTap: () {
                        // Ir a la pantalla de error
                        Navigator.pushNamed(context, '/error');
                      },
                    ),
                    if (currentUser != null)
                      _buildListTile(
                        icon: Icons.logout,
                        title: 'Cerrar Sesión',
                        onTap: () async {
                          try {
                            await FirebaseAuth.instance.signOut();
                            print('Sesión cerrada exitosamente.');
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/',
                              (route) => false,
                            );
                          } catch (e) {
                            print('Error al cerrar sesión: ${e.toString()}');
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
