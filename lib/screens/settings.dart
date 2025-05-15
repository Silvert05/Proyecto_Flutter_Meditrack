import 'package:flutter/material.dart';
import '../src/appmenu.dart'; // Asegúrate de que esta ruta sea correcta
import 'package:firebase_auth/firebase_auth.dart'; // Importa Firebase Auth

// Creamos un widget simple para simular la pantalla de error
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Puedes usar el mismo fondo oscuro o uno diferente
      backgroundColor: const Color(0xFF141E30),
      appBar: AppBar(
        title: const Text("Error"),
         iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF121212),
         titleTextStyle: const TextStyle( // Estilo para el título del AppBar en la pantalla de error
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent, // Color de acento rojo para error
            letterSpacing: 1.5,
          ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline, // Icono de error
                size: 120,
                color: Colors.redAccent, // Color de acento rojo para el icono
              ),
              const SizedBox(height: 24),
              const Text(
                '¡Algo salió mal!', // Mensaje principal de error
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                 textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Esta es una pantalla de error simulada.', // Descripción
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
                 textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, // Color del botón
                   foregroundColor: Colors.white,
                   padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                   textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  // Al presionar, regresar a la pantalla anterior (Configuración)
                  Navigator.pop(context);
                },
                child: const Text('Regresar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// Convertimos a StatefulWidget para poder usar AnimationController
class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

// Agregamos SingleTickerProviderStateMixin para el AnimationController
class _SettingsState extends State<Settings> with SingleTickerProviderStateMixin {
  // Controlador para la animación
  late AnimationController _controller;
  // Animaciones para el desvanecimiento y el deslizamiento
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Helper method para construir secciones (lo mantenemos)
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

  // Helper method para construir elementos de lista (lo mantenemos)
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
  void initState() {
    super.initState();
    // Inicializar el AnimationController
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800), // Duración total de la animación
      vsync: this, // Sincronizar con el ciclo de vida del widget
    );

    // Definir la animación de desvanecimiento (curva de entrada suave)
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Definir la animación de deslizamiento (inicia ligeramente abajo y se mueve a la posición final)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1), // Empieza 10% más abajo
      end: Offset.zero,            // Termina en su posición original
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut, // Curva de salida suave
    ));

    // Iniciar la animación
    _controller.forward();
  }

  @override
  void dispose() {
    // Desechar el controlador cuando el widget ya no sea necesario
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // Obtener el usuario actualmente logueado usando Firebase Auth
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF141E30), // Fondo oscuro
      drawer: const MenuPrincipal(), // Menú lateral
      appBar: AppBar(
        elevation: 6,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF121212), // Color de AppBar oscuro
        title: const Text(
          "Configuración", // Título de la pantalla
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.cyanAccent, // Color de acento para el título
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Envolvemos los elementos principales con las animaciones
            // Aplicamos FadeTransition y SlideTransition a los bloques principales

            // Bloque del Icono y Títulos
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column( // Usamos una columna aquí para agruparlos y aplicar la animación
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

            // Sección Cuenta - Aplicamos animaciones a la SectionCard
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildSectionCard(
                  title: 'Cuenta',
                  children: [
                    if (currentUser != null) // Mostramos email si logueado
                      _buildListTile(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        trailing: Text(
                          currentUser.email ?? 'Correo no disponible',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        onTap: () {
                          print('Email del usuario: ${currentUser.email}');
                          // Puedes añadir funcionalidad aquí, ej. copiar al portapapeles
                        },
                      ),
                    _buildListTile(
                      icon: Icons.person_outline,
                      title: 'Perfil',
                      onTap: () {
                        // Navega a la pantalla de perfil. Asegúrate de que la ruta "/profile" esté definida en tu MaterialApp.
                        Navigator.pushNamed(context, "/profile");
                      },
                    ),
                    _buildListTile(
                      icon: Icons.lock_outline,
                      title: 'Privacidad',
                      onTap: () {
                        // TODO: Acción de privacidad
                        print('Acción de privacidad pendiente...');
                      },
                    ),
                    if (currentUser != null) // Mostramos cerrar sesión si logueado
                      _buildListTile(
                        icon: Icons.logout,
                        title: 'Cerrar Sesión',
                        onTap: () async {
                          try {
                            await FirebaseAuth.instance.signOut();
                            print('Sesión cerrada exitosamente.');
                            // Navegar a la pantalla de inicio/login y limpiar la pila
                            Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login', // Reemplaza con tu ruta de login/inicio
                                (route) => false
                              );
                          } catch (e) {
                            print('Error al cerrar sesión: ${e.toString()}');
                             ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al cerrar sesión: ${e.toString()}'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

             // Sección Información - Aplicamos animaciones
             SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildSectionCard(
                  title: 'Información',
                  children: [
                    _buildListTile(
                      icon: Icons.info_outline,
                      title: 'Sobre la App',
                      onTap: () {
                        // *** Aquí navegamos a la pantalla de error simulada ***
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ErrorScreen()),
                        );
                         print('Navegando a pantalla de error simulada...');
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

   // Los helper methods _buildSectionCard y _buildListTile están definidos arriba.
}