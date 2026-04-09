import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fp/core/networking/api_constants.dart';
import 'package:fp/core/networking/dio_factory.dart';
import 'package:fp/core/routing/app_routes.dart';
import 'package:fp/core/services/patient_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

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
    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        selectedFileName = result.files.single.name;
      });
    }
  }

  Future<void> _pickDicomFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
      allowedExtensions: null,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        selectedFileName = result.files.single.name;
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
        title: const Text('Upload Angiography Image'),
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF2B4F7A).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B4F7A).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.play_circle_fill,
                        color: Color(0xFF2B4F7A),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedFileName ?? selectedFile!.path.split('/').last,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E1E1E),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(selectedFile!.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle, color: Colors.green, size: 22),
                  ],
                ),
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
