import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untracked/application/router.dart';
import 'package:untracked/application/theme.dart';
import 'package:untracked/core/l10n/generated/l10n.dart';

/// The main application widget.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp.router(
          title: 'UNTRACED',
          debugShowCheckedModeBanner: false,

          // Theme
          theme: AppTheme.light(lightDynamic),
          darkTheme: AppTheme.dark(darkDynamic),

          // Localization
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,

          // Router
          routerConfig: router,
        );
      },
    );
  }
}
