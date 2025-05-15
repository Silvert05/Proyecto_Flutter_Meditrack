import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../src/appmenu.dart';

class MedicationReminders extends StatelessWidget {
  const MedicationReminders({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141E30),
      drawer: const MenuPrincipal(),
      appBar: AppBar(
        elevation: 6,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF121212),
        title: const Text(
          "Recordatorios",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.cyanAccent,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('medicamentos')
            .orderBy('creado_en', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No hay medicamentos registrados.',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }

          final meds = snapshot.data!.docs;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text("Próximas Tomas",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  )),
              const SizedBox(height: 16),
              ...meds.map((doc) {
                final nombre = doc['nombre'] ?? '';
                final dosis = doc['dosis'] ?? '';
                final frecuencia = doc['frecuencia'] ?? '';
                final fechaInicioStr = doc['fecha_inicio'] ?? '';
                final fechaInicio = DateTime.tryParse(fechaInicioStr);
                final proximaToma = fechaInicio != null
                    ? '${fechaInicio.hour.toString().padLeft(2, '0')}:${fechaInicio.minute.toString().padLeft(2, '0')}'
                    : 'Hora no disponible';

                return _reminderCard(
                  nombre,
                  '$dosis - $frecuencia',
                  'Próxima: $proximaToma',
                  Icons.medication,
                  Colors.cyanAccent,
                );
              }).toList(),
              const SizedBox(height: 24),
              const Text("Consejos Rápidos",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              _quickTip("Usa alarmas para no olvidar tus medicamentos.", Icons.alarm),
              _quickTip("Lleva un registro diario.", Icons.edit_note),
              _quickTip("Consulta a tu médico si olvidas una dosis.", Icons.medical_services),
            ],
          );
        },
      ),
    );
  }

  Widget _reminderCard(
      String title, String subtitle, String time, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 2),
                Text(time,
                    style: const TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _quickTip(String tip, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Text(tip,
                style: const TextStyle(
                    color: Colors.white, fontSize: 15, letterSpacing: 0.8)),
          ),
        ],
      ),
    );
  }
}
