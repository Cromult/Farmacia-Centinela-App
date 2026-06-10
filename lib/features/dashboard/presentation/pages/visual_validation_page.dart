import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/dashboard_model.dart';
import '../providers/dashboard_provider.dart';

class VisualValidationPage extends ConsumerStatefulWidget {
  final MedicationModel medication;

  const VisualValidationPage({super.key, required this.medication});

  @override
  ConsumerState<VisualValidationPage> createState() => _VisualValidationPageState();
}

class _VisualValidationPageState extends ConsumerState<VisualValidationPage> {
  File? _image;
  bool _isValidating = false;

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _validateAndSubmit() async {
    if (_image == null) return;

    setState(() => _isValidating = true);

    try {
      final result = await ref.read(markAsTakenProvider((
        medication: widget.medication,
        image: _image!,
      )).future);

      if (mounted) {
        _showSuccessDialog(result);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isValidating = false);
    }
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    final String mensaje = result['mensaje'] ?? 'La medicina es la correcta. Se ha registrado su toma.';
    final String? base64String = result['verificacion_ia']?['imagen_recortada_base64'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 80),
        title: const Text('¡Verificación Exitosa!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mensaje, textAlign: TextAlign.center),
            if (base64String != null) ...[
              const SizedBox(height: 20),
              const Text('Captura de la IA:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  base64Decode(base64String),
                  width: 250, // Incrementado para mejor visibilidad
                  height: 250, // Incrementado para mejor visibilidad
                  fit: BoxFit.contain, // Cambiado a contain para ver la pastilla completa sin recortes
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, size: 80, color: Colors.grey);
                  },
                ),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Volver al dashboard
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 80),
        title: const Text('¡Atención!'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación Visual'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Por favor, tome una foto clara de la pastilla que va a tomar.',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),
            
            // Caja de enfoque simulada
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _image == null ? colorScheme.primary : Colors.green,
                      width: 4,
                    ),
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_enhance, size: 64, color: colorScheme.primary),
                            const SizedBox(height: 16),
                            const Text('Enfoque la medicina aquí'),
                          ],
                        ),
                ),
                if (_image == null)
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            if (_isValidating)
              const Column(
                children: [
                  CircularProgressIndicator.adaptive(),
                  SizedBox(height: 16),
                  Text('Validando con IA...', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              )
            else ...[
              ElevatedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.photo_camera),
                label: Text(_image == null ? 'Tomar Foto' : 'Cambiar Foto'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 64),
                ),
              ),
              const SizedBox(height: 16),
              if (_image != null)
                ElevatedButton.icon(
                  onPressed: _validateAndSubmit,
                  icon: const Icon(Icons.verified),
                  label: const Text('Subir y Verificar'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 64),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
