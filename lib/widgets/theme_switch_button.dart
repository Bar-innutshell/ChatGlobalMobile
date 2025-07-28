import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class ThemeSwitchButton extends StatelessWidget {
  const ThemeSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return IconButton(
      icon: Icon(themeNotifier.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
      tooltip: 'Switch Theme',
      onPressed: () => themeNotifier.toggleTheme(),
    );
  }
}
