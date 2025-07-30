import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickManagementCard extends StatelessWidget {
  final VoidCallback? onAddStudent;
  final VoidCallback? onAddFaculty;
  final VoidCallback? onCreateAnnouncement;
  final VoidCallback? onViewReports;

  const QuickManagementCard({
    Key? key,
    this.onAddStudent,
    this.onAddFaculty,
    this.onCreateAnnouncement,
    this.onViewReports,
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
                  'Quick Management',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.getRoleColor('admin'),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                CustomIconWidget(
                  iconName: 'dashboard',
                  color: AppTheme.getRoleColor('admin'),
                  size: 24,
                ),
              ],
            ),
            SizedBox(height: 3.h),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 1.2,
              children: [
                _buildQuickActionTile(
                  'Add Student',
                  'person_add',
                  AppTheme.getRoleColor('student'),
                  onAddStudent,
                ),
                _buildQuickActionTile(
                  'Add Faculty',
                  'person_add',
                  AppTheme.getRoleColor('faculty'),
                  onAddFaculty,
                ),
                _buildQuickActionTile(
                  'Announcement',
                  'campaign',
                  AppTheme.getRoleColor('admin'),
                  onCreateAnnouncement,
                ),
                _buildQuickActionTile(
                  'View Reports',
                  'assessment',
                  Colors.purple,
                  onViewReports,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionTile(
    String title,
    String iconName,
    Color color,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: color,
                size: 28,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
