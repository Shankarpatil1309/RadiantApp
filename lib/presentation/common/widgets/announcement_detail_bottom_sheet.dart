import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AnnouncementDetailBottomSheet extends StatelessWidget {
  final Map<String, dynamic> announcement;
  final VoidCallback? onClose;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const AnnouncementDetailBottomSheet({
    Key? key,
    required this.announcement,
    this.onClose,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(top: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with priority and close button
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(
                              announcement['priority'] as String? ?? 'normal'),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (announcement['priority'] as String? ?? 'normal')
                              .toUpperCase(),
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (showActions) ...[
                        if (onEdit != null)
                          IconButton(
                            onPressed: onEdit,
                            icon: CustomIconWidget(
                              iconName: 'edit',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 24,
                            ),
                          ),
                        if (onDelete != null)
                          IconButton(
                            onPressed: onDelete,
                            icon: CustomIconWidget(
                              iconName: 'delete',
                              color: AppTheme.getStatusColor('error'),
                              size: 24,
                            ),
                          ),
                      ],
                      IconButton(
                        onPressed: onClose ?? () => Navigator.pop(context),
                        icon: CustomIconWidget(
                          iconName: 'close',
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  
                  // Title
                  Text(
                    announcement['title'] as String? ?? 'No Title',
                    style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        announcement['content'] as String? ?? 
                        announcement['message'] as String? ?? 'No content',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  
                  // Footer with author and timestamp
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'person',
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        announcement['author'] as String? ?? 
                        announcement['createdBy'] as String? ?? 'Unknown',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Text(
                        _formatTimestamp(announcement),
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return AppTheme.lightTheme.colorScheme.error;
      case 'important':
        return const Color(0xFFFF9800);
      case 'normal':
      default:
        return AppTheme.lightTheme.primaryColor;
    }
  }

  String _formatTimestamp(Map<String, dynamic> announcement) {
    try {
      DateTime? dateTime;
      
      // Try different timestamp formats
      if (announcement['timestamp'] != null) {
        dateTime = DateTime.parse(announcement['timestamp'] as String);
      } else if (announcement['createdAt'] != null) {
        final createdAt = announcement['createdAt'];
        if (createdAt is DateTime) {
          dateTime = createdAt;
        } else if (createdAt is String) {
          dateTime = DateTime.parse(createdAt);
        }
      } else if (announcement['timeAgo'] != null) {
        return announcement['timeAgo'] as String;
      }
      
      if (dateTime != null) {
        final now = DateTime.now();
        final difference = now.difference(dateTime);
        
        if (difference.inDays > 0) {
          return '${difference.inDays}d ago';
        } else if (difference.inHours > 0) {
          return '${difference.inHours}h ago';
        } else if (difference.inMinutes > 0) {
          return '${difference.inMinutes}m ago';
        } else {
          return 'Just now';
        }
      }
      
      return 'Unknown time';
    } catch (e) {
      return 'Unknown time';
    }
  }
}