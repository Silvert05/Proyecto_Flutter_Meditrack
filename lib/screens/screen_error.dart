import 'package:flutter/material.dart';

class ScreenError extends StatelessWidget {
  const ScreenError({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Fondo oscuro para mantener consistencia
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono de error
                Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 80,
                ),
                const SizedBox(height: 24),
                // Texto principal
                const Text(
                  '¡Algo salió mal!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyanAccent, // Usamos el color cian para mayor visibilidad
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                // Mensaje más claro
                const Text(
                  'No pudimos encontrar la pantalla que estás buscando.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70, // Texto en tono más suave
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 32),
                // Botón de regresar al home
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, "/home");
                  },
                  icon: const Icon(Icons.home),
                  label: const Text("Ir al Inicio"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    elevation: 4, // Añadimos una pequeña sombra para resaltar el botón
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
