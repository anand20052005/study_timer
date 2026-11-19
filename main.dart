import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'activity_page.dart';
import 'record_page.dart';
import 'store.dart';
import 'week_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(StudyApp(store: StudyStore(prefs)));
}

class StudyApp extends StatelessWidget {
  const StudyApp({super.key, required this.store});
  final StudyStore store;

  static const strava = Color(0xFFFC4C02);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: strava,
          brightness: Brightness.dark,
          primary: strava,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: HomeShell(store: store),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.store});
  final StudyStore store;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      RecordPage(store: widget.store),
      WeekPage(store: widget.store),
      ActivityPage(store: widget.store),
    ];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _index, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.timer_outlined), selectedIcon: Icon(Icons.timer), label: 'Record'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Week'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'Activity'),
        ],
      ),
    );
  }
}
