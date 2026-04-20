import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routing/app_router.dart';
import 'core/app_theme.dart';
import 'core/localization/app_strings.dart';
import 'core/app_state.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final appState = AppState();
  await appState.loadSettings();

  GoogleFonts.config.allowRuntimeFetching = true;

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const AngioLensApp(),
    ),
  );
}

class AngioLensApp extends StatelessWidget {
  const AngioLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return MaterialApp.router(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          locale: Locale(appState.locale),
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
