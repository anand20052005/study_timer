import 'package:flutter/material.dart';
import 'store.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key, required this.store});
  final StudyStore store;

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  String _when(DateTime d) {
    final today = dayOf(DateTime.now());
    final day = dayOf(d);
    final label = day == today
        ? 'Today'
        : day == today.subtract(const Duration(days: 1))
            ? 'Yesterday'
            : '${d.day} ${_months[d.month - 1]}';
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '$label, $h:$m ${d.hour < 12 ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final sessions = store.sessions;
        final primary = Theme.of(context).colorScheme.primary;
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('Activity', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          body: sessions.isEmpty
              ? const Center(child: Text('No sessions yet. Hit Start on the Record tab.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: sessions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final s = sessions[i];
                    return Dismissible(
                      key: ValueKey(s.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.delete),
                      ),
                      onDismissed: (_) => store.deleteSession(s.id),
                      child: Card(
                        color: const Color(0xFF1E1E1E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: primary.withValues(alpha: 0.2),
                            child: Icon(Icons.menu_book, color: primary),
                          ),
                          title: Text(s.subject, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(_when(s.start)),
                          trailing: Text(
                            s.seconds < 60 ? '<1m' : fmtHm(s.seconds),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
