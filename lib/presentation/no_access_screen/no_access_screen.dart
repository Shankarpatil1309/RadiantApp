import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:radiant_app/controllers/auth_controller.dart';

class NoAccessScreen extends ConsumerStatefulWidget {
  const NoAccessScreen({super.key});

  @override
  ConsumerState<NoAccessScreen> createState() => _NoAccessScreenState();
}

class _NoAccessScreenState extends ConsumerState<NoAccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

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
    try {
      _fadeController.dispose();
      _slideController.dispose();
      _scaleController.dispose();
    } catch (e) {
      // Controllers might already be disposed
    }
    super.dispose();
  }

  void _signOut() async {
    HapticFeedback.lightImpact();
    await ref.read(authControllerProvider.notifier).signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login-screen');
    }
  }

  void _contactSupport() {
    HapticFeedback.lightImpact();
    // TODO: Implement contact support functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Contact admin@bkit.edu.in or call +91 80-12345678',
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              theme.colorScheme.error.withValues(alpha: 0.05),
              theme.colorScheme.surface,
              theme.colorScheme.surface,
              theme.colorScheme.errorContainer.withValues(alpha: 0.03),
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

                  // Animated Error Illustration
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
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.block_rounded,
                                size: 80,
                                color: theme.colorScheme.error,
                              ),
                              SizedBox(height: 2.h),
                              Icon(
                                Icons.school_rounded,
                                size: 40,
                                color: theme.colorScheme.error.withValues(alpha: 0.6),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 6.h),

                  // Animated Title Section
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          Text(
                            'Access Denied',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.error,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'You don\'t have permission to access this application',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 6.h),

                  // Animated Information Card
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: theme.colorScheme.primary,
                              size: 32,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'This could happen if:',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            _buildInfoItem(
                              '• You\'re not registered in the college system',
                              theme,
                            ),
                            _buildInfoItem(
                              '• Your account is pending activation',
                              theme,
                            ),
                            _buildInfoItem(
                              '• You selected the wrong role during login',
                              theme,
                            ),
                            _buildInfoItem(
                              '• Your access permissions have been revoked',
                              theme,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Animated Action Buttons
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          // Contact Support Button
                          Container(
                            width: double.infinity,
                            height: 6.h,
                            constraints: const BoxConstraints(
                              minHeight: 56,
                              maxHeight: 70,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _contactSupport,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.support_agent_rounded,
                                          color: theme.colorScheme.onPrimary,
                                          size: 24,
                                        ),
                                        SizedBox(width: 3.w),
                                        Text(
                                          'Contact Support',
                                          style: GoogleFonts.inter(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 2.h),

                          // Sign Out Button
                          Container(
                            width: double.infinity,
                            height: 6.h,
                            constraints: const BoxConstraints(
                              minHeight: 56,
                              maxHeight: 70,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _signOut,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.logout_rounded,
                                          color: theme.colorScheme.onSurface,
                                          size: 24,
                                        ),
                                        SizedBox(width: 3.w),
                                        Text(
                                          'Sign Out & Try Again',
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Animated Footer
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.error.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.admin_panel_settings_rounded,
                                color: theme.colorScheme.error,
                                size: 20,
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Text(
                                  'Contact college administration for access',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.error,
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
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildInfoItem(String text, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}