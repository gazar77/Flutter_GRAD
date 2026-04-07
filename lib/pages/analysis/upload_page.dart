import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fp/core/routing/app_routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  String? selectedPatient;
  File? selectedFile;

  final List<String> patients = [
    'Nora Ahmed, 59',
    'Sara Hassan, 45',
    'Khaled Ahmed, 60',
  ];

  final ImagePicker picker = ImagePicker();

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedFile = File(picked.path);
      });
    }
  }

  void analyze() {
    if (selectedFile == null || selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select patient and file')),
      );
      return;
    }

    /// هنا بعدين هتربط مع FastAPI
    debugPrint('Analyzing for $selectedPatient');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Analyzing...')));
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

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.black26),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedPatient,
                  hint: const Text('Select Patient (e.g., Nora Ahmed , 59)'),
                  isExpanded: true,
                  items: patients.map((p) {
                    return DropdownMenuItem(value: p, child: Text(p));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPatient = value;
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
                  onTap: pickImage,
                ),
                _UploadBox(
                  title: 'Tap to upload\nangiography video\n(DICOM)',
                  onTap: pickImage,
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// 🔹 Preview
            if (selectedFile != null)
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(selectedFile!, fit: BoxFit.cover),
                ),
              ),

            const Spacer(),

            /// 🔹 Analyze Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  context.go(AppRoutes.processing, extra: selectedFile);
                },
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

/// 🔹 Upload Box Widget
class _UploadBox extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _UploadBox({required this.title, required this.onTap});

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
            color: Color(0xFF2B4F7A),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_upload, size: 30),
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
