import 'package:flutter/material.dart';

// 🔹 Importaciones de tus pantallas
import 'package:rutasuno/screens/home.dart';
import 'package:rutasuno/screens/login.dart';
import 'package:rutasuno/screens/profile.dart';
import 'package:rutasuno/screens/screen_error.dart';
import 'package:rutasuno/screens/settings.dart';
import 'package:rutasuno/screens/registro.dart';
import 'package:rutasuno/screens/medication_registration.dart';
import 'package:rutasuno/screens/medication_history.dart';
import 'package:rutasuno/screens/medication_reminders.dart';
import 'package:rutasuno/screens/medi_creados.dart';

// 🔹 Importaciones necesarias para Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // 🔸 Asegura que los widgets estén inicializados antes de Firebase
  WidgetsFlutterBinding.ensureInitialized();
try {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Firebase inicializado correctamente');
} catch (e) {
  print('Error al inicializar Firebase: $e');
}

  // 🔸 Inicializa Firebase usando las opciones generadas automáticamente
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔸 Corre tu app normalmente con todas tus rutas
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rutas',
      initialRoute: "/",
      routes: {
        "/": (context) => const Login(),
        "/registro": (context) => const Registro(),
        "/home": (context) => const Home(),
        "/profile": (context) => const Profile(),
        "/settings": (context) => const Settings(),
        "/screen_error": (context) => const ScreenError(),
        "/medication_registration": (context) => MedicationRegistration(),
        "/medication_history": (context) => MedicationHistory(),
        "/medication_reminders": (context) => MedicationReminders(),
        "/medi_creados": (context) => MedicamentosCreados(),

      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const ScreenError());
      },
    );
  }
}
