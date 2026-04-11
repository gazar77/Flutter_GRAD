import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/routing/app_routes.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _content = const [
    OnboardingContent(
      title: 'Precision AI Analysis',
      description: 'Advanced deep learning algorithms for precise coronary stenosis detection and medical imaging analysis.',
      icon: Icons.biotech,
      color: Color(0xFF2B4F7A),
    ),
    OnboardingContent(
      title: 'Smart Reports',
      description: 'Generate comprehensive medical reports with visual analytics and export them as professional PDFs instantly.',
      icon: Icons.analytics,
      color: Color(0xFF1B324F),
    ),
    OnboardingContent(
      title: 'Secure & Reliable',
      description: 'Enterprise-grade security for your patient data with encrypted storage and seamless backend synchronization.',
      icon: Icons.security,
      color: Color(0xFF0D1B2A),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _content.length,
            itemBuilder: (context, index) {
              final item = _content[index];
              return Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      item.color.withAlpha((0.8 * 255).toInt()),
                      item.color,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 120,
                      color: Colors.white,
                    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
                    
                    const SizedBox(height: 60),
                    
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'sans-serif',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ).animate().fadeIn(delay: 200.ms).slide().scale(),
                    
                    const SizedBox(height: 20),
                    
                    Text(
                      item.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'sans-serif',
                        fontSize: 16,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                  ],
                ),
              );
            },
          ),
          
          // Bottom Controls
          Positioned(
            bottom: 50,
            left: 40,
            right: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Indicators
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    _content.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? Colors.white : Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                
                // Next/Get Started Button
                Flexible(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _content.length - 1) {
                        context.go(AppRoutes.login);
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _content[_currentPage].color,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentPage == _content.length - 1 ? 'GET STARTED' : 'NEXT',
                      style: const TextStyle(
                        fontFamily: 'sans-serif',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ).animate().scale(delay: 600.ms),
              ],
            ),
          ),
          
          // Skip button
          Positioned(
            top: 60,
            right: 20,
            child: TextButton(
              onPressed: () => context.go(AppRoutes.login),
              child: const Text(
                'SKIP',
                style: TextStyle(color: Colors.white54, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingContent {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const OnboardingContent({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
