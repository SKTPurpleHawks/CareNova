import 'package:flutter/material.dart';

class ProtectorUserHomeScreen extends StatelessWidget {
  final String token;

  const ProtectorUserHomeScreen({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("보호자 홈 화면"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // 로그아웃 → 로그인 화면으로 이동
              Navigator.pushReplacementNamed(context, "/");
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          "우홬황랔화홬ㅋㅋㅋ 로그인성공이닼ㅋㅋㅋ(보호자)",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
