import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/app_notification.dart';
import '../../core/services/providers.dart';

const _typeIcons = {
  NotificationType.absence: Icons.event_busy,
  NotificationType.grade: Icons.grade_outlined,
  NotificationType.payment: Icons.payments_outlined,
  NotificationType.announcement: Icons.campaign_outlined,
};

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasyon')),
      body: StreamBuilder<List<AppNotification>>(
        stream: ref.watch(firestoreServiceProvider).watchNotifications(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final notifications = snapshot.data!;
          if (notifications.isEmpty) {
            return const Center(child: Text('Pa gen notifikasyon.'));
          }
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, i) {
              final n = notifications[i];
              return ListTile(
                leading: Icon(_typeIcons[n.type] ?? Icons.notifications_outlined),
                title: Text(n.title, style: TextStyle(fontWeight: n.seen ? FontWeight.normal : FontWeight.bold)),
                subtitle: Text(n.body),
                trailing: n.createdAt != null ? Text(dateFormat.format(n.createdAt!)) : null,
                tileColor: n.seen ? null : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                onTap: n.seen
                    ? null
                    : () => ref.read(firestoreServiceProvider).markNotificationSeen(n.id),
              );
            },
          );
        },
      ),
    );
  }
}
