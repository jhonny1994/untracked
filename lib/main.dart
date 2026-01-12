import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:untracked/app/app_exports.dart';
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

  // Configure global error widget for production graceful error handling
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Builder(
      builder: (context) {
        // Try to get theme, fallback to defaults if not available
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        return Material(
          child: Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.all(AppDesign.paddingScreen),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: AppDesign.iconXLarge,
                    color: colorScheme.error,
                  ),
                  const Gap(AppDesign.spaceMedium),
                  Text(
                    'Something went wrong',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  };

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
