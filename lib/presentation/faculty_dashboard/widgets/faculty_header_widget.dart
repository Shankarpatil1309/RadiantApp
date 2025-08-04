import 'package:flutter/material.dart';
import 'package:radiant_app/models/faculty_model.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FacultyHeaderWidget extends StatelessWidget {
  final Faculty facultyData;
  final Function() onProfileTap;
  final Function() onNotificationTap;
  final Function() onLogoutTap;

  const FacultyHeaderWidget({
    Key? key,
    required this.facultyData,
    required this.onProfileTap,
    required this.onNotificationTap,
    required this.onLogoutTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 2.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: onProfileTap,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.getRoleColor('faculty'),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: facultyData.profileImage != null
                          ? CustomImageWidget(
                              imageUrl: facultyData.profileImage!,
                              width: 12.w,
                              height: 12.w,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: AppTheme.getRoleColor('faculty')
                                  .withValues(alpha: 0.1),
                              child: CustomIconWidget(
                                iconName: 'person',
                                color: AppTheme.getRoleColor('faculty'),
                                size: 24,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back,",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                      ),
                      Text(
                        facultyData.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.getRoleColor('faculty'),
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "ID: ${facultyData.employeeId} • ${facultyData.department}",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onNotificationTap,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        CustomIconWidget(
                          iconName: 'notifications',
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                          size: 24,
                        ),
                        if (false) // TODO: Add unread notifications to Faculty model
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: EdgeInsets.all(1.w),
                              decoration: BoxDecoration(
                                color: AppTheme.getStatusColor('error'),
                                shape: BoxShape.circle,
                              ),
                              constraints: BoxConstraints(
                                minWidth: 4.w,
                                minHeight: 4.w,
                              ),
                              child: Text(
                                0 // TODO: Add unread notifications count
                                    .toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontSize: 8.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                GestureDetector(
                  onTap: onLogoutTap,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .errorContainer
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'logout',
                      color: Theme.of(context).colorScheme.error,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
