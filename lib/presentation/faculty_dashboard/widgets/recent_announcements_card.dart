import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentAnnouncementsCard extends StatelessWidget {
  final List<Map<String, dynamic>> announcements;
  final Function(Map<String, dynamic>) onAnnouncementTap;
  final Function(Map<String, dynamic>) onAnnouncementLongPress;

  const RecentAnnouncementsCard({
    Key? key,
    required this.announcements,
    required this.onAnnouncementTap,
    required this.onAnnouncementLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'campaign',
                  color: AppTheme.getRoleColor('faculty'),
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  "Recent Announcements",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getRoleColor('faculty'),
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Feature coming soon'),
                      backgroundColor: AppTheme.getStatusColor('warning'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  ),
                  // Navigator.pushNamed(context, '/announcements-screen'),
                  child: Text(
                    "View All",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.getRoleColor('faculty'),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            announcements.isEmpty
                ? _buildEmptyState(context)
                : Column(
                    children: announcements
                        .take(3)
                        .map((announcement) =>
                            _buildAnnouncementItem(context, announcement))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'notifications_none',
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            size: 48,
          ),
          SizedBox(height: 1.h),
          Text(
            "No recent announcements",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementItem(
      BuildContext context, Map<String, dynamic> announcement) {
    return GestureDetector(
      onTap: () => onAnnouncementTap(announcement),
      onLongPress: () => onAnnouncementLongPress(announcement),
      child: Container(
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: _getPriorityColor(announcement["priority"] as String)
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getPriorityColor(announcement["priority"] as String)
                .withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color:
                        _getPriorityColor(announcement["priority"] as String),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    (announcement["priority"] as String).toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 10.sp,
                        ),
                  ),
                ),
                const Spacer(),
                Text(
                  announcement["timeAgo"] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              announcement["title"] as String,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 0.5.h),
            Text(
              announcement["content"] as String,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 1.h),
            // Row(
            //   children: [
            //     CustomIconWidget(
            //       iconName: 'visibility',
            //       color: Theme.of(context)
            //           .colorScheme
            //           .onSurface
            //           .withValues(alpha: 0.6),
            //       size: 16,
            //     ),
            //     SizedBox(width: 1.w),
            //     Text(
            //       "${announcement["views"]} views",
            //       style: Theme.of(context).textTheme.bodySmall,
            //     ),
            //     SizedBox(width: 3.w),
            //     CustomIconWidget(
            //       iconName: 'thumb_up',
            //       color: Theme.of(context)
            //           .colorScheme
            //           .onSurface
            //           .withValues(alpha: 0.6),
            //       size: 16,
            //     ),
            //     SizedBox(width: 1.w),
            //     Text(
            //       "${announcement["likes"]} likes",
            //       style: Theme.of(context).textTheme.bodySmall,
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return AppTheme.getRoleColor('admin');
      case 'important':
        return AppTheme.warningLight;
      default:
        return AppTheme.getRoleColor('faculty');
    }
  }
}
