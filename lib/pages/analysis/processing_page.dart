import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fp/core/networking/api_constants.dart';
import 'package:fp/core/networking/dio_factory.dart';
import 'package:fp/core/routing/app_routes.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';

class ProcessingPage extends StatefulWidget {
  final File file;
  final int studyId;

  const ProcessingPage({super.key, required this.file, required this.studyId});

  @override
  State<ProcessingPage> createState() => _ProcessingPageState();
}

class _ProcessingPageState extends State<ProcessingPage> {
  double progress = 0.0;
  bool isError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _analyzeStudy();
  }

  Future<void> _analyzeStudy() async {
    try {
      final dio = DioFactory.getDio();
      
      // We'll show fake progress while waiting for the API
      final timer = Stream.periodic(const Duration(milliseconds: 100), (i) => i);
      final subscription = timer.listen((i) {
        if (mounted && progress < 0.9) {
          setState(() {
            progress += 0.01;
          });
        }
      });

      final response = await dio.post('${ApiConstants.analysis}/${widget.studyId}');

      subscription.cancel();

      if (response.statusCode == 200) {
        setState(() {
          progress = 1.0;
        });

        if (mounted) {
          context.read<AppState>().triggerDashboardRefresh();
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.go(
                AppRoutes.result,
                extra: {
                  'file': widget.file,
                  'studyId': widget.studyId,
                  'result': response.data,
                },
              );
            }
          });
        }
      } else {
        throw Exception('Analysis failed: ${response.statusMessage}');
      }
    } catch (e) {
      debugPrint('Analysis error: $e');
      if (mounted) {
        setState(() {
          isError = true;
          errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2B4F7A);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text(
              'Processing Analysis',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 60),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x402B4F7A),
                          blurRadius: 25,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: isError ? 1.0 : progress,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation(isError ? Colors.red : primaryColor),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(isError ? Icons.error : Icons.monitor_heart, 
                           color: isError ? Colors.red : primaryColor),
                      const SizedBox(height: 8),
                      Text(
                        isError ? 'ERROR' : '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: isError ? Colors.red : primaryColor,
                        ),
                      ),
                      Text(
                        isError ? 'FAILED' : 'ANALYZING',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            if (isError)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else ...[
              const Text(
                'Analyzing angiography video',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'This may take a few seconds',
                style: TextStyle(color: Colors.black54),
              ),
            ],
            if (isError)
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.upload),
                  child: const Text('Go Back'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}