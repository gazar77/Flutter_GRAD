import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fp/core/routing/app_routes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF2B4F7A);
    const Color backgroundColor = Color(0xFFF3F4F6);
    const Color cardColor = Colors.white;
    const Color lightBlue = Color(0xFFEAF2FB);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          /// HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 52, left: 16, right: 16, bottom: 18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF284E78), Color(0xFF5E789A)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Doctor Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
              child: Column(
                children: [
                  /// PROFILE IMAGE
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor.withOpacity(0.6),
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.12),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 52,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/300?img=12',
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// MAIN INFO CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    decoration: _cardDecoration(cardColor),
                    child: Column(
                      children: const [
                        Text(
                          'DR. Ahmed Mansour',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Cardiologist',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5C91D1),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Dar Al Fouad Hospital',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF5F5F5F),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// CONTACT INFO
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: _cardDecoration(cardColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Contact Info',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF222222),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _infoRow(
                          icon: Icons.email_outlined,
                          title: 'Email',
                          value: 'ahmed.mansour11@gmail.com',
                          valueColor: const Color(0xFF5C91D1),
                        ),
                        const SizedBox(height: 10),
                        _infoRow(
                          icon: Icons.phone_outlined,
                          title: 'Phone',
                          value: '+20 10 1234 5678',
                        ),
                        const SizedBox(height: 10),
                        _infoRow(
                          icon: Icons.local_hospital_outlined,
                          title: 'Extension',
                          value: '+20 10 2534 2435',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// STATISTICS
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: _cardDecoration(cardColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Statistics',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF222222),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _statCard(
                                bgColor: lightBlue,
                                icon: Icons.groups_2_outlined,
                                title: 'Total Patients',
                                value: '1,029',
                                primaryColor: primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _statCard(
                                bgColor: lightBlue,
                                icon: Icons.analytics_outlined,
                                title: 'Analyses Performed',
                                value: '900',
                                primaryColor: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// ACTION BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: () {
                              // context.push(AppRoutes.editProfile);
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // context.push(AppRoutes.settings);
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            icon: const Icon(Icons.settings_outlined, size: 18),
                            label: const Text(
                              'Settings',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      /// BOTTOM NAV
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 2,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.black87,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          onTap: (index) {
            if (index == 0) context.go(AppRoutes.home);
            if (index == 1) context.go(AppRoutes.history);
            if (index == 2) context.go(AppRoutes.profile);
            if (index == 3) {
              // context.go(AppRoutes.settings);
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
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
              label: 'Setting',
            ),
          ],
        ),
      ),
    );
  }

  static BoxDecoration _cardDecoration(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 10,
          offset: Offset(0, 3),
        ),
      ],
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
    Color valueColor = const Color(0xFF3A3A3A),
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6F8AA8)),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF202020),
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: valueColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required Color bgColor,
    required IconData icon,
    required String title,
    required String value,
    required Color primaryColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF3F3F3F),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}