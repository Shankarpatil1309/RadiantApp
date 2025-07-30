import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class UserStatisticsCard extends StatelessWidget {
  final Map<String, dynamic> statistics;
  final VoidCallback? onTap;

  const UserStatisticsCard({
    Key? key,
    required this.statistics,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'User Statistics',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.getRoleColor('admin'),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'people',
                    color: AppTheme.getRoleColor('admin'),
                    size: 24,
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              _buildStatisticRow(
                'Total Students',
                (statistics['totalStudents'] as int).toString(),
                'school',
              ),
              SizedBox(height: 2.h),
              _buildStatisticRow(
                'Total Faculty',
                (statistics['totalFaculty'] as int).toString(),
                'person',
              ),
              SizedBox(height: 2.h),
              _buildStatisticRow(
                'Active Users',
                (statistics['activeUsers'] as int).toString(),
                'verified_user',
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/add-student');
                      },
                      icon: CustomIconWidget(
                        iconName: 'person_add',
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        'Add Student',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.getRoleColor('student'),
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/add-faculty');
                      },
                      icon: CustomIconWidget(
                        iconName: 'person_add',
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        'Add Faculty',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.getRoleColor('faculty'),
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticRow(String label, String value, String iconName) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: AppTheme.getRoleColor('admin').withValues(alpha: 0.7),
          size: 20,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.getRoleColor('admin'),
          ),
        ),
      ],
    );
  }
}
