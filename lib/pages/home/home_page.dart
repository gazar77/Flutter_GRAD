import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'models/home_data_model.dart';
import 'services/home_service.dart';
import '../../core/routing/app_routes.dart';

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
    homeFuture = HomeService().getHomeData();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2B4F7A);
    const backgroundColor = Color(0xFFF4F4F4);

    return Scaffold(
      backgroundColor: backgroundColor,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          if (index == 0) {
            context.go(AppRoutes.home);
          } else if (index == 1) {
            context.go(AppRoutes.history);
          } else if (index == 2) {
            // لما تعمل Profile route
          } else if (index == 3) {
            // لما تعمل Settings route
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.black87,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
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

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'حدث خطأ: ${snapshot.error}',
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text('لا توجد بيانات'),
              );
            }

            final homeData = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
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
                        child: ClipOval(
                          child: homeData.doctorImage != null &&
                                  homeData.doctorImage!.isNotEmpty
                              ? Image.network(
                                  homeData.doctorImage!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.person,
                                      size: 32,
                                      color: primaryColor,
                                    );
                                  },
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 32,
                                  color: primaryColor,
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello,Dr / ${homeData.doctorName}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5A7392),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'welcome back',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  const Divider(color: Colors.black45, thickness: 1),
                  const SizedBox(height: 6),

                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Find ',
                          style: TextStyle(
                            fontSize: 18,
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
                        imagePath: 'assets/images/patient_icon.png',
                        fallbackIcon: Icons.child_care,
                        number: homeData.totalPatients.toString(),
                        subtitle: 'Total Patients',
                      ),
                      _StatCard(
                        title: 'Reports',
                        imagePath: 'assets/images/report_icon.png',
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
                          icon: Icons.add,
                          onTap: () {
                            context.go(AppRoutes.addPatient);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionButton(
                          text: 'Upload Video',
                          icon: Icons.add,
                          onTap: () {
                            context.go(AppRoutes.upload);
                          },
                        ),
                      ),
                    ],
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
                      child: _RecentAnalysisItem(
                        patientName: analysis.patientName,
                        stenosisText: 'Stenosis ${analysis.stenosisPercent}%',
                        date: analysis.date,
                        dotColor: _getStenosisColor(analysis.stenosisPercent),
                      ),
                    ),
                  ),
                ],
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
      width: 105,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 52,
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
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              patientName,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, size: 10, color: dotColor),
                const SizedBox(width: 4),
                Text(
                  stenosisText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              date,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}