import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../src/appmenu.dart';

class MedicationHistory extends StatelessWidget {
  const MedicationHistory({super.key});

  Future<void> _eliminarDelHistorial(
      BuildContext context, String documentoId) async {
    try {
      await FirebaseFirestore.instance
          .collection('historial_medicamentos')
          .doc(documentoId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Elemento eliminado del historial'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar del historial: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

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
          "Historial",
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
            .collection('historial_medicamentos')
            .orderBy('registrado_en', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.cyanAccent));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Aún no hay historial de medicamentos.',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }

          final historial = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: historial.length,
            itemBuilder: (context, index) {
              final documento = historial[index];
              final item = documento.data() as Map<String, dynamic>;
              final bool tomado = item['estado'] == 'Tomado';

              return Container(
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['nombre'] ?? '',
                              style: const TextStyle(
                                  color: Colors.cyanAccent,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildDetail("Dosis", item['dosis'] ?? ''),
                              _buildDetail("Frecuencia", item['frecuencia'] ?? ''),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildDetail(
                                  "Inicio", _formatDate(item['fecha_inicio'])),
                              _buildDetail("Fin", _formatDate(item['fecha_fin'])),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                tomado
                                    ? Icons.check_circle_outline
                                    : Icons.cancel_outlined,
                                color: tomado
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item['estado'] ?? '',
                                style: TextStyle(
                                  color: tomado
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.delete_forever,
                          color: Colors.redAccent),
                      onPressed: () =>
                          _eliminarDelHistorial(context, documento.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ],
    );
  }

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'N/D';
    try {
      final date = DateTime.parse(isoString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/D';
    }
  }
}