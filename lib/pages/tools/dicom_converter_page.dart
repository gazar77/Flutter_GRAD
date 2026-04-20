import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/networking/api_constants.dart';
import '../../core/networking/dio_factory.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_button.dart';
import '../../core/localization/app_localizations.dart';

class DicomConverterPage extends StatefulWidget {
  const DicomConverterPage({super.key});

  @override
  State<DicomConverterPage> createState() => _DicomConverterPageState();
}

class _DicomConverterPageState extends State<DicomConverterPage> {
  File? _selectedFile;
  String? _selectedFileName;
  bool _isConverting = false;
  File? _resultVideoFile;
  VideoPlayerController? _videoController;

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickDicomFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);
    if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
      if (_videoController != null) {
        await _videoController!.dispose();
        _videoController = null;
      }
      setState(() {
        _selectedFile = File(result.files.first.path!);
        _selectedFileName = result.files.first.name;
        _resultVideoFile = null;
      });
    }
  }

  Future<void> _convertToVideo() async {
    if (_selectedFile == null) return;
    setState(() => _isConverting = true);
    try {
      final dio = DioFactory.getDio();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(_selectedFile!.path, filename: _selectedFileName),
      });

      final response = await dio.post(
        ApiConstants.dicomToVideo,
        data: formData,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
        final file = File(path);
        await file.writeAsBytes(response.data);
        setState(() {
          _resultVideoFile = file;
          _isConverting = false;
        });
        _initializePreview(file);
      } else {
        throw Exception('Conversion failed');
      }
    } catch (e) {
      setState(() => _isConverting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _initializePreview(File file) async {
    try {
      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      controller.setLooping(true);
      controller.play();
      setState(() => _videoController = controller);
    } catch (e) {
      debugPrint('Preview error: $e');
    }
  }

  Future<void> _shareVideo() async {
    if (_resultVideoFile == null) return;
    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(_resultVideoFile!.path)]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('dicom_converter'.tr(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('dicom_desc'.tr(context), textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 32),
            _buildSelectionArea(),
            const SizedBox(height: 32),
            if (_selectedFile != null && _resultVideoFile == null)
              AppButton(text: 'convert'.tr(context), isLoading: _isConverting, onPressed: _convertToVideo),
            if (_resultVideoFile != null) ...[
              const SizedBox(height: 16),
              _buildSuccessView(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionArea() {
    return AppCard(
      onTap: _pickDicomFile,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        width: double.infinity,
        child: Column(
          children: [
            Icon(
              _selectedFile == null ? Icons.upload_file_rounded : Icons.check_circle_rounded,
              size: 48,
              color: _selectedFile == null ? AppColors.primary : AppColors.success,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFileName ?? 'tap_to_select'.tr(context),
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildSuccessView() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
            const SizedBox(width: 8),
            Text('conversion_success'.tr(context), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success)),
          ],
        ),
        const SizedBox(height: 24),
        AppCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 300,
              color: Colors.black,
              child: _videoController != null && _videoController!.value.isInitialized
                  ? AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: VideoPlayer(_videoController!))
                  : const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            text: 'convert_another'.tr(context),
            variant: AppButtonVariant.outline,
            onPressed: _pickDicomFile,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppButton(
            text: 'share'.tr(context),
            onPressed: _shareVideo,
          ),
        ),
      ],
    );
  }
}
