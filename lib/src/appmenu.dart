import 'package:flutter/material.dart';

class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 0, 0, 0), // Azul oscuro
              Color.fromARGB(255, 1, 19, 26), // Intermedio
              Color.fromARGB(255, 17, 49, 63), // Azul grisáceo suave
            ],
          ),
        ),
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/fondo3.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('images/lobo.jpg'),
                    backgroundColor: Colors.transparent,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'David Cocha',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'edu.cocha@yavirac.edu.ec',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Menú
            _buildMenuItem(
              icon: Icons.home,
              label: 'Inicio',
              context: context,
              route: '/home',
            ),
            _buildMenuItem(
              icon: Icons.person,
              label: 'Perfil',
              context: context,
              route: '/profile',
            ),
            _buildMenuItem(
              icon: Icons.settings,
              label: 'Configuración',
              context: context,
              route: '/settings',
            ),
            _buildMenuItem(
              icon: Icons.rectangle_outlined,
              label: 'Registro',
              context: context,
              route: '/medication_registration',
            ),
            _buildMenuItem(
              icon: Icons.history,
              label: 'Historial',
              context: context,
              route: '/medication_history',
            ),
            _buildMenuItem(
              icon: Icons.recommend,
              label: 'Recordatorios',
              context: context,
              route: '/medication_reminders',
            ),
              _buildMenuItem(
              icon: Icons.create,
              label: 'Creados',
              context: context,
              route: '/medi_creados',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required BuildContext context,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.cyanAccent),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pushReplacementNamed(context, route);
      },
    );
  }
}
