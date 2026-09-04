import 'package:flutter/material.dart';
import 'package:wallet_manager/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        title: const Text('Wallet Manager'),
        actions: [
          IconButton(
              onPressed: (){},
              icon: const Icon(Icons.calendar_month_outlined)
          ),
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryNavy,
            child: Icon(
              Icons.person,
              size: 16,
              color: Colors.white
            ),
          )
        ]
      ),
      body: const Center(
        child: Text("Home Screen"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(
            Icons.add,
            color: Colors.white),
      ),
    );
  }
}