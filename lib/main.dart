// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import 'providers/debt_provider.dart';
import 'screens/home_page.dart';

void main() {
  // Ensure that all widgets are initialized before running the app.
  WidgetsFlutterBinding.ensureInitialized();
  // Set the default locale for date formatting, etc.
  Intl.defaultLocale = 'ar_SA';
  runApp(
    ChangeNotifierProvider(
      create: (context) => DebtProvider(),
      child: const DebtManagerApp(),
    ),
  );
}

class DebtManagerApp extends StatelessWidget {
  const DebtManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مدير الديون',
      // Enable RTL support
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'SA'),
      ],
      // Set the theme with a modern and attractive color scheme
      theme: ThemeData(
        primarySwatch: Colors.teal,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        scaffoldBackgroundColor: Colors.white,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'Almarai', // You can use a custom Arabic font if you add it to pubspec.yaml
            ),
      ),
      home: const HomePage(),
    );
  }
}
