import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../src/appmenu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el ancho de la pantalla
    final double screenWidth = MediaQuery.of(context).size.width;
    // Definimos un punto de quiebre. 600 es un valor común.
    final double breakpoint = 600.0;

    // Decidimos si la TabBar debe ser scrollable basado en el ancho de la pantalla
    final bool isScrollable = screenWidth < breakpoint;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(0xFF141E30),
        drawer: const MenuPrincipal(),
        appBar: AppBar(
          elevation: 6,
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: const Color(0xFF121212),
          title: const Text(
            "MediTrack",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.cyanAccent,
              letterSpacing: 1.5,
            ),
          ),
          bottom: TabBar(
            // Quitamos const aquí
            isScrollable: isScrollable, // Usamos la variable booleana
            indicatorColor: Colors.cyanAccent,
            labelColor: Colors.cyanAccent,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              // Mantenemos const aquí
              Tab(icon: Icon(Icons.dashboard), text: "Resumen"),
              Tab(icon: Icon(Icons.medication), text: "Medicamentos"),
              Tab(icon: Icon(Icons.star), text: "Favoritos"),
              Tab(icon: Icon(Icons.tips_and_updates), text: "Consejos"),
              Tab(icon: Icon(Icons.spoke_outlined), text: "Soporte"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ResumenTab(),
            MedicamentosTab(),
            FavoritosTab(),
            ConsejosTab(),
            SoporteTab(),
          ],
        ),
      ),
    );
  }
}

// PESTAÑA 1: RESUMEN
class ResumenTab extends StatefulWidget {
  const ResumenTab({super.key});

  @override
  State<ResumenTab> createState() => _ResumenTabState();
}

