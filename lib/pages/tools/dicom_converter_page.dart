import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import '../../core/networking/api_constants.dart';
import '../../core/networking/dio_factory.dart';
import 'package:share_plus/share_plus.dart';


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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

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

    setState(() {
      _isConverting = true;
    });

    try {
      final dio = DioFactory.getDio();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          _selectedFile!.path,
          filename: _selectedFileName,
        ),
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
      debugPrint('Error: $e');
      String errorMsg = 'Conversion failed';
      if (e is DioException && e.response != null) {
        // Try to get the specific error message from the backend
        try {
          final responseData = e.response!.data;
          if (responseData is List<int>) {
             errorMsg = String.fromCharCodes(responseData);
          } else {
             errorMsg = responseData.toString();
          }
        } catch (_) {
          errorMsg = e.message ?? e.toString();
        }
      } else {
        errorMsg = e.toString();
      }

      setState(() {
        _isConverting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _initializePreview(File file) async {
    try {
      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      controller.setLooping(true);
      controller.play();
      setState(() {
        _videoController = controller;
      });
    } catch (e) {
      debugPrint('Preview error: $e');
    }
  }

  Future<void> _downloadVideo() async {
    if (_resultVideoFile == null) return;

    try {
      await SharePlus.shareXFiles([XFile(_resultVideoFile!.path)], subject: 'Converted DICOM Video');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2B4F7A);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text('DICOM Video Converter'),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Convert your medical DICOM scans to viewable MP4 videos instantly.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Select Area
            GestureDetector(
              onTap: _pickDicomFile,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: primaryColor.withAlpha(76), width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _selectedFile == null ? Icons.file_present : Icons.check_circle,
                      size: 48,
                      color: _selectedFile == null ? primaryColor : Colors.green,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _selectedFileName ?? 'Tap to select DICOM file',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            if (_selectedFile != null && _resultVideoFile == null)
              ElevatedButton(
                onPressed: _isConverting ? null : _convertToVideo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isConverting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Convert to MP4', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),

            if (_resultVideoFile != null) ...[
              const Text(
                'Conversion Success!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 20),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: _videoController != null && _videoController!.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                   Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDicomFile,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Convert Another'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(color: primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _downloadVideo,
                      icon: const Icon(Icons.download),
                      label: const Text('View / Share MP4'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
