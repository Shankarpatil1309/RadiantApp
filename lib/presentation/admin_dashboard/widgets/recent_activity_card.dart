import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentActivityCard extends StatelessWidget {
  final List<Map<String, dynamic>> activities;
  final VoidCallback? onViewAll;

  const RecentActivityCard({
    Key? key,
    required this.activities,
    this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.getRoleColor('admin'),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                CustomIconWidget(
                  iconName: 'timeline',
                  color: AppTheme.getRoleColor('admin'),
                  size: 24,
                ),
              ],
            ),
            SizedBox(height: 3.h),
            activities.isEmpty
                ? _buildEmptyState()
                : Column(
                    children: [
                      ...activities
                          .take(4)
                          .map((activity) => _buildActivityItem(activity)),
                      if (activities.length > 4) ...[
                        SizedBox(height: 2.h),
                        TextButton(
                          onPressed: onViewAll,
                          child: Text(
                            'View All Activities',
                            style: TextStyle(
                              color: AppTheme.getRoleColor('admin'),
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'history',
            color: Colors.grey.withValues(alpha: 0.5),
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No recent activity',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final activityType = activity['type'] as String;
    final IconData activityIcon = _getActivityIcon(activityType);
    final Color activityColor = _getActivityColor(activityType);

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: activityColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: _getIconName(activityIcon),
              color: activityColor,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] as String,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  activity['description'] as String,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            _formatTime(activity['timestamp'] as DateTime),
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'registration':
        return Icons.person_add;
      case 'attendance':
        return Icons.check_circle;
      case 'assignment':
        return Icons.assignment;
      case 'announcement':
        return Icons.campaign;
      case 'login':
        return Icons.login;
      default:
        return Icons.info;
    }
  }

  String _getIconName(IconData icon) {
    if (icon == Icons.person_add) return 'person_add';
    if (icon == Icons.check_circle) return 'check_circle';
    if (icon == Icons.assignment) return 'assignment';
    if (icon == Icons.campaign) return 'campaign';
    if (icon == Icons.login) return 'login';
    return 'info';
  }

  Color _getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'registration':
        return AppTheme.getRoleColor('student');
      case 'attendance':
        return AppTheme.getStatusColor('success');
      case 'assignment':
        return AppTheme.getRoleColor('faculty');
      case 'announcement':
        return AppTheme.getRoleColor('admin');
      case 'login':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
