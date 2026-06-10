import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/providers/network_providers.dart';
import '../../data/models/medication_detail_model.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../providers/prescription_provider.dart';

class EditMedicationPage extends ConsumerStatefulWidget {
  final String medicationId;

  const EditMedicationPage({super.key, required this.medicationId});

  @override
  ConsumerState<EditMedicationPage> createState() => _EditMedicationPageState();
}

class _EditMedicationPageState extends ConsumerState<EditMedicationPage> {
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  int _frequency = 8;
  String _route = 'Oral';
  
  List<File> _newFiles = [];
  List<MedicationDocModel> _existingDocs = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _prescriptionId;

  @override
  void initState() {
    super.initState();
    _loadMedication();
  }

  Future<void> _loadMedication() async {
    try {
      final actions = ref.read(medicationActionsProvider);
      final med = await actions.getDetail(widget.medicationId);
      
      setState(() {
        _nameCtrl.text = med.nombre;
        _dosageCtrl.text = med.dosis;
        _descriptionCtrl.text = med.descripcion;
        _quantityCtrl.text = med.cantidad.toString();
        _durationCtrl.text = med.duracionDias.toString();
        _frequency = med.frecuenciaHoras;
        _route = med.viaAdministracion;
        _existingDocs = List.from(med.medicationsDocs);
        _prescriptionId = med.prescriptionId;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _descriptionCtrl.dispose();
    _quantityCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    
    if (pickedFile != null) {
      setState(() {
        _newFiles.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final dataSource = ref.read(medicationDataSourceProvider);
      await dataSource.updateMedication(
        id: widget.medicationId,
        nombre: _nameCtrl.text,
        dosis: _dosageCtrl.text,
        descripcion: _descriptionCtrl.text,
        frecuenciaHoras: _frequency,
        cantidad: int.tryParse(_quantityCtrl.text),
        duracionDias: int.tryParse(_durationCtrl.text),
        viaAdministracion: _route,
        keepDocIds: _existingDocs.map((e) => e.id).toList(),
        files: _newFiles,
      );
      
      ref.invalidate(dashboardFutureProvider);
      ref.invalidate(medicationsByPrescriptionProvider(_prescriptionId ?? ''));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicamento guardado correctamente')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator.adaptive()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Editar Medicamento', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('PillTrack', style: theme.textTheme.titleLarge?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w900))),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (_prescriptionId != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                  border: Border(left: BorderSide(color: colorScheme.primary, width: 8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID de Receta', style: theme.textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
                    Text(_prescriptionId!, style: theme.textTheme.headlineMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            
            _buildField(
              label: 'Nombre del Medicamento',
              icon: Icons.medication,
              child: TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  hintText: 'Ej: Paracetamol',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            
            _buildField(
              label: 'Dosis',
              icon: Icons.monitor_weight,
              child: TextField(
                controller: _dosageCtrl,
                decoration: InputDecoration(
                  hintText: 'Ej: 500mg',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            
            _buildField(
              label: 'Descripción / Instrucciones',
              icon: Icons.description,
              child: TextField(
                controller: _descriptionCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Ej: Tomar después de las comidas...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    label: 'Frecuencia (Horas)',
                    icon: Icons.schedule,
                    child: Row(
                      children: [
                        _counterBtn(Icons.remove, () => setState(() { if (_frequency > 1) _frequency--; })),
                        Expanded(child: Text(_frequency.toString(), textAlign: TextAlign.center, style: theme.textTheme.headlineMedium)),
                        _counterBtn(Icons.add, () => setState(() => _frequency++)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildField(
                    label: 'Vía de Administración',
                    icon: Icons.vaccines,
                    child: DropdownButtonFormField<String>(
                      value: _route,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      items: ['Oral', 'Tópica', 'Inyectable', 'Oftálmica'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setState(() => _route = val!),
                    ),
                  ),
                ),
              ],
            ),
            
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outlineVariant, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cantidad', style: theme.textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(child: TextField(controller: _quantityCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(border: InputBorder.none), style: theme.textTheme.displaySmall?.copyWith(color: colorScheme.primary))),
                            Text('Pastillas', style: theme.textTheme.labelLarge?.copyWith(color: colorScheme.outline)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outlineVariant, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Duración', style: theme.textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(child: TextField(controller: _durationCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(border: InputBorder.none), style: theme.textTheme.displaySmall?.copyWith(color: colorScheme.primary))),
                            Text('Días', style: theme.textTheme.labelLarge?.copyWith(color: colorScheme.outline)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildField(
              label: 'Archivos o Fotos de la Caja',
              icon: Icons.photo_camera,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _showPickerOptions(),
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.outlineVariant, width: 4, style: BorderStyle.solid),
                        color: Colors.grey.shade100,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: colorScheme.primaryContainer, shape: BoxShape.circle),
                            child: Icon(Icons.upload_file, size: 48, color: colorScheme.primary),
                          ),
                          const SizedBox(height: 12),
                          Text('Subir Foto o Archivo', style: theme.textTheme.headlineSmall?.copyWith(color: colorScheme.primary)),
                          Text('Formatos: JPG, PNG', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.outline)),
                        ],
                      ),
                    ),
                  ),
                  if (_existingDocs.isNotEmpty || _newFiles.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            ..._existingDocs.map((doc) => _imagePreview(doc.mediaUrl, () => setState(() => _existingDocs.remove(doc)))),
                            ..._newFiles.map((file) => _imagePreview(file, () => setState(() => _newFiles.remove(file)), isFile: true)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            _isSaving 
              ? const CircularProgressIndicator.adaptive()
              : ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save, size: 36),
                  label: const Text('Guardar Medicamento'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 80),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    textStyle: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildField({required String label, IconData? icon, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) Icon(icon, color: Theme.of(context).colorScheme.primary),
              if (icon != null) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge,
                  softWrap: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _counterBtn(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(12)),
      child: IconButton(icon: Icon(icon, color: Colors.white, size: 32), onPressed: onPressed),
    );
  }

  Widget _imagePreview(dynamic source, VoidCallback onRemove, {bool isFile = false}) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: isFile ? FileImage(source as File) : NetworkImage(source as String) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 0, right: 8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(color: Colors.black54, child: const Icon(Icons.close, color: Colors.white, size: 20)),
          ),
        ),
      ],
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('Galería'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
            ListTile(leading: const Icon(Icons.photo_camera), title: const Text('Cámara'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
          ],
        ),
      ),
    );
  }
}
