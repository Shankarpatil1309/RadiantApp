import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/animated_logo_widget.dart';
import './widgets/background_gradient_widget.dart';
import './widgets/loading_indicator_widget.dart';
import './widgets/retry_connection_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;
  bool _showRetry = false;
  bool _animationCompleted = false;
  Timer? _timeoutTimer;

  // Mock authentication states for demonstration
  final List<Map<String, dynamic>> _mockUsers = [
    {
      "email": "student@bkit.edu",
      "password": "student123",
      "role": "student",
      "name": "John Doe",
      "id": "STU001"
    },
    {
      "email": "faculty@bkit.edu",
      "password": "faculty123",
      "role": "faculty",
      "name": "Dr. Sarah Wilson",
      "id": "FAC001"
    },
    {
      "email": "admin@bkit.edu",
      "password": "admin123",
      "role": "admin",
      "name": "Michael Johnson",
      "id": "ADM001"
    }
  ];

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _setSystemUIOverlay();
  }

  void _setSystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.lightTheme.colorScheme.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _initializeApp() async {
    setState(() {
      _isLoading = true;
      _showRetry = false;
    });

    // Start timeout timer
    _timeoutTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _isLoading) {
        setState(() {
          _showRetry = true;
          _isLoading = false;
        });
      }
    });

    try {
      // Simulate Firebase initialization
      await _initializeFirebase();

      // Check authentication state
      await _checkAuthenticationState();

      // Load cached data
      await _loadCachedData();

      // Verify network connectivity
      await _checkNetworkConnectivity();

      // Refresh push notification token
      await _refreshNotificationToken();

      // Wait for animation to complete
      while (!_animationCompleted) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      _timeoutTimer?.cancel();

      if (mounted) {
        await _navigateToNextScreen();
      }
    } catch (e) {
      _timeoutTimer?.cancel();
      if (mounted) {
        setState(() {
          _showRetry = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _initializeFirebase() async {
    // Simulate Firebase Auth initialization
    await Future.delayed(const Duration(milliseconds: 800));
  }

  Future<void> _checkAuthenticationState() async {
    // Simulate authentication state check
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<void> _loadCachedData() async {
    // Simulate loading cached academic data
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _checkNetworkConnectivity() async {
    // Simulate network connectivity check
    await Future.delayed(const Duration(milliseconds: 400));
  }

  Future<void> _refreshNotificationToken() async {
    // Simulate FCM token refresh
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _navigateToNextScreen() async {
    // Add haptic feedback
    HapticFeedback.lightImpact();

    // Simulate checking for stored authentication
    final bool isAuthenticated = await _checkStoredAuthentication();

    if (isAuthenticated) {
      final String userRole = await _getUserRole();
      _navigateBasedOnRole(userRole);
    } else {
      // Navigate to login screen
      Navigator.pushReplacementNamed(context, '/login-screen');
    }
  }

  Future<bool> _checkStoredAuthentication() async {
    // Simulate checking stored JWT token or auth state
    await Future.delayed(const Duration(milliseconds: 200));
    // For demo purposes, return false to show login screen
    return false;
  }

  Future<String> _getUserRole() async {
    // Simulate getting user role from stored data
    await Future.delayed(const Duration(milliseconds: 100));
    return 'student'; // Default role for demo
  }

  void _navigateBasedOnRole(String role) {
    String route;
    switch (role.toLowerCase()) {
      case 'student':
        route = '/student-dashboard';
        break;
      case 'faculty':
        route = '/faculty-dashboard';
        break;
      case 'admin':
        route = '/admin-dashboard';
        break;
      default:
        route = '/login-screen';
    }

    Navigator.pushReplacementNamed(context, route);
  }

  void _onAnimationComplete() {
    setState(() {
      _animationCompleted = true;
    });
  }

  void _retryInitialization() {
    _initializeApp();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundGradientWidget(
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: _showRetry ? _buildRetryView() : _buildLoadingView(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Center(
            child: AnimatedLogoWidget(
              onAnimationComplete: _onAnimationComplete,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const LoadingIndicatorWidget(),
              SizedBox(height: 4.h),
              Text(
                'BKIT College Management',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary
                      .withValues(alpha: 0.9),
                  fontSize: 4.w,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                'Streamlining Academic Excellence',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary
                      .withValues(alpha: 0.7),
                  fontSize: 3.w,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
      ],
    );
  }

  Widget _buildRetryView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Center(
            child: AnimatedLogoWidget(
              onAnimationComplete: _onAnimationComplete,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: RetryConnectionWidget(
              onRetry: _retryInitialization,
              message:
                  'Unable to connect to BKIT servers. Please check your internet connection and try again.',
            ),
          ),
        ),
        SizedBox(height: 4.h),
      ],
    );
  }
}
