import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Importación de Firebase Auth

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Row(
        children: [
          // LADO IZQUIERDO (mensaje)
          if (screenWidth > 600)
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFF6B6B),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.rocket_launch, size: 100, color: Colors.white),
                        SizedBox(height: 20),
                        Text(
                          'Sé parte de nuestro equipo increíble\ny diviértete con nosotros',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // LADO DERECHO (formulario de inicio de sesión)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              decoration: const BoxDecoration(
                color: Color(0xFF0D1B2A),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Este lo dejé igual (nombre completo)
                      _buildTextField(Icons.person, 'Nombre completo'),
                      const SizedBox(height: 20),

                      // Campo contraseña (usa el controller)
                      _buildTextField(Icons.lock, 'Contraseña',
                          obscure: true, controller: _passwordController),
                      const SizedBox(height: 20),

                      // Campo correo (usa el controller)
                      _buildTextField(Icons.email, 'Correo electrónico',
                          controller: _emailController),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Checkbox(
                            value: true,
                            onChanged: (_) {},
                            checkColor: Colors.white,
                            activeColor: Color(0xFFFF6B6B),
                          ),
                          const Expanded(
                            child: Text(
                              'Acepto los términos y condiciones',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      if (_error != null)
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFF6B6B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('Ingresar'),
                          ),
                        ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/registro");
                        },
                        child: const Text(
                          '¿No tienes cuenta? Regístrate',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildTextField(IconData icon, String hint,
      {bool obscure = false, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Color(0xFF1B263B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      Navigator.pushReplacementNamed(context, "/home");
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? 'Error desconocido';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
