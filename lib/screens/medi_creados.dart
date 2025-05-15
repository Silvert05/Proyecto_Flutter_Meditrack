import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../src/appmenu.dart';

class MedicamentosCreados extends StatefulWidget {
  const MedicamentosCreados({super.key});

  @override
  State<MedicamentosCreados> createState() => _MedicamentosCreadosState();
}

class _MedicamentosCreadosState extends State<MedicamentosCreados> {
  final Map<String, bool> _estadoTomado = {};

  Future<void> _agregarAFavoritos(BuildContext context, String medicamentoId,
      Map<String, dynamic> medicamentoData) async {
    try {
      await FirebaseFirestore.instance.collection('favoritos').doc(medicamentoId).set({
        ...medicamentoData,
        'agregado_en': DateTime.now().toIso8601String(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medicamento añadido a favoritos'),
          backgroundColor: Colors.greenAccent,
        ),
      );
      // Reemplaza '/home' con la ruta real de tu pantalla principal
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al añadir a favoritos: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuPrincipal(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 6,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Medicamentos Creados',
          style: TextStyle(
            color: Colors.cyanAccent,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      backgroundColor: const Color(0xFF141E30),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('medicamentos')
            .orderBy('creado_en', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.cyanAccent));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No hay medicamentos registrados aún.',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }

          final meds = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: meds.length,
            itemBuilder: (context, index) {
              final doc = meds[index];
              final id = doc.id;
              final data = doc.data() as Map<String, dynamic>;
              final nombre = data['nombre'] ?? '';
              final dosis = data['dosis'] ?? '';
              final frecuencia = data['frecuencia'] ?? '';
              final notas = data['notas'] ?? '';
              final inicio = DateTime.tryParse(data['fecha_inicio'] ?? '');
              final fin = DateTime.tryParse(data['fecha_fin'] ?? '');
              final hora = data['hora'] ?? '';

              final yaPasoHora =
                  DateTime.now().isAfter(fin ?? DateTime.now());

              if (yaPasoHora) {
                final fueTomado = _estadoTomado[id] ?? false;
                final estadoFinal = fueTomado ? "Tomado" : "No Tomado";

                FirebaseFirestore.instance
                    .collection('medicamentos')
                    .doc(id)
                    .get()
                    .then((docSnapshot) async {
                  if (docSnapshot.exists) {
                    await FirebaseFirestore.instance
                        .collection('historial_medicamentos')
                        .add({
                      'nombre': nombre,
                      'dosis': dosis,
                      'frecuencia': frecuencia,
                      'notas': notas,
                      'fecha_inicio': data['fecha_inicio'],
                      'fecha_fin': data['fecha_fin'],
                      'estado': estadoFinal,
                      'registrado_en': DateTime.now().toIso8601String(),
                    });

                    await FirebaseFirestore.instance
                        .collection('medicamentos')
                        .doc(id)
                        .delete();
                  }
                });
                return const SizedBox.shrink();
              }

              return Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(18),
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
                        Text(
                          nombre,
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(Icons.medication, 'Dosis:', dosis),
                        _buildDetailRow(
                            Icons.schedule, 'Frecuencia:', frecuencia),
                        _buildDetailRow(Icons.access_time, 'Hora:', hora),
                        _buildDetailRow(
                            Icons.date_range, 'Inicio:', _formatDate(inicio)),
                        _buildDetailRow(Icons.event, 'Fin:', _formatDate(fin)),
                        if (notas.isNotEmpty)
                          _buildDetailRow(Icons.note_alt, 'Notas:', notas),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "¿Tomado?",
                              style: TextStyle(color: Colors.white),
                            ),
                            Checkbox(
                              value: _estadoTomado[id] ?? false,
                              onChanged: (valor) {
                                setState(() {
                                  _estadoTomado[id] = valor ?? false;
                                });
                              },
                              activeColor: Colors.cyanAccent,
                              checkColor: Colors.black87,
                              side: const BorderSide(color: Colors.white38),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final fueTomado = _estadoTomado[id] ?? false;
                            final estadoFinal = fueTomado
                                ? "Tomado"
                                : (yaPasoHora ? "No Tomado" : "Pendiente");

                            if (estadoFinal != "Pendiente") {
                              await FirebaseFirestore.instance
                                  .collection('historial_medicamentos')
                                  .add({
                                'nombre': nombre,
                                'dosis': dosis,
                                'frecuencia': frecuencia,
                                'notas': notas,
                                'fecha_inicio': data['fecha_inicio'],
                                'fecha_fin': data['fecha_fin'],
                                'estado': estadoFinal,
                                'registrado_en': DateTime.now().toIso8601String(),
                              });

                              await FirebaseFirestore.instance
                                  .collection('medicamentos')
                                  .doc(id)
                                  .delete();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Todavía no es tiempo de mover este medicamento.'),
                                  backgroundColor: Colors.orangeAccent,
                                ),
                              );
                            }
                          },
                          icon:
                              const Icon(Icons.history, color: Colors.white),
                          label: const Text(
                              'Mover a historial'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.star_border,
                          color: Colors.amberAccent),
                      onPressed: () =>
                          _agregarAFavoritos(context, id, data),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    Color iconColor = Colors.cyanAccent;
    if (label.contains('Hora')) {
      iconColor = Colors.orangeAccent;
    } else if (label.contains('Notas')) {
      iconColor = Colors.lightGreenAccent;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Text(
            '$label ',
            style: const TextStyle(
                color: Colors.white70, fontWeight: FontWeight.w600),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Fecha no disponible';
    return '${date.day}/${date.month}/${date.year}';
  }
}