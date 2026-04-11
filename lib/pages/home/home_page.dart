import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'models/home_data_model.dart';
import 'services/home_service.dart';
import 'package:provider/provider.dart';
import '../../core/routing/app_routes.dart';
import '../../core/app_state.dart';
import '../../core/theme/glass_container.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late Future<HomeDataModel> _homeFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _refresh() {
    final future = HomeService().getHomeData();
    future.then((data) {
      debugPrint('DEBUG: Home Page Refreshed. Stats: P=${data.totalPatients}, R=${data.totalReports}');
      
      if (data.error != null && mounted) {
        debugPrint('HOME_ERROR: ${data.error}');
        // Only show error snackbar if there's a real issue
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${data.error}')),
        );
      }

      if (!mounted) return;
      final appState = context.read<AppState>();
      if (data.doctorName.isNotEmpty && appState.doctorName.isEmpty && mounted) {
        appState.updateDoctorProfile(
          name: data.doctorName,
        );
      }
    });
    setState(() {
      _homeFuture = future;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2B4F7A);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 1) context.go(AppRoutes.history);
          if (index == 2) context.go(AppRoutes.profile);
          if (index == 3) context.go(AppRoutes.settings);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<HomeDataModel>(
          future: _homeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final homeData = snapshot.data ??
                HomeDataModel(
                  doctorName: context.read<AppState>().doctorName,
                  doctorImage: null,
                  totalPatients: 0,
                  totalReports: 0,
                  recentAnalyses: <AnalysisItemModel>[],
                );

            return RefreshIndicator(
              onRefresh: () async {
                _refresh();
                await _homeFuture;
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0x332196F3),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0x192B4F7A),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Consumer<AppState>(
                            builder: (context, appState, _) => ClipOval(
                              child: appState.profileImageFile != null
                                  ? Image.file(
                                      appState.profileImageFile!,
                                      fit: BoxFit.cover,
                                    )
                                  : (homeData.doctorImage != null &&
                                          homeData.doctorImage!.isNotEmpty
                                      ? Image.network(
                                          homeData.doctorImage!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              const Icon(Icons.person,
                                                  size: 36,
                                                  color: primaryColor),
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return const Center(child: CircularProgressIndicator());
                                          },
                                        )
                                      : const Icon(Icons.person,
                                          size: 36, color: primaryColor)),
                            ),
                          ),
                        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Consumer<AppState>(
                                builder: (context, appState, _) => Text(
                                  'Hello, Dr. ${appState.doctorName}',
                                  style: const TextStyle(
                                    fontFamily: 'sans-serif',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2B3A4A),
                                  ),
                                ),
                              ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
                              const SizedBox(height: 4),
                              Text(
                                'welcome back',
                                style: const TextStyle(
                                  fontFamily: 'sans-serif',
                                  fontSize: 14,
                                  color: Colors.grey,
                                  letterSpacing: 0.5,
                                ),
                              ).animate().fadeIn(delay: 200.ms),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Text(
                      'Find your Patient',
                      style: const TextStyle(
                        fontFamily: 'sans-serif',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2B3A4A),
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 12),

                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x0A000000),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search by Name or ID',
                          hintStyle: const TextStyle(
                            fontFamily: 'sans-serif',
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          prefixIcon: const Icon(Icons.search, color: primaryColor, size: 22),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Patients',
                            imagePath: 'assets/images/WhatsApp Image 2026-04-08 at 6.35.59 AM.jpeg',
                            fallbackIcon: Icons.child_care,
                            number: homeData.totalPatients.toString(),
                            subtitle: 'Total Records',
                            delay: 500,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _StatCard(
                            title: 'Reports',
                            imagePath: 'assets/images/WhatsApp Image 2026-04-08 at 6.36.16 AM.jpeg',
                            fallbackIcon: Icons.assignment,
                            number: homeData.totalReports.toString(),
                            subtitle: 'Analyses Done',
                            delay: 600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            text: 'Add Patient',
                            icon: Icons.person_add_rounded,
                            onTap: () {
                              context.push(AppRoutes.addPatient).then((_) => _refresh());
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _ActionButton(
                            text: 'Upload Video',
                            icon: Icons.videocam_rounded,
                            onTap: () {
                              context.push(AppRoutes.upload).then((_) => _refresh());
                            },
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 700.ms),
                    const SizedBox(height: 12),
                    _ActionButton(
                      text: 'DICOM to Video Converter',
                      icon: Icons.transform_rounded,
                      onTap: () {
                        context.push(AppRoutes.dicomConverter);
                      },
                    ),
                    const SizedBox(height: 12),
                    _ActionButton(
                      text: 'Manage Patients Repository',
                      icon: Icons.folder_shared_rounded,
                      onTap: () {
                        context.push(AppRoutes.patients).then((_) => _refresh());
                      },
                    ).animate().fadeIn(delay: 800.ms),

                    const SizedBox(height: 40),

                    Text(
                      'Clinical Insights',
                      style: const TextStyle(
                        fontFamily: 'sans-serif',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B3A4A),
                      ),
                    ).animate().fadeIn(delay: 900.ms),

                    const SizedBox(height: 15),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _InsightCard(
                            title: 'Risk Trends',
                            description: 'Critical cases decreased by 12% this week.',
                            icon: Icons.trending_down_rounded,
                            color: const Color(0xFFE57373),
                          ),
                          const SizedBox(width: 15),
                          _InsightCard(
                            title: 'System Health',
                            description: 'AI Processing latency is optimal (0.8s).',
                            icon: Icons.speed_rounded,
                            color: const Color(0xFF81C784),
                          ),
                          const SizedBox(width: 15),
                          _InsightCard(
                            title: 'Pending Reviews',
                            description: '4 analysis reports awaiting final signature.',
                            icon: Icons.pending_actions_rounded,
                            color: const Color(0xFFFFB74D),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 1000.ms).slideX(begin: 0.1),

                    const SizedBox(height: 30),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor.withValues(alpha: 0.8), primaryColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.lightbulb_outline_rounded, color: Colors.white, size: 24),
                              SizedBox(width: 10),
                              Text(
                                'Pro Tip of the Day',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Regular calibration of DICOM sources improves AI stenosis detection accuracy by up to 15%.',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14, height: 1.5),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 1100.ms).scale(begin: const Offset(0.95, 0.95)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final IconData fallbackIcon;
  final String number;
  final String subtitle;
  final int delay;

  const _StatCard({
    required this.title,
    required this.imagePath,
    required this.fallbackIcon,
    required this.number,
    required this.subtitle,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2B4F7A);

    return GlassContainer(
      opacity: 0.1,
      blur: 20,
      borderRadius: 24,
      padding: const EdgeInsets.all(16),
      child: Column(
          children: [
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'sans-serif',
                fontSize: 12,
                color: Color(0xB32B4F7A),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 50,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    fallbackIcon,
                    size: 40,
                    color: primaryColor,
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
            Text(
              number,
              style: const TextStyle(
                fontFamily: 'sans-serif',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'sans-serif',
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ).animate().scale(delay: delay.ms, duration: 500.ms, curve: Curves.easeOutBack).fadeIn();
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2B4F7A);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [primaryColor, Color(0xFF3E6CA3)],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color(0x4D2B4F7A),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'sans-serif',
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _InsightCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4),
          ),
        ],
      ),
    );
  }
}