class _ResumenTabState extends State<ResumenTab> {
  int _activeMedications = 0;
  int _pendingDosesToday = 0;
  int _totalDosesTaken = 0;
  List<double> _adherenceData = [];
  List<FlSpot> _activityData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSummaryData();
  }

  Future<void> _loadSummaryData() async {
    try {
      final medicationsSnapshot =
          await FirebaseFirestore.instance.collection('medicamentos').get();
      final dosesSnapshot =
          await FirebaseFirestore.instance.collection('doses').get();
      final historySnapshot =
          await FirebaseFirestore.instance
              .collection('historial_medicamentos')
              .get();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      final sevenDaysAgo = today.subtract(const Duration(days: 6));

      setState(() {
        _activeMedications = medicationsSnapshot.docs.length;
        _pendingDosesToday =
            dosesSnapshot.docs
                .where(
                  (doc) =>
                      (doc.data()['proximaToma'] as Timestamp?)
                              ?.toDate()
                              .isAtSameMomentAs(today) ==
                          true ||
                      ((doc.data()['proximaToma'] as Timestamp?)
                                      ?.toDate()
                                      .isAfter(today) ==
                                  true &&
                              (doc.data()['proximaToma'] as Timestamp?)
                                      ?.toDate()
                                      .isBefore(tomorrow) ==
                                  true) &&
                          doc.data()['tomado'] == false,
                )
                .length;
        _totalDosesTaken =
            historySnapshot.docs
                .where((doc) => doc.data()['estado'] == 'Tomado')
                .length;

        // Calcular adherencia para los últimos 7 días
        _adherenceData = List.generate(7, (index) {
          final dayToCheck = sevenDaysAgo.add(Duration(days: index));
          final endOfDay = dayToCheck.add(
            const Duration(hours: 23, minutes: 59, seconds: 59),
          );
          final totalExpectedToday =
              dosesSnapshot.docs
                  .where(
                    (doc) =>
                        (doc.data()['proximaToma'] as Timestamp?)
                                ?.toDate()
                                .isAfter(
                                  dayToCheck.subtract(
                                    const Duration(milliseconds: 1),
                                  ),
                                ) ==
                            true &&
                        (doc.data()['proximaToma'] as Timestamp?)
                                ?.toDate()
                                .isBefore(
                                  endOfDay.add(const Duration(milliseconds: 1)),
                                ) ==
                            true,
                  )
                  .length;
          final takenToday =
              historySnapshot.docs.where((doc) {
                final registradoEn = doc.data()['registrado_en'];
                if (registradoEn != null) {
                  DateTime? dateTaken;
                  if (registradoEn is String) {
                    try {
                      dateTaken = DateTime.parse(registradoEn);
                    } catch (e) {
                      print("Error parsing date string: $e");
                      return false;
                    }
                  } else if (registradoEn is Timestamp) {
                    dateTaken = registradoEn.toDate();
                  }
                  return doc.data()['estado'] == 'Tomado' &&
                      dateTaken != null &&
                      dateTaken.isAfter(
                        dayToCheck.subtract(const Duration(milliseconds: 1)),
                      ) &&
                      dateTaken.isBefore(
                        endOfDay.add(const Duration(milliseconds: 1)),
                      );
                }
                return false;
              }).length;
          return totalExpectedToday > 0
              ? (takenToday / totalExpectedToday * 100).clamp(0, 100)
              : 0;
        });

        // Datos de actividad (tomas realizadas por día) para los últimos 7 días
        _activityData = List.generate(7, (index) {
          final dayToCheck = sevenDaysAgo.add(Duration(days: index));
          final endOfDay = dayToCheck.add(
            const Duration(hours: 23, minutes: 59, seconds: 59),
          );
          final takenOnDay =
              historySnapshot.docs.where((doc) {
                final registradoEn = doc.data()['registrado_en'];
                if (registradoEn != null) {
                  DateTime? dateTaken;
                  if (registradoEn is String) {
                    try {
                      dateTaken = DateTime.parse(registradoEn);
                    } catch (e) {
                      print("Error parsing date string for activity: $e");
                      return false;
                    }
                  } else if (registradoEn is Timestamp) {
                    dateTaken = registradoEn.toDate();
                  }
                  return doc.data()['estado'] == 'Tomado' &&
                      dateTaken != null &&
                      dateTaken.isAfter(
                        dayToCheck.subtract(const Duration(milliseconds: 1)),
                      ) &&
                      dateTaken.isBefore(
                        endOfDay.add(const Duration(milliseconds: 1)),
                      );
                }
                return false;
              }).length;
          return FlSpot(index.toDouble(), takenOnDay.toDouble());
        });
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading summary data: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error al cargar la información del resumen. Por favor, intenta de nuevo.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
          child: CircularProgressIndicator(color: Colors.cyanAccent),
        )
        : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Resumen de Salud",
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            _infoCard(
              "Medicamentos Activos",
              "$_activeMedications",
              Icons.medication,
              Colors.cyanAccent,
            ),
            _infoCard(
              "Historial",
              "$_totalDosesTaken tomados",
              Icons.history,
              Colors.lightGreenAccent,
            ),
            const SizedBox(height: 24),
            const Text(
              "Sugerencias",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _horizontalSuggestion(
              "Hidratación",
              Icons.water_drop,
              Colors.cyanAccent,
            ),
            _horizontalSuggestion(
              "Ejercicio",
              Icons.fitness_center,
              Colors.deepOrangeAccent,
            ),
            _horizontalSuggestion("Sueño", Icons.bed, Colors.deepPurpleAccent),
            const SizedBox(height: 24),
            const Text(
              "Actividad Semanal (Tomas Realizadas)",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            _activityChart(_activityData),
          ],
        );
  }

  static Widget _infoCard(
    String title,
    String data,
    IconData icon,
    Color color,
  ) {
    return Container(
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _horizontalSuggestion(String text, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _adherenceChart(List<double> data) {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final now = DateTime.now();
                  final sevenDaysAgo = now.subtract(const Duration(days: 6));
                  final dayToCheck = sevenDaysAgo.add(
                    Duration(days: value.toInt()),
                  );
                  return Text(
                    DateFormat('E').format(
                      dayToCheck,
                    ), // Muestra la abreviatura del día (Lun, Mar, etc.)
                    style: const TextStyle(color: Colors.white70),
                  );
                },
                interval: 1,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i].toDouble(),
                  color: Colors.cyanAccent,
                  width: 14,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _activityChart(List<FlSpot> data) {
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value % 1 == 0) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final now = DateTime.now();
                  final sevenDaysAgo = now.subtract(const Duration(days: 6));
                  final dayToCheck = sevenDaysAgo.add(
                    Duration(days: value.toInt()),
                  );
                  return Text(
                    DateFormat('E').format(
                      dayToCheck,
                    ), // Muestra la abreviatura del día (Lun, Mar, etc.)
                    style: const TextStyle(color: Colors.white70),
                  );
                },
                interval: 1,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data,
              isCurved: true,
              color: Colors.cyanAccent,
              barWidth: 4,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.cyanAccent.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// PESTAÑA 2: MEDICAMENTOS
class MedicamentosTab extends StatefulWidget {
  const MedicamentosTab({super.key});

  @override
  State<MedicamentosTab> createState() => _MedicamentosTabState();
}

class _MedicamentosTabState extends State<MedicamentosTab> {
  late Stream<QuerySnapshot> _medicamentosStream;

  @override
  void initState() {
    super.initState();
    _medicamentosStream =
        FirebaseFirestore.instance.collection('medicamentos').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _medicamentosStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Algo salió mal',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.cyanAccent),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No hay medicamentos registrados.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children:
              snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                return Card(
                  color: Colors.white.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 14),
                  child: ListTile(
                    leading: const Icon(
                      Icons.medication,
                      color: Colors.cyanAccent,
                    ),
                    title: Text(
                      data['nombre'] ?? 'Nombre no disponible',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Hora: ${data['horaToma'] ?? 'Hora no disponible'}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.greenAccent,
                    ),
                    // onTap: () {
                    // Aquí puedes agregar la lógica para marcar como tomado
                    // },
                  ),
                );
              }).toList(),
        );
      },
    );
  }
}

