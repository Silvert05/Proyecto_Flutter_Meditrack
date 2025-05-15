import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../src/appmenu.dart';

class MedicationRegistration extends StatefulWidget {
  @override
  _MedicationRegistrationState createState() => _MedicationRegistrationState();
}

class _MedicationRegistrationState extends State<MedicationRegistration> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _hora; // Nueva variable

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _frequencyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext ctx, bool isStart) async {
    final picked = await showDatePicker(
      context: ctx,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFEB1555),
            onPrimary: Colors.white,
            surface: Color.fromARGB(255, 51, 29, 49),
            onSurface: Colors.white,
          ),
          dialogBackgroundColor: Color(0xFF0A0E21),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickTime(BuildContext ctx) async {
    final picked = await showTimePicker(
      context: ctx,
      initialTime: _hora ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFEB1555),
            onPrimary: Colors.white,
            surface: Color.fromARGB(255, 51, 29, 49),
            onSurface: Colors.white,
          ),
          dialogBackgroundColor: Color(0xFF0A0E21),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _hora = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null || _hora == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona fecha de inicio, fin y hora')),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance.collection('medicamentos').add({
          'nombre': _nameController.text.trim(),
          'dosis': _doseController.text.trim(),
          'frecuencia': _frequencyController.text.trim(),
          'notas': _notesController.text.trim(),
          'fecha_inicio': _startDate!.toIso8601String(),
          'fecha_fin': _endDate!.toIso8601String(),
          'hora': _hora!.format(context), // guardar hora
          'creado_en': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicamento registrado exitosamente')),
        );

        _formKey.currentState!.reset();
        _nameController.clear();
        _doseController.clear();
        _frequencyController.clear();
        _notesController.clear();
        setState(() {
          _startDate = null;
          _endDate = null;
          _hora = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141E30),
      drawer: const MenuPrincipal(),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 6,
        backgroundColor: const Color(0xFF121212),
        title: const Text(
          "Registrar Medicamento",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.cyanAccent,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              color: const Color(0xFF1D1E33),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 4,
              shadowColor: Colors.black87,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(_nameController, 'Nombre del Medicamento', Icons.medication),
                      const SizedBox(height: 20),
                      _buildTextField(_doseController, 'Dosis (ej. 500mg)', Icons.medical_services),
                      const SizedBox(height: 20),
                      _buildTextField(_frequencyController, 'Frecuencia (ej. 2 veces al día)', Icons.repeat),
                      const SizedBox(height: 20),
                      _buildDatePicker(context, 'Fecha de Inicio', _startDate, Icons.date_range, () => _pickDate(context, true)),
                      const SizedBox(height: 20),
                      _buildDatePicker(context, 'Fecha de Fin', _endDate, Icons.event, () => _pickDate(context, false)),
                      const SizedBox(height: 20),
                      _buildTimePicker(context, 'Hora del Medicamento', _hora, Icons.access_time, () => _pickTime(context)),
                      const SizedBox(height: 20),
                      _buildTextField(_notesController, 'Notas adicionales', Icons.note_alt, maxLines: 3),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.save, size: 20),
                        label: const Text('Guardar Medicamento'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 1, 132, 150),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Color(0xFF00BCD4)),
        filled: true,
        fillColor: Color(0xFF1F2A40),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF00ACC1), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
    );
  }

  Widget _buildDatePicker(BuildContext context, String label, DateTime? date, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Color(0xFF00BCD4)),
          filled: true,
          fillColor: Color(0xFF1F2A40),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white24),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF00ACC1), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          date != null ? "${date.day}/${date.month}/${date.year}" : 'Selecciona fecha',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context, String label, TimeOfDay? time, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Color(0xFF00BCD4)),
          filled: true,
          fillColor: Color(0xFF1F2A40),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white24),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF00ACC1), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          time != null ? time.format(context) : 'Selecciona hora',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
