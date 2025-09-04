// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/call_record.dart';

class RecentCallsWidget extends StatefulWidget {
  const RecentCallsWidget({super.key});

  @override
  State<RecentCallsWidget> createState() => _RecentCallsWidgetState();
}

class _RecentCallsWidgetState extends State<RecentCallsWidget> {
  List<CallRecord> _recentCalls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentCalls();
  }

  Future<void> _loadRecentCalls() async {
    try {
      final calls = await DatabaseService().getCallHistory();
      setState(() {
        _recentCalls = calls.take(5).toList(); // Show only last 5 calls
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Add some demo data for now
      _addDemoData();
    }
  }

  void _addDemoData() {
    setState(() {
      _recentCalls = [
        CallRecord(
          participants: ['Ahmad', 'You'],
          startTime: DateTime.now().subtract(const Duration(hours: 2)),
          endTime: DateTime.now().subtract(
            const Duration(hours: 1, minutes: 45),
          ),
          duration: const Duration(minutes: 15),
          aiSummary: 'Discussed project requirements and timeline',
          callType: 'video',
        ),
        CallRecord(
          participants: ['Sarah', 'You'],
          startTime: DateTime.now().subtract(const Duration(days: 1)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 1))
              .add(const Duration(minutes: 30)),
          duration: const Duration(minutes: 30),
          aiSummary: 'Team meeting about AI integration features',
          callType: 'video',
        ),
        CallRecord(
          participants: ['Ali', 'You'],
          startTime: DateTime.now().subtract(const Duration(days: 2)),
          endTime: DateTime.now()
              .subtract(const Duration(days: 2))
              .add(const Duration(minutes: 10)),
          duration: const Duration(minutes: 10),
          aiSummary: 'Quick catch-up call about design updates',
          callType: 'audio',
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recentCalls.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.call,
              size: 48,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No recent calls',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Start your first AI-powered call!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _recentCalls.map((call) => _buildCallTile(call)).toList(),
    );
  }

  Widget _buildCallTile(CallRecord call) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Call type icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: call.callType == 'video'
                  ? Colors.green.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              call.callType == 'video' ? Icons.videocam : Icons.call,
              color: call.callType == 'video' ? Colors.green : Colors.blue,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // Call details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  call.participants.where((p) => p != 'You').join(', '),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM dd, hh:mm a').format(call.startTime),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
                if (call.aiSummary != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    call.aiSummary!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Duration
          if (call.duration != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${call.duration!.inMinutes}m',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),

          const SizedBox(width: 8),

          // Call again button
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/video-call');
            },
            icon: const Icon(Icons.call),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
