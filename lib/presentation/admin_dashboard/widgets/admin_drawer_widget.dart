import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../controllers/auth_controller.dart';

class AdminDrawerWidget extends ConsumerWidget {
  final Map<String, dynamic> adminData;
  final Function(String) onNavigate;

  const AdminDrawerWidget({
    Key? key,
    required this.adminData,
    required this.onNavigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerSection('User Management', [
                  _buildDrawerItem(
                    'All Students',
                    'school',
                    () => onNavigate('/student-management'),
                  ),
                  _buildDrawerItem(
                    'All Faculty',
                    'person',
                    () => onNavigate('/faculty-management'),
                  ),
                  _buildDrawerItem(
                    'Department Wise',
                    'business',
                    () => onNavigate('/department-management'),
                  ),
                ]),
                _buildDrawerSection('System Management', [
                  _buildDrawerItem(
                    'Announcements',
                    'campaign',
                    () => onNavigate('/announcement-management'),
                  ),
                  _buildDrawerItem(
                    'Reports & Analytics',
                    'assessment',
                    () => onNavigate('/reports'),
                  ),
                  _buildDrawerItem(
                    'System Settings',
                    'settings',
                    () => onNavigate('/system-settings'),
                  ),
                ]),
                _buildDrawerSection('Data Operations', [
                  _buildDrawerItem(
                    'Export Data',
                    'download',
                    () => onNavigate('/data-export'),
                  ),
                  _buildDrawerItem(
                    'Backup & Restore',
                    'backup',
                    () => onNavigate('/backup'),
                  ),
                  _buildDrawerItem(
                    'Audit Logs',
                    'history',
                    () => onNavigate('/audit-logs'),
                  ),
                ]),
                Divider(),
                _buildDrawerItem(
                  'Profile Settings',
                  'account_circle',
                  () => onNavigate('/profile-settings'),
                ),
                _buildDrawerItem(
                  'Help & Support',
                  'help',
                  () => onNavigate('/help'),
                ),
                _buildDrawerItem(
                  'Logout',
                  'logout',
                  () => _showLogoutDialog(context, ref),
                  isLogout: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      height: 25.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.getRoleColor('admin'),
            AppTheme.getRoleColor('admin').withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: ClipOval(
                  child: adminData['profileImage'] != null
                      ? CustomImageWidget(
                          imageUrl: adminData['profileImage'] as String,
                          width: 20.w,
                          height: 20.w,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.white.withValues(alpha: 0.2),
                          child: CustomIconWidget(
                            iconName: 'person',
                            color: Colors.white,
                            size: 10.w,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                adminData['name'] as String,
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                adminData['designation'] as String,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              Text(
                'Employee ID: ${adminData['employeeId']}',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 1.h),
          child: Text(
            title,
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.getRoleColor('admin'),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...items,
        SizedBox(height: 1.h),
      ],
    );
  }

  Widget _buildDrawerItem(
    String title,
    String iconName,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: isLogout
            ? AppTheme.getStatusColor('error')
            : AppTheme.getRoleColor('admin').withValues(alpha: 0.7),
        size: 24,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: isLogout
              ? AppTheme.getStatusColor('error')
              : AppTheme.lightTheme.colorScheme.onSurface,
          fontWeight: isLogout ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login-screen',
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.getStatusColor('error'),
              ),
              child: Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
