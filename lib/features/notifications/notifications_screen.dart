import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api/models/message.dart';
import '../../core/api/services/message_service.dart';
import '../../core/services/user_session.dart';
import '../../core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = true;
  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final messages = await MessageService.getMessages(UserSession.instance.personId);
    if (mounted) {
      setState(() {
        _messages = messages;
        _loading = false;
      });
    }
  }

  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'test':
        return Icons.event_available_rounded;
      case 'status':
        return Icons.info_outline_rounded;
      case 'chat':
        return Icons.chat_bubble_outline_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _getColor(String type) {
    switch (type.toLowerCase()) {
      case 'test':
        return AppColors.accent;
      case 'status':
        return AppColors.primary;
      case 'chat':
        return Colors.green;
      default:
        return AppColors.textLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadMessages,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _messages.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadMessages,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _buildMessageCard(msg);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: AppColors.textLight.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you here when there\'s an update.',
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(Message msg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: msg.isRead ? null : Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (!msg.isRead) {
            MessageService.markAsRead(msg.id);
            setState(() {
              // Local update for immediate feedback
              final idx = _messages.indexWhere((m) => m.id == msg.id);
              if (idx != -1) {
                _messages[idx] = Message(
                  id: msg.id,
                  personId: msg.personId,
                  senderId: msg.senderId,
                  title: msg.title,
                  content: msg.content,
                  isRead: true,
                  createdAt: msg.createdAt,
                  messageType: msg.messageType,
                );
              }
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getColor(msg.messageType).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(msg.messageType),
                  color: _getColor(msg.messageType),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            msg.title,
                            style: GoogleFonts.poppins(
                              fontWeight: msg.isRead ? FontWeight.w500 : FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!msg.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      msg.content,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(msg.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