// PESTAÑA 3: FAVORITOS
class FavoritosTab extends StatelessWidget {
  const FavoritosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('favoritos').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Algo salió mal al cargar los favoritos',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.cyanAccent),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No tienes medicamentos en favoritos.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children:
              snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.star, color: Colors.amber),
                    title: Text(
                      data['nombre'] ?? 'Nombre no disponible',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Dosis: ${data['dosis'] ?? 'No especificada'}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () async {
                        try {
                          await FirebaseFirestore.instance
                              .collection('favoritos')
                              .doc(document.id)
                              .delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Medicamento eliminado de favoritos',
                              ),
                              backgroundColor: Colors.orangeAccent,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error al eliminar de favoritos: $e',
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                    ),
                    onTap: () {
                      // Aquí puedes agregar la lógica para ver los detalles del favorito si lo deseas
                      print('Ver detalles de ${data['nombre']}');
                    },
                  ),
                );
              }).toList(),
        );
      },
    );
  }
}

// PESTAÑA 4: CONSEJOS
class ConsejosTab extends StatelessWidget {
  const ConsejosTab({super.key});

  @override
  Widget build(BuildContext context) {
    final consejos = [
      {
        'titulo': 'Bebe agua frecuentemente',
        'icono': Icons.water_drop,
        'descripcion': 'Mantenerte hidratado es crucial para tu salud general.',
      },
      {
        'titulo': 'Evita el alcohol con medicamentos',
        'icono': Icons.no_drinks,
        'descripcion':
            'El alcohol puede interferir con los efectos de muchos medicamentos.',
      },
      {
        'titulo': 'No tomes medicinas sin receta',
        'icono': Icons.warning_amber,
        'descripcion':
            'Siempre consulta a un profesional antes de tomar medicinas.',
      },
      {
        'titulo': 'Descansa adecuadamente',
        'icono': Icons.bed,
        'descripcion':
            'El descanso es esencial para la recuperación y bienestar.',
      },
      {
        'titulo': 'Mantén una dieta equilibrada',
        'icono': Icons.food_bank,
        'descripcion':
            'Una buena nutrición es clave para mantenerte saludable.',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children:
          consejos
              .map(
                (c) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                    color: Colors.white.withOpacity(0.04),
                  ),
                  child: Row(
                    children: [
                      Icon(c['icono'] as IconData, color: Colors.cyanAccent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c['titulo'] as String,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              c['descripcion'] as String,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }
}

class SoporteTab extends StatefulWidget {
  const SoporteTab({super.key});

  @override
  _SoporteTabState createState() => _SoporteTabState();
}

class _SoporteTabState extends State<SoporteTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward(); // Start the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'pregunta': '¿Cómo restablecer mi contraseña?',
        'respuesta':
            'Puedes restablecerla desde la sección de "Configuración" en la app.',
      },
      {
        'pregunta': '¿Cómo eliminar mi cuenta?',
        'respuesta':
            'Para eliminar tu cuenta, por favor contacta al soporte a través del correo electrónico.',
      },
      {
        'pregunta': '¿Cómo agregar un medicamento?',
        'respuesta':
            'Puedes agregar un medicamento desde la pantalla principal de "Medicamentos".',
      },
    ];

    return SingleChildScrollView(
      // Agrega SingleChildScrollView para que todo el contenido sea desplazable
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FadeTransition(
                opacity: _opacityAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: const Icon(
                    Icons.support_agent,
                    size: 80,
                    color: Colors.cyanAccent,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeTransition(
                opacity: _opacityAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: const Text(
                    "¿Necesitas ayuda?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeTransition(
                opacity: _opacityAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: const Text(
                    "Escríbenos a soporte@meditrack.com o llama al 1800-MED-HELP.",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeTransition(
                opacity: _opacityAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: const Text(
                    "Preguntas Frecuentes:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeTransition(
                opacity: _opacityAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        faqs.map((faq) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white30),
                              color: Colors.white.withOpacity(0.1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  faq['pregunta']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  faq['respuesta']!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeTransition(
                opacity: _opacityAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ElevatedButton(
                    onPressed: () {
                      // Acción para enviar un correo o abrir un formulario de contacto
                      print("Contactar Soporte");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 30,
                      ),
                    ),
                    child: const Text(
                      "Contactar Soporte",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
