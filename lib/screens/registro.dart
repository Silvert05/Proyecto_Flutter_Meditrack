import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  _RegistroState createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isPasswordValid = true;

  Future<void> _register() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _nameController.text.isEmpty) {
      _showError("Por favor, completa todos los campos.");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _isPasswordValid = false;
      });
      return;
    }

    try {
      print("Intentando registrar usuario...");
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      print("Usuario creado correctamente. UID: ${userCredential.user!.uid}");

      await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
        'nombre': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'uid': userCredential.user!.uid,
        'fechaRegistro': FieldValue.serverTimestamp(),
      });

      print("Datos guardados en Firestore");

      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _nameController.clear();

      await _auth.signOut();

      Navigator.pop(context); // Vuelve al Login
    } on FirebaseAuthException catch (e) {
      print("Error de FirebaseAuth: $e");
      _showError(e.message ?? "Ha ocurrido un error");
    } catch (e) {
      print("Error inesperado: $e");
      _showError("Error inesperado: $e");
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Row(
        children: [
          if (screenWidth > 600)
            Expanded(
              child: Container(
                color: const Color(0xFFFF6B6B),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_add, size: 100, color: Colors.white),
                        SizedBox(height: 20),
                        Text(
                          'Únete a nuestra comunidad\ny crea tu cuenta',
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
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              decoration: const BoxDecoration(color: Color(0xFF0D1B2A)),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        'Crear Cuenta',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildTextField(Icons.person, 'Nombre completo', controller: _nameController),
                      const SizedBox(height: 20),
                      _buildTextField(Icons.email, 'Correo electrónico', controller: _emailController),
                      const SizedBox(height: 20),
                      _buildTextField(Icons.lock, 'Contraseña', obscure: true, controller: _passwordController),
                      const SizedBox(height: 20),
                      _buildTextField(Icons.lock_outline, 'Confirmar contraseña', obscure: true, controller: _confirmPasswordController),
                      if (!_isPasswordValid)
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            'Las contraseñas no coinciden',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 30),
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
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B6B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Registrarse'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          '¿Ya tienes una cuenta? Inicia sesión',
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

  static Widget _buildTextField(IconData icon, String hint, {bool obscure = false, TextEditingController? controller}) {
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
}
