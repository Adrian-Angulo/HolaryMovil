import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/local_storage_datasource.dart';
import 'presentation/screens/home_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar almacenamiento local Hive 100% offline
  await LocalStorageDataSource.init();

  // Inicializar localización para formatos de fecha en español
  await initializeDateFormatting('es', null);

  runApp(
    const ProviderScope(
      child: PractiHorasApp(),
    ),
  );
}

class PractiHorasApp extends StatelessWidget {
  const PractiHorasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeNavigationScreen(),
    );
  }
}
