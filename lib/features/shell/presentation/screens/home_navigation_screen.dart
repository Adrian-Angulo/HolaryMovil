import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../perfil/presentation/screens/perfil_config_screen.dart';
import '../../../registros/presentation/screens/historial_screen.dart';
import '../../../registros/presentation/screens/nuevo_registro_screen.dart';
import '../widgets/atoms/app_bottom_nav_bar.dart';

class HomeNavigationScreen extends ConsumerStatefulWidget {
  const HomeNavigationScreen({super.key});

  @override
  ConsumerState<HomeNavigationScreen> createState() => _HomeNavigationScreenState();
}

class _HomeNavigationScreenState extends ConsumerState<HomeNavigationScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(
        onNavigateToRegistrar: () => _onTabSelected(1),
        onNavigateToHistorial: () => _onTabSelected(2),
        onNavigateToAjustes: () => _onTabSelected(3),
      ),
      NuevoRegistroScreen(
        onRegistroGuardado: () => _onTabSelected(0),
      ),
      HistorialScreen(
        onEditRegistro: (_) => _onTabSelected(1),
      ),
      const PerfilConfigScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
