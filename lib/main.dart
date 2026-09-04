import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_manager/providers/app_state.dart';
import 'package:wallet_manager/screens/home_screen.dart';
import 'package:wallet_manager/theme/app_theme.dart';

void main() {
  runApp(const WalletManagerApp());
}

class WalletManagerApp extends StatelessWidget {
  const WalletManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => AppState()),
    ],
    child: MaterialApp(
      title: 'Wallet Manager',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    ));
  }
}
