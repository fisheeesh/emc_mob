import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:emc_mob/providers/login_provider.dart';
import 'package:emc_mob/screens/onBoard/on_boarding_screen.dart';
import 'package:emc_mob/screens/main/home_screen.dart';
import 'package:emc_mob/screens/auth/login_screen.dart';
import 'package:emc_mob/utils/constants/image_strings.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({Key? key}) : super(key: key);

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    // Navigate after animation and initialization
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // Check onboarding status and user login
    final prefs = await SharedPreferences.getInstance();
    final isViewed = prefs.getInt('onBoard');
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);

    // Determine which screen to navigate to
    Widget nextScreen;
    if (isViewed != 0) {
      nextScreen = OnBoardingScreen();
    } else if (await loginProvider.ensureValidToken()) {
      nextScreen = const HomeScreen();
    } else {
      nextScreen = const LoginScreen();
    }

    // Navigate with fade transition
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _logoSection(),
                const SizedBox(height: 40),
                _loadingSpinner(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo
        Image.asset(
          EImages.ataLogo,
          width: 260,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 5),
        Text(
          'Emotion Check-In Application',
          style: GoogleFonts.michroma(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _loadingSpinner() {
    return const SizedBox(
      width: 30,
      height: 30,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
      ),
    );
  }
}