import 'package:flutter/material.dart';
import 'features/conversations_page.dart';

void main() {
  runApp(const TudoChatApp());
}

class TudoChatApp extends StatelessWidget {
  const TudoChatApp({super.key});

  // Paleta TUDO TECH
  static const tudoTechYellow = Color(0xFFFFCC00);
  static const carbonBlack = Color(0xFF0F1115);
  static const graphite = Color(0xFF141821);
  static const textPrimary = Color(0xFFE5E7EB);
  static const cyanAccent = Color(0xFF22D3EE);

  static ThemeData theme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: carbonBlack,
      colorScheme: const ColorScheme.dark().copyWith(
        primary: tudoTechYellow,
        secondary: cyanAccent,
        surface: graphite,
        onPrimary: carbonBlack,
        onSurface: textPrimary,
        background: carbonBlack,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: graphite,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: tudoTechYellow,
        foregroundColor: carbonBlack,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1C2230),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF222734)),
      listTileTheme: const ListTileThemeData(iconColor: textPrimary, textColor: textPrimary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TUDO Chat Off-Grid',
      debugShowCheckedModeBanner: false,
      theme: theme(),
      home: const ConversationsPage(),
    );
  }
}
