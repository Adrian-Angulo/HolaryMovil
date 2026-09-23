import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/app_constants.dart';
import 'core/storage/session_storage.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/dependency_injection.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar almacenamiento de sesión
  final sessionStorage = await SessionStorage.create();

  // Inicializar localización para formatos de fecha en español
  await initializeDateFormatting('es_ES', null);

  runApp(
    ProviderScope(
      overrides: [
        sessionStorageProvider.overrideWithValue(sessionStorage),
      ],
      child: const PractiHorasApp(),
    ),
  );
}

class PractiHorasApp extends ConsumerWidget {
  const PractiHorasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('es'),
        Locale('en', 'US'),
      ],
      locale: const Locale('es', 'ES'),
      home: const SplashScreen(),
    );
  }
}
