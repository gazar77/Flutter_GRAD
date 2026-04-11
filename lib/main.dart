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
  await appState.loadProfileImage();

  GoogleFonts.config.allowRuntimeFetching = false;

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
          darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
            primaryColor: const Color(0xFF2B4F7A),
            scaffoldBackgroundColor: const Color(0xFF121212),
          ),
          themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
