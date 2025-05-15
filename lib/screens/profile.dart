import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../screens/login.dart';
import '../src/appmenu.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  TextEditingController nombreController = TextEditingController();
  TextEditingController correoController = TextEditingController();
  TextEditingController contrasenaController = TextEditingController();

  String? fotoUrl;
  bool isEditing = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('usuarios').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        nombreController.text = data['nombre'] ?? '';
        correoController.text = user.email ?? '';
      }
      setState(() {
        fotoUrl = user.photoURL;
        isLoading = false;
      });
    }
  }

  Future<void> _actualizarPerfil() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Cambiar nombre
      await _firestore.collection('usuarios').doc(user.uid).update({
        'nombre': nombreController.text.trim(),
      });

      // Cambiar contraseña si no está vacía
      if (contrasenaController.text.isNotEmpty) {
        await user.updatePassword(contrasenaController.text.trim());
      }

      setState(() {
        isEditing = false;
      });
    }
  }

  Future<void> _cambiarImagen() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final XFile? imagen = await _picker.pickImage(source: ImageSource.gallery);
    if (imagen == null) return;

    final ref = FirebaseStorage.instance.ref().child('fotos_perfil/${user.uid}.jpg');
    await ref.putFile(File(imagen.path));
    final nuevaUrl = await ref.getDownloadURL();

    await user.updatePhotoURL(nuevaUrl);
    await _firestore.collection('usuarios').doc(user.uid).update({
      'fotoUrl': nuevaUrl,
    });

    setState(() {
      fotoUrl = nuevaUrl;
    });
  }

  void _cerrarSesion() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141E30),
      drawer: const MenuPrincipal(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 6,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Perfil",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.cyanAccent,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: isEditing ? _cambiarImagen : null,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: fotoUrl != null
                              ? NetworkImage(fotoUrl!)
                              : const AssetImage('images/lobo.jpg') as ImageProvider,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(
                          isEditing ? Icons.save : Icons.edit,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (isEditing) {
                            _actualizarPerfil();
                          } else {
                            setState(() {
                              isEditing = true;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Nombre
                  _buildInput("Nombre", nombreController, isEditing, icon: Icons.person),
                  const SizedBox(height: 20),

                  // Correo (solo lectura)
                  _buildInput("Correo", correoController, false, icon: Icons.email),
                  const SizedBox(height: 20),

                  // Contraseña (editable)
                  _buildInput("Contraseña", contrasenaController, isEditing,
                      isPassword: true, icon: Icons.lock),
                  const SizedBox(height: 30),

                  ElevatedButton.icon(
                    onPressed: _cerrarSesion,
                    icon: const Icon(Icons.logout),
                    label: const Text("Cerrar Sesión"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller,
      bool editable, {
        bool isPassword = false,
        required IconData icon,
      }) {
    return TextField(
      controller: controller,
      enabled: editable,
      obscureText: isPassword,
      style: const TextStyle(
        fontSize: 18,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.cyanAccent),
        filled: true,
        fillColor: Colors.white10,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.cyanAccent),
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.cyanAccent,
        ),
      ),
    );
  }
}
