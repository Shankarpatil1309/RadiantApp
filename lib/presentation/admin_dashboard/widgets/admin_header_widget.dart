import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AdminHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> adminData;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  const AdminHeaderWidget({
    Key? key,
    required this.adminData,
    this.onProfileTap,
    this.onNotificationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.getRoleColor('admin'),
            AppTheme.getRoleColor('admin').withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: onProfileTap,
                  child: Container(
                    width: 15.w,
                    height: 15.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: adminData['profileImage'] != null
                          ? CustomImageWidget(
                              imageUrl: adminData['profileImage'] as String,
                              width: 15.w,
                              height: 15.w,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.white.withValues(alpha: 0.2),
                              child: CustomIconWidget(
                                iconName: 'person',
                                color: Colors.white,
                                size: 8.w,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      Text(
                        adminData['name'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${adminData['designation']} • Office ${adminData['officeNumber']}',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onNotificationTap,
                  icon: Stack(
                    children: [
                      CustomIconWidget(
                        iconName: 'notifications',
                        color: Colors.white,
                        size: 24,
                      ),
                      if (adminData['unreadNotifications'] != null &&
                          (adminData['unreadNotifications'] as int) > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.all(1.w),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 4.w,
                              minHeight: 4.w,
                            ),
                            child: Text(
                              (adminData['unreadNotifications'] as int) > 9
                                  ? '9+'
                                  : (adminData['unreadNotifications'] as int)
                                      .toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            _buildInstitutionStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildInstitutionStats() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Departments',
            (adminData['totalDepartments'] as int).toString(),
            'business',
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            'Active Sessions',
            (adminData['activeSessions'] as int).toString(),
            'schedule',
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            'Today\'s Attendance',
            '${adminData['todayAttendance']}%',
            'check_circle',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String iconName) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: Colors.white,
          size: 20,
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 6.h,
      width: 1,
      color: Colors.white.withValues(alpha: 0.3),
    );
  }
}
