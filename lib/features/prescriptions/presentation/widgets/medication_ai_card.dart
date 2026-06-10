import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../data/models/prescription_ai_models.dart';
import '../providers/prescription_provider.dart';

class MedicationAICard extends ConsumerStatefulWidget {
  final MedicationAIModel med;
  final VoidCallback onEdit;

  const MedicationAICard({super.key, required this.med, required this.onEdit});

  @override
  ConsumerState<MedicationAICard> createState() => _MedicationAICardState();
}

class _MedicationAICardState extends ConsumerState<MedicationAICard> {
  bool _isUploading = false;

  Future<void> _uploadImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    
    if (pickedFile != null) {
      setState(() => _isUploading = true);
      try {
        final actions = ref.read(medicationActionsProvider);
        await actions.updateImage(widget.med.id, File(pickedFile.path));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Imagen subida correctamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: InkWell(
                  onTap: widget.onEdit,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${widget.med.nombre} ${widget.med.dosis}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(Icons.edit, color: Colors.grey, size: 24),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '1 cada ${widget.med.frecuenciaHoras} horas (${widget.med.duracionDias} días)',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _isUploading 
                ? const SizedBox(width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 3))
                : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add_a_photo, color: colorScheme.primary, size: 30),
                  ),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _showPickerOptions(context),
            icon: const Icon(Icons.photo_camera),
            label: const Text('Agregar Imagen'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 64),
              side: BorderSide(color: colorScheme.primary, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                _uploadImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(context);
                _uploadImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}
