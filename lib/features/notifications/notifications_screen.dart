import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Vision Test Passed',
      'body': 'Congratulations! You passed your vision test. Written theory exam is scheduled for Apr 10.',
      'time': '2 hours ago',
      'icon': Icons.check_circle_rounded,
      'color': AppColors.success,
      'bg': AppColors.successLight,
      'isRead': false,
    },
    {
      'title': 'Exam Reminder',
      'body': 'Your Written Theory Exam is tomorrow at 10:00 AM. Please arrive 15 minutes early.',
      'time': '5 hours ago',
      'icon': Icons.notifications_active_rounded,
      'color': AppColors.warning,
      'bg': AppColors.warningLight,
      'isRead': false,
    },
    {
      'title': 'Fee Payment Confirmed',
      'body': 'Your payment of ETB 10.00 for application APP-2026-0041 has been received.',
      'time': 'Yesterday',
      'icon': Icons.payment_rounded,
      'color': AppColors.primary,
      'bg': AppColors.accentLight,
      'isRead': true,
    },
    {
      'title': 'Application Submitted',
      'body': 'Your application for a New License (Class B) has been submitted and is under review.',
      'time': '3 days ago',
      'icon': Icons.assignment_turned_in_rounded,
      'color': AppColors.info,
      'bg': AppColors.infoLight,
      'isRead': true,
    },
    {
      'title': 'Document Verified',
      'body': 'Your national ID and medical certificate have been verified successfully.',
      'time': '3 days ago',
      'icon': Icons.verified_rounded,
      'color': AppColors.success,
      'bg': AppColors.successLight,
      'isRead': true,
    },
    {
      'title': 'License Renewal Approved',
      'body': 'Your license renewal application has been approved. Visit any branch to collect.',
      'time': '3 weeks ago',
      'icon': Icons.autorenew_rounded,
      'color': AppColors.success,
      'bg': AppColors.successLight,
      'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => !n['isRead']).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Notifications',
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var n in _notifications) {
                  n['isRead'] = true;
                }
              });
            },
            child: Text('Mark all read',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
      body: Column(
        children: [
          if (unread > 0)
            Container(
              width: double.infinity,
              color: AppColors.accentLight,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                '$unread unread notification${unread > 1 ? 's' : ''}',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500),
              ),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final n = _notifications[i];
                return GestureDetector(
                  onTap: () => setState(() => n['isRead'] = true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: n['isRead'] ? AppColors.white : AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: n['isRead']
                            ? AppColors.divider
                            : (n['color'] as Color).withOpacity(0.3),
                        width: n['isRead'] ? 1 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: n['bg'] as Color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(n['icon'] as IconData,
                              color: n['color'] as Color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(n['title'] as String,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: n['isRead']
                                              ? FontWeight.w500
                                              : FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        )),
                                  ),
                                  if (!n['isRead'])
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.accent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(n['body'] as String,
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      height: 1.5)),
                              const SizedBox(height: 8),
                              Text(n['time'] as String,
                                  style: GoogleFonts.poppins(
                                      fontSize: 11, color: AppColors.textLight)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
