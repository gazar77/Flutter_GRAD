import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fp/core/networking/api_constants.dart';
import 'package:fp/core/networking/dio_factory.dart';
import 'package:fp/core/routing/app_routes.dart';
import 'package:fp/core/services/patient_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:video_player/video_player.dart';

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
      debugPrint('Error loading patients: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading patients: $e')),
        );
      }
    }
  }

  Future<void> _pickVideoFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
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

      // Automatically try to initialize preview with a safe delay
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && selectedFile != null) {
          _initializeVideoPreview();
        }
      });
    }
  }

  Future<void> _initializeVideoPreview() async {
    if (selectedFile == null) return;
    
    try {
      final controller = VideoPlayerController.file(selectedFile!);
      await controller.initialize();
      controller.setLooping(true);
      controller.play();

      setState(() {
        _videoController = controller;
      });
    } catch (e) {
      debugPrint('Error initializing video player: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot show preview for this video format on this device.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickDicomFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
      allowedExtensions: null,
    );
    if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
      setState(() {
        selectedFile = File(result.files.first.path!);
        selectedFileName = result.files.first.name;
      });
    }
  }

  Future<void> _uploadAndAnalyze() async {
    if (selectedFile == null || selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select patient and file')),
      );
      return;
    }

    // Show loading immediately
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Uploading...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );
    }

    int studyId = 0;

    try {
      final dio = DioFactory.getDio();
      final formData = FormData.fromMap({
        'PatientId': selectedPatientId,
        'File': await MultipartFile.fromFile(selectedFile!.path),
      });

      final response = await dio.post(
        '${ApiConstants.studies}/upload',
        data: formData,
      );

      if (response.statusCode == 200) {
        studyId = response.data['id'];
      } else {
        throw Exception('Upload failed: ${response.statusMessage}');
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      // Still navigate to processing to show the error state there
    }

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      context.go(AppRoutes.processing, extra: {
        'file': selectedFile,
        'studyId': studyId,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2B4F7A);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text('Upload Angiography Video'),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Patients Scan to start analysis',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            /// 🔹 Select Patient
            const Text(
              'Select Patient',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            isLoadingPatients
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.black26),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedPatientId,
                        hint: const Text('Select Patient'),
                        isExpanded: true,
                        items: patients.map((p) {
                          return DropdownMenuItem<int>(
                            value: p['id'],
                            child: Text('${p['fullName']}, ${p['age']}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPatientId = value;
                          });
                        },
                      ),
                    ),
                  ),

            const SizedBox(height: 20),

            /// 🔹 Upload Boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _UploadBox(
                  title: 'Tap to upload\nangiography video\n(MP4)',
                  icon: Icons.video_file,
                  onTap: _pickVideoFile,
                ),
                _UploadBox(
                  title: 'Tap to upload\nangiography scan\n(DICOM)',
                  icon: Icons.file_present,
                  onTap: _pickDicomFile,
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// 🔹 Preview
            if (selectedFile != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected File',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.3 * 255).toInt()),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        children: [
                          if (_videoController != null && _videoController!.value.isInitialized)
                            Center(
                              child: AspectRatio(
                                aspectRatio: _videoController!.value.aspectRatio,
                                child: VideoPlayer(_videoController!),
                              ),
                            )
                          else if (selectedFileName != null && (selectedFileName!.toLowerCase().endsWith('.mp4') || selectedFileName!.toLowerCase().endsWith('.mov')))
                            const Center(child: CircularProgressIndicator(color: Colors.white))
                          else
                            const Center(
                              child: Icon(Icons.description, color: Colors.white, size: 64),
                            ),
                          
                          // File info overlay
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withAlpha((0.8 * 255).toInt()),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          selectedFileName ?? 'Selected File',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${(selectedFile!.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB',
                                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedFile = null;
                                        selectedFileName = null;
                                        _videoController?.dispose();
                                        _videoController = null;
                                      });
                                    },
                                    icon: const Icon(Icons.close, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            const Spacer(),

            /// 🔹 Analyze Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _uploadAndAnalyze,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Analyze Video',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadBox extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _UploadBox({
    required this.title,
    this.icon = Icons.cloud_upload,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF2FB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF2B4F7A),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: const Color(0xFF2B4F7A)),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
