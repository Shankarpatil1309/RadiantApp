import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:radiant_app/controllers/auth_controller.dart';
import 'widgets/college_logo_widget.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _logoScaleAnimation;
  
  bool _isNavigating = false;
  String _selectedRole = 'STUDENT'; // Default role selection

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.bounceOut,
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _slideController.forward();
  }

  @override
  void dispose() {
    // Stop animations before disposing to prevent errors
    _stopAllAnimations();
    
    // Dispose animation controllers safely
    try {
      _fadeController.dispose();
      _slideController.dispose();
      _scaleController.dispose();
    } catch (e) {
      // Controllers might already be disposed
    }
    
    super.dispose();
  }

  void _onGoogleSignIn() async {
    // Haptic feedback
    HapticFeedback.lightImpact();

    // Trigger sign in with selected role
    ref.read(authControllerProvider.notifier).signInWithGoogle(_selectedRole);
  }

  void _navigateToRoleDashboard(BuildContext context, String role) {
    String route;
    switch (role.toUpperCase()) {
      case 'STUDENT':
        route = '/student-dashboard';
        break;
      case 'FACULTY':
        route = '/faculty-dashboard';
        break;
      case 'ADMIN':
      case 'ADMINISTRATOR':
        route = '/admin-dashboard';
        break;
      default:
        route = '/no-access-screen'; // Default to no access screen for unknown roles
    }

    // Stop all animations before navigation
    _stopAllAnimations();

    // Navigate to the appropriate dashboard
    Navigator.pushReplacementNamed(context, route);
  }

  void _stopAllAnimations() {
    if (mounted) {
      try {
        _fadeController.stop();
        _slideController.stop();
        _scaleController.stop();
      } catch (e) {
        // Animation controllers might already be disposed
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    // Listen for authentication success and navigate
    ref.listen<AsyncValue>(authControllerProvider, (previous, next) {
      if (_isNavigating || !mounted) return;
      
      next.when(
        data: (user) async {
          // Only navigate if user is authenticated AND previous state was loading
          // This ensures we only navigate on successful authentication, not on auth state changes
          if (user != null && !_isNavigating && previous?.isLoading == true) {
            _isNavigating = true;
            // User successfully signed in, navigate to appropriate dashboard
            final String? userRole = await ref.read(authControllerProvider.notifier).getUserRole();
            if (mounted) {
              _navigateToRoleDashboard(context, userRole ?? 'STUDENT');
            }
          }
        },
        loading: () {},
        error: (error, stack) {
          // Reset navigation flag on error so user can retry
          _isNavigating = false;
        },
      );
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.4, 0.8, 1.0],
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.surface,
              theme.colorScheme.surface,
              theme.colorScheme.secondary.withOpacity(0.03),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 8.h),

                  // Animated College Logo
                  AnimatedBuilder(
                    animation: _logoScaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: const CollegeLogoWidget(),
                      );
                    },
                  ),

                  SizedBox(height: 6.h),

                  // Animated Welcome Section
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          Text(
                            'Welcome Back!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Sign in to access your academic portal',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Animated Login Illustration
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 60.w,
                        height: 25.h,
                        constraints: const BoxConstraints(
                          maxWidth: 280,
                          maxHeight: 220,
                        ),
                        child: Image.asset(
                          'assets/images/login_illustration.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.school_rounded,
                                size: 80,
                                color: theme.colorScheme.primary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 6.h),

                  // Animated Role Selection
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildRoleSelection(theme),
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Animated Google Sign In Button
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child:
                          _buildGoogleSignInButton(context, authState, theme),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Animated Error Message
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: authState.hasError
                        ? _buildErrorMessage(authState.error.toString(), theme)
                        : const SizedBox.shrink(),
                  ),

                  SizedBox(height: 4.h),

                  // Animated Footer Information
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildFooterInfo(theme),
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton(
      BuildContext context, dynamic authState, ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 6.h,
      constraints: const BoxConstraints(
        minHeight: 56,
        maxHeight: 70,
      ),
      child: authState.isLoading
          ? _buildLoadingButton(theme)
          : _buildGoogleButton(theme),
    );
  }

  Widget _buildLoadingButton(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              'Signing in...',
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleButton(ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _onGoogleSignIn,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/google.png',
                  height: 24,
                  width: 24,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Text(
                          'G',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(width: 3.w),
                Text(
                  'Continue with Google',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String error, ThemeData theme) {
    return Container(
      key: ValueKey(error),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: theme.colorScheme.error,
            size: 20,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              error,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterInfo(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Use your B.K.I.T college email to sign in',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          '© 2024 B.K.I.T College. All rights reserved.',
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select your role',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildRoleOption('STUDENT', 'Student', Icons.school, theme),
              Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
              _buildRoleOption('FACULTY', 'Faculty', Icons.person_outline, theme),
              Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
              _buildRoleOption('ADMIN', 'Administrator', Icons.admin_panel_settings, theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleOption(String value, String label, IconData icon, ThemeData theme) {
    final isSelected = _selectedRole == value;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRole = value;
          });
          HapticFeedback.selectionClick();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 24,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
