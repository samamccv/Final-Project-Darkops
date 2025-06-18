// lib/widgets/sms_message_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/sms_service.dart';

/// Widget for selecting SMS messages from the device
class SMSMessageSelector extends StatefulWidget {
  final Function(DeviceSMSMessage) onMessageSelected;
  final bool showAsDialog;

  const SMSMessageSelector({
    super.key,
    required this.onMessageSelected,
    this.showAsDialog = true,
  });

  @override
  State<SMSMessageSelector> createState() => _SMSMessageSelectorState();

  /// Show as a modal bottom sheet
  static Future<DeviceSMSMessage?> showBottomSheet(
    BuildContext context, {
    Function(DeviceSMSMessage)? onMessageSelected,
  }) async {
    return await showModalBottomSheet<DeviceSMSMessage>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: SMSMessageSelector(
                    onMessageSelected: (message) {
                      onMessageSelected?.call(message);
                      Navigator.pop(context, message);
                    },
                    showAsDialog: false,
                  ),
                ),
          ),
    );
  }

  /// Show as a full page dialog
  static Future<DeviceSMSMessage?> showDialog(
    BuildContext context, {
    Function(DeviceSMSMessage)? onMessageSelected,
  }) async {
    return await showGeneralDialog<DeviceSMSMessage>(
      context: context,
      pageBuilder:
          (context, animation, secondaryAnimation) => SMSMessageSelector(
            onMessageSelected: (message) {
              onMessageSelected?.call(message);
              Navigator.pop(context, message);
            },
            showAsDialog: true,
          ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: animation.drive(
            Tween(begin: const Offset(0, 1), end: Offset.zero),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

class _SMSMessageSelectorState extends State<SMSMessageSelector> {
  final SMSService _smsService = SMSService();
  final TextEditingController _searchController = TextEditingController();

  List<DeviceSMSMessage> _allMessages = [];
  List<DeviceSMSMessage> _filteredMessages = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedFilter = 'all'; // 'all', 'suspicious', 'recent'

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check permission first
      final hasPermission = await _smsService.hasPermission();
      if (!hasPermission) {
        final permissionStatus = await _smsService.requestPermission();
        if (permissionStatus != PermissionStatus.granted) {
          setState(() {
            _errorMessage = 'SMS permission is required to read messages';
            _isLoading = false;
          });
          return;
        }
      }

      final messages = await _smsService.readAllSMSMessages(limit: 100);
      setState(() {
        _allMessages = messages;
        _filteredMessages = messages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterMessages() {
    List<DeviceSMSMessage> filtered = _allMessages;

    // Apply filter type
    switch (_selectedFilter) {
      case 'suspicious':
        filtered =
            filtered.where((msg) => msg.isPotentiallySuspicious).toList();
        break;
      case 'recent':
        final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
        filtered =
            filtered.where((msg) => msg.date.isAfter(threeDaysAgo)).toList();
        break;
      case 'all':
      default:
        // No additional filtering
        break;
    }

    // Apply search filter
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (msg) =>
                    msg.body.toLowerCase().contains(searchQuery) ||
                    msg.address.toLowerCase().contains(searchQuery),
              )
              .toList();
    }

    setState(() {
      _filteredMessages = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.showAsDialog) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: const Text('Select SMS Message'),
          backgroundColor: colorScheme.surface,
          elevation: 0,
        ),
        body: _buildContent(theme),
      );
    } else {
      return Column(
        children: [
          // Handle bar for bottom sheet
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Select SMS Message',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: _buildContent(theme)),
        ],
      );
    }
  }

  Widget _buildContent(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Search and filter section
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search messages...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                onChanged: (_) => _filterMessages(),
              ),
              const SizedBox(height: 12),
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All Messages', 'all', Icons.sms_outlined),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Suspicious',
                      'suspicious',
                      Icons.warning_outlined,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Recent',
                      'recent',
                      Icons.schedule_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Messages list
        Expanded(child: _buildMessagesList(theme)),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _selectedFilter == value;
    final theme = Theme.of(context);

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 4), Text(label)],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
        _filterMessages();
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: theme.colorScheme.primary,
    );
  }

  Widget _buildMessagesList(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading SMS messages...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Error loading messages',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadMessages,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredMessages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sms_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text('No messages found', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Try adjusting your search or filter'
                  : 'No SMS messages available',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredMessages.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final message = _filteredMessages[index];
        return _buildMessageTile(message, theme, index);
      },
    );
  }

  Widget _buildMessageTile(
    DeviceSMSMessage message,
    ThemeData theme,
    int index,
  ) {
    final colorScheme = theme.colorScheme;
    final isSuspicious = message.isPotentiallySuspicious;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isSuspicious
                    ? Colors.orange.withValues(alpha: 0.1)
                    : colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isSuspicious ? Icons.warning_outlined : Icons.sms_outlined,
            color: isSuspicious ? Colors.orange : colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          message.address,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.bodyPreview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  message.formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                if (isSuspicious) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Suspicious',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => widget.onMessageSelected(message),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms);
  }
}
