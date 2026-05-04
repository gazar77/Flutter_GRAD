import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/routing/app_routes.dart';
import '../../core/services/patient_service.dart';
import '../../core/services/study_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_button.dart';
import '../../core/localization/app_localizations.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  int? selectedPatientId;
  File? selectedFile;
  String? selectedFileName;
  List<Map<String, dynamic>> patients = [];
  bool isLoadingPatients = true;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      final rawPatients = await PatientService().getAllPatients();
      setState(() {
        patients = rawPatients.cast<Map<String, dynamic>>();
        isLoadingPatients = false;
      });
    } catch (e) {
      if (mounted) setState(() => isLoadingPatients = false);
    }
  }

  Future<void> _pickFile(FileType type, {List<String>? allowedExtensions}) async {
    final result = await FilePicker.platform.pickFiles(
      type: type,
      allowMultiple: false,
      allowedExtensions: allowedExtensions,
    );
    if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
      if (_videoController != null) {
        await _videoController!.dispose();
        _videoController = null;
      }

      setState(() {
        selectedFile = File(result.files.first.path!);
        selectedFileName = result.files.first.name;
      });

      if (type == FileType.video) {
        _initializeVideoPreview();
      }
    }
  }

  Future<void> _initializeVideoPreview() async {
    if (selectedFile == null) return;
    try {
      final controller = VideoPlayerController.file(selectedFile!);
      await controller.initialize();
      controller.setLooping(true);
      controller.play();
      setState(() => _videoController = controller);
    } catch (e) {
      debugPrint('Video init error: $e');
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _uploadAndAnalyze() async {
    if (selectedFile == null || selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select patient and file')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Uploading and processing...'), duration: Duration(seconds: 2)),
    );

    int studyId = 0;
    try {
      final studyService = StudyService();
      final data = await studyService.uploadStudy(
        patientId: selectedPatientId!,
        file: selectedFile!,
      );
      final rawId = data['id'];
      if (rawId is int) {
        studyId = rawId;
      } else if (rawId != null) {
        studyId = int.tryParse(rawId.toString()) ?? 0;
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }

    if (studyId <= 0) {
      return;
    }

    if (mounted) {
      context.go(AppRoutes.processing, extra: {'file': selectedFile, 'studyId': studyId});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('analyze'.tr(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ready_analysis'.tr(context), style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 32),
            _buildPatientSelector(),
            const SizedBox(height: 32),
            _buildUploadOptions(),
            const SizedBox(height: 32),
            if (selectedFile != null) _buildFilePreview(),
            const SizedBox(height: 48),
            AppButton(
              text: 'analyze'.tr(context),
              onPressed: _uploadAndAnalyze,
              isDisabled: selectedFile == null || selectedPatientId == null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('SELECT PATIENT', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
        AppCard(
          child: isLoadingPatients
              ? const Center(child: CircularProgressIndicator())
              : DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: selectedPatientId,
                    hint: Text('select_patient'.tr(context)),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    items: patients.map((p) => DropdownMenuItem<int>(value: p['id'], child: Text('${p['fullName']}, ${p['age']}'))).toList(),
                    onChanged: (v) => setState(() => selectedPatientId = v),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildUploadOptions() {
    return Row(
      children: [
        Expanded(child: _buildUploadBox('MP4 Video', Icons.video_library_rounded, () => _pickFile(FileType.video))),
        const SizedBox(width: 12),
        Expanded(child: _buildUploadBox('Image', Icons.image_rounded, () => _pickFile(FileType.custom, allowedExtensions: ['jpg', 'jpeg', 'png', 'bmp']))),
        const SizedBox(width: 12),
        Expanded(child: _buildUploadBox('DICOM', Icons.album_rounded, () => _pickFile(FileType.custom, allowedExtensions: ['dcm']))),
      ],
    );
  }


  Widget _buildUploadBox(String title, IconData icon, VoidCallback onTap) {
    return AppCard(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildFilePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text('SELECTED FILE', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                if (_videoController != null && _videoController!.value.isInitialized)
                  AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: VideoPlayer(_videoController!))
                else if (selectedFile != null && (selectedFile!.path.toLowerCase().endsWith('.jpg') || 
                         selectedFile!.path.toLowerCase().endsWith('.jpeg') || 
                         selectedFile!.path.toLowerCase().endsWith('.png') || 
                         selectedFile!.path.toLowerCase().endsWith('.bmp')))
                  Image.file(selectedFile!, height: 200, width: double.infinity, fit: BoxFit.contain)
                else
                  Container(
                    height: 160,
                    width: double.infinity,
                    color: AppColors.secondary.withValues(alpha: 0.05),
                    child: const Icon(Icons.description_rounded, size: 48, color: AppColors.primary),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text(selectedFileName ?? '', style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      IconButton(onPressed: () => setState(() => selectedFile = null), icon: const Icon(Icons.close_rounded, size: 20)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn().slideY(begin: 0.1),
      ],
    );
  }
}
