import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'providers/app_provider.dart';
import 'router.dart';

class ScholarSetuApp extends StatefulWidget {
  const ScholarSetuApp({super.key});

  @override
  State<ScholarSetuApp> createState() => _ScholarSetuAppState();
}

class _ScholarSetuAppState extends State<ScholarSetuApp> {
  late final _router;

  @override
  void initState() {
    super.initState();
    final appProvider = context.read<AppProvider>();
    _router = AppRouter.createRouter(appProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ScholarSetu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}
