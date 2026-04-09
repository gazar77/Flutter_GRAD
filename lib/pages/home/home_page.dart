import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'models/home_data_model.dart';
import 'services/home_service.dart';
import 'package:provider/provider.dart';
import '../../core/routing/app_routes.dart';
import '../../core/app_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  late Future<HomeDataModel> homeFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final future = HomeService().getHomeData();
    future.then((data) {
      debugPrint('DEBUG: Home Page Refreshed. Stats: P=${data.totalPatients}, R=${data.totalReports}');
      if (data.doctorName.isNotEmpty && mounted) {
        context.read<AppState>().updateDoctorProfile(
          name: data.doctorName,
        );
      }
    });
    setState(() {
      homeFuture = future;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2B4F7A);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
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
          future: homeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Graceful fallback — uses AppState if API data is missing
            final homeData = snapshot.data ??
                HomeDataModel(
                  doctorName: context.read<AppState>().doctorName,
                  doctorImage: null,
                  totalPatients: 0,
                  totalReports: 0,
                  recentAnalyses: [],
                );

            return RefreshIndicator(
              onRefresh: () async {
                _refresh();
                await homeFuture;
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Header
                    Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Consumer<AppState>(
                            builder: (context, appState, _) => ClipOval(
                              child: appState.profileImageFile != null
                                  // 1️⃣ local image picked by user
                                  ? Image.file(
                                      appState.profileImageFile!,
                                      fit: BoxFit.cover,
                                    )
                                  : (homeData.doctorImage != null &&
                                          homeData.doctorImage!.isNotEmpty
                                      // 2️⃣ image from backend
                                      ? Image.network(
                                          homeData.doctorImage!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              const Icon(Icons.person,
                                                  size: 32,
                                                  color: primaryColor),
                                        )
                                      // 3️⃣ fallback icon
                                      : const Icon(Icons.person,
                                          size: 32, color: primaryColor)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Consumer<AppState>(
                                builder: (context, appState, _) => Text(
                                  'Hello, Dr. / ${appState.doctorName}',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5A7392),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'welcome back',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),
                    const Divider(color: Colors.grey, thickness: 0.5),
                    const SizedBox(height: 18),

                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Find ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          TextSpan(
                            text: 'your ',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          TextSpan(
                            text: 'Patient',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF9DB7DA)),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search for Patient',
                          hintStyle: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                          suffixIcon: const Icon(
                            Icons.search,
                            color: primaryColor,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatCard(
                          title: 'Patients',
                          imagePath: 'assets/images/WhatsApp Image 2026-04-08 at 6.35.59 AM.jpeg',
                          fallbackIcon: Icons.child_care,
                          number: homeData.totalPatients.toString(),
                          subtitle: 'Total Patients',
                        ),
                        _StatCard(
                          title: 'Reports',
                          imagePath: 'assets/images/WhatsApp Image 2026-04-08 at 6.36.16 AM.jpeg',
                          fallbackIcon: Icons.assignment,
                          number: homeData.totalReports.toString(),
                          subtitle: 'Generated Reports',
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            text: 'Add Patient',
                            icon: Icons.person_add,
                            onTap: () {
                              context.push(AppRoutes.addPatient).then((_) => _refresh());
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionButton(
                            text: 'Upload Video',
                            icon: Icons.video_call,
                            onTap: () {
                              context.push(AppRoutes.upload).then((_) => _refresh());
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _ActionButton(
                      text: 'Manage Patients',
                      icon: Icons.manage_accounts,
                      onTap: () {
                        context.push(AppRoutes.patients).then((_) => _refresh());
                      },
                    ),

                    const SizedBox(height: 48),

                    const Text(
                      'Recent Analyses',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 14),

                    ...homeData.recentAnalyses.map(
                      (analysis) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            context.go(AppRoutes.caseDetails, extra: {
                              'patientName': analysis.patientName,
                              'stenosisPercent': analysis.stenosisPercent,
                              'date': analysis.date,
                            });
                          },
                          child: _RecentAnalysisItem(
                            patientName: analysis.patientName,
                            stenosisText: 'Stenosis ${analysis.stenosisPercent}%',
                            date: analysis.date,
                            dotColor: _getStenosisColor(analysis.stenosisPercent),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getStenosisColor(int percent) {
    if (percent >= 70) return Colors.red;
    if (percent >= 40) return Colors.orange;
    return Colors.green;
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final IconData fallbackIcon;
  final String number;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.imagePath,
    required this.fallbackIcon,
    required this.number,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  fallbackIcon,
                  size: 46,
                  color: const Color(0xFF2B4F7A),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
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
        height: 42,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentAnalysisItem extends StatelessWidget {
  final String patientName;
  final String stenosisText;
  final String date;
  final Color dotColor;

  const _RecentAnalysisItem({
    required this.patientName,
    required this.stenosisText,
    required this.date,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  stenosisText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}