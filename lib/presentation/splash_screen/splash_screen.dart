import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../services/user_service.dart';
import '../../services/student_service.dart';
import './widgets/animated_logo_widget.dart';
import './widgets/background_gradient_widget.dart';
import './widgets/loading_indicator_widget.dart';
import './widgets/retry_connection_widget.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _isLoading = true;
  bool _showRetry = false;
  bool _animationCompleted = false;
  Timer? _timeoutTimer;

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
    // Wait for the AuthController to initialize
    await Future.delayed(const Duration(milliseconds: 600));
    
    // The auth state will be checked automatically by the AuthController
    // when we navigate to the next screen
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

    // Check real authentication state using AuthController
    final authState = ref.read(authControllerProvider);
    
    await authState.when(
      data: (user) async {
        if (user != null) {
          // User is authenticated, get their role and navigate
          final String? userRole = await ref.read(authControllerProvider.notifier).getUserRole();
          _navigateBasedOnRole(userRole ?? 'STUDENT');
        } else {
          // User is not authenticated, navigate to login
          Navigator.pushReplacementNamed(context, '/login-screen');
        }
      },
      loading: () async {
        // Auth is still loading, wait a bit more
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.pushReplacementNamed(context, '/login-screen');
      },
      error: (error, stack) async {
        // Auth error, navigate to login
        Navigator.pushReplacementNamed(context, '/login-screen');
      },
    );
  }

  void _navigateBasedOnRole(String role) async {
    String route;
    switch (role.toUpperCase()) {
      case 'STUDENT':
        // Validate student existence before navigation
        final isValidStudent = await _validateStudentAccess();
        if (isValidStudent) {
          route = '/student-dashboard';
        } else {
          // Invalid student, redirect to login
          route = '/login-screen';
        }
        break;
      case 'FACULTY':
        route = '/faculty-dashboard';
        break;
      case 'ADMIN':
      case 'ADMINISTRATOR':
        route = '/admin-dashboard';
        break;
      default:
        route = '/login-screen';
    }

    Navigator.pushReplacementNamed(context, route);
  }

  Future<bool> _validateStudentAccess() async {
    try {
      final user = ref.read(authControllerProvider).value;
      if (user == null) return false;

      final userService = UserService();
      final studentService = StudentService();

      // Get the current user from users collection
      final appUser = await userService.getUser(user.uid);
      if (appUser == null || appUser.uniqueId == null) {
        print('User not found in users collection or uniqueId is null');
        // Sign out invalid user
        await ref.read(authControllerProvider.notifier).signOut();
        return false;
      }

      // Check if student document exists
      final student = await studentService.getStudent(appUser.uniqueId!);
      if (student == null) {
        print('Student document not found for uniqueId: ${appUser.uniqueId}');
        // Sign out invalid student
        await ref.read(authControllerProvider.notifier).signOut();
        return false;
      }

      return true;
    } catch (e) {
      print('Error validating student access: $e');
      // Sign out on error
      await ref.read(authControllerProvider.notifier).signOut();
      return false;
    }
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
