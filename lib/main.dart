import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:untracked/application/application.dart';
import 'package:untracked/core/core.dart';
import 'package:untracked/features/features.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(LinkHistoryEntryAdapter());

  // Register timeago locales for non-English languages
  timeago.setLocaleMessages('ar', timeago.ArMessages());
  timeago.setLocaleMessages('fr', timeago.FrMessages());

  runApp(
    const ProviderScope(
      child: AppLifecycleObserver(
        child: App(),
      ),
    ),
  );
}

class AppLifecycleObserver extends StatefulWidget {
  const AppLifecycleObserver({required this.child, super.key});

  final Widget child;

  @override
  State<AppLifecycleObserver> createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppHttpClient.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      AppHttpClient.dispose();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
