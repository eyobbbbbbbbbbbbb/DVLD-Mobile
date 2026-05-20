import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/services/theme_service.dart';
import 'features/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'core/providers/notification_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    runApp(const DVLDApp());
  } catch (e) {
    debugPrint('Fatal error in main: $e');
  }
}

class DVLDApp extends StatelessWidget {
  const DVLDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationProvider(),
      child: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          // Defer polling until after first build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.startPolling();
          });
          
          return ValueListenableBuilder<bool>(
            valueListenable: ThemeService.instance.isDarkModeNotifier,
            builder: (_, isDark, __) {
              return MaterialApp(
                title: 'DVLD — Driving License Department',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                home: const LoginScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
