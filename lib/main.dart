import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/booking_api_service.dart';
import 'providers/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation_shell.dart';

void main() {
  BookingApiService.authToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoic3R1ZGVudCIsImlhdCI6MTc5NDc2NTQ5MiwiZXhwIjoxNzk0NzY5MDkyLCJzdWIiOiIxIn0.yHB_OAAZ4O1Aeikdv7OtM5f0FOMkjxrNGwx_lNd0rBg';
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style to match the dark theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const SmartVenueApp(),
    ),
  );
}

class SmartVenueApp extends StatelessWidget {
  const SmartVenueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return MaterialApp(
          title: 'Smart Venue IPS & AI Timetable Routing',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: !appState.isLoggedIn
              ? const LoginScreen()
              : const MainNavigationShell(),
        );
      },
    );
  }
}
