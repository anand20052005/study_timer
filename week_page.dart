import 'package:flutter/material.dart';
import 'store.dart';

class WeekPage extends StatelessWidget {
  const WeekPage({super.key, required this.store});
  final StudyStore store;

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final theme = Theme.of(context);
        final primary = theme.colorScheme.primary;
        final week = store.last7Days();
        final goalSec = store.goalMinutes * 60;
        final maxSec = week.fold<int>(goalSec, (m, e) => e.value > m ? e.value : m);
        final total = store.weekTotal;
        final best = week.fold<int>(0, (m, e) => e.value > m ? e.value : m);
        final subjects = store.weekBySubject();
        final subjMax = subjects.isEmpty ? 1 : subjects.first.value;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('Past 7 days', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(fmtHm(total),
                  style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
              Text('studied this week', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white60)),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final e in week)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                e.value == 0 ? '' : fmtHm(e.value),
                                style: const TextStyle(fontSize: 10, color: Colors.white70),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: e.value == 0 ? 4 : 150 * e.value / maxSec,
                                decoration: BoxDecoration(
                                  color: e.value >= goalSec
                                      ? primary
                                      : e.value == 0
                                          ? Colors.white12
                                          : primary.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _days[e.key.weekday - 1],
                                style: TextStyle(
                                  fontWeight: e.key == dayOf(DateTime.now()) ? FontWeight.w800 : FontWeight.w400,
                                  color: e.key == dayOf(DateTime.now()) ? primary : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text('Solid bars hit your ${fmtHm(goalSec)} goal',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38)),
              const SizedBox(height: 24),
              Row(
                children: [
                  _Stat(label: 'Daily avg', value: fmtHm(total ~/ 7)),
                  _Stat(label: 'Best day', value: fmtHm(best)),
                  _Stat(label: 'Streak', value: '${store.streak}d'),
                ],
              ),
              const SizedBox(height: 28),
              Text('By subject', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              if (subjects.isEmpty)
                Text('No sessions yet this week.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white54)),
              for (final s in subjects)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(width: 64, child: Text(s.key)),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: s.value / subjMax,
                            minHeight: 10,
                            color: primary,
                            backgroundColor: Colors.white12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(width: 64, child: Text(fmtHm(s.value), textAlign: TextAlign.end)),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54)),
        ],
      ),
    );
  }
}
