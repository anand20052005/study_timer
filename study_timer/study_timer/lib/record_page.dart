import 'dart:async';
import 'package:flutter/material.dart';
import 'store.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key, required this.store});
  final StudyStore store;

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (widget.store.isRunning && mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _editGoal() async {
    final store = widget.store;
    var value = store.goalMinutes.toDouble();
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Daily goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(fmtHm(value.round() * 60),
                  style: Theme.of(ctx).textTheme.headlineSmall),
              Slider(
                min: 30,
                max: 720,
                divisions: 46,
                value: value,
                onChanged: (v) => setLocal(() => value = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, value.round()), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (result != null) store.setGoal(result);
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final theme = Theme.of(context);
        final primary = theme.colorScheme.primary;
        final goalSec = store.goalMinutes * 60;
        final today = store.todaySeconds;
        final progress = (today / goalSec).clamp(0.0, 1.0);
        final status = store.isRunning
            ? 'Studying ${store.subject}'
            : store.isActive
                ? 'Paused'
                : 'Ready';

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('Study Timer', style: TextStyle(fontWeight: FontWeight.w700)),
            actions: [
              IconButton(
                tooltip: 'Daily goal',
                icon: const Icon(Icons.flag_outlined),
                onPressed: _editGoal,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final s in store.subjects)
                      ChoiceChip(
                        label: Text(s),
                        selected: store.subject == s,
                        onSelected: store.isActive ? null : (_) => store.setSubject(s),
                      ),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 270,
                  height: 270,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 12,
                          color: primary,
                          backgroundColor: Colors.white12,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            fmtHms(store.elapsedSeconds),
                            style: const TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.w300,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(status, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white60)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Today  ${fmtHm(today)}  /  ${fmtHm(goalSec)}',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  store.streak > 0 ? '${store.streak}-day streak' : 'Start a streak today',
                  style: theme.textTheme.bodyMedium?.copyWith(color: primary),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (store.isActive) ...[
                      OutlinedButton.icon(
                        onPressed: () {
                          final saved = store.finish();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(saved > 0
                                ? 'Saved ${fmtHm(saved)} session. Today: ${fmtHm(store.todaySeconds)}'
                                : 'Session too short to save'),
                          ));
                        },
                        icon: const Icon(Icons.stop),
                        label: const Text('Finish'),
                        style: OutlinedButton.styleFrom(minimumSize: const Size(130, 54)),
                      ),
                      const SizedBox(width: 16),
                    ],
                    FilledButton.icon(
                      onPressed: store.isRunning ? store.pause : store.start,
                      icon: Icon(store.isRunning ? Icons.pause : Icons.play_arrow),
                      label: Text(store.isRunning ? 'Pause' : store.isActive ? 'Resume' : 'Start'),
                      style: FilledButton.styleFrom(minimumSize: const Size(150, 54)),
                    ),
                  ],
                ),
                if (store.isActive)
                  TextButton(
                    onPressed: store.discard,
                    child: const Text('Discard session'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
