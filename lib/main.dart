import 'package:flutter/material.dart';
import 'core/routing/app_router.dart';

void main() {
  runApp(const AngioLensApp());
}

class AngioLensApp extends StatelessWidget {
  const AngioLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}
