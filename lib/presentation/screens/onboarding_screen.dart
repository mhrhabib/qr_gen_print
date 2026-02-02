import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import '../widgets/paywall_modal.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Create Stunning QRs',
      description: 'Generate beautiful, customized QR codes in seconds with our 2-step process.',
      icon: Icons.qr_code_2,
      color: const Color(0xFF6366F1),
    ),
    OnboardingData(
      title: 'Personalize Everything',
      description: 'Change colors, add logos, and select unique frames to match your brand.',
      icon: Icons.palette,
      color: const Color(0xFF8B5CF6),
    ),
    OnboardingData(
      title: 'Export in High Quality',
      description: 'Download in PNG, PDF, or SVG formats ready for digital use or high-end printing.',
      icon: Icons.file_download,
      color: const Color(0xFFEC4899),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) => _buildPage(_pages[index]),
          ),
          Positioned(
            bottom: 60,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) => _buildDot(index == _currentPage)),
                ),
                const SizedBox(height: 32),
                _buildButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: data.color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(data.icon, size: 100, color: data.color),
          ),
          const SizedBox(height: 48),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937)),
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 18, color: const Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: active ? 24 : 8,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF6366F1) : Colors.black12,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildButton() {
    bool isLast = _currentPage == _pages.length - 1;
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          FilledButton(
            onPressed: () {
              if (isLast) {
                _showFinalStep();
              } else {
                _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
              }
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              backgroundColor: const Color(0xFF6366F1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(
              isLast ? 'Get Started' : 'Next Step',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          if (isLast) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _navigateToHome(),
              child: Text('Skip for now', style: GoogleFonts.outfit(color: Colors.black45)),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showFinalStep() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_onboarding', false);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PaywallModal(),
    ).then((_) {
      if (mounted) {
        _navigateToHome();
      }
    });
  }

  Future<void> _navigateToHome() async {
    // Ensure flag is set if they skipped without closing logic
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_onboarding', false);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeThroughTransition(animation: animation, secondaryAnimation: secondaryAnimation, child: child);
        },
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({required this.title, required this.description, required this.icon, required this.color});
}
