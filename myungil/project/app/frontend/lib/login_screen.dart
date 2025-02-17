import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_type_selection_screen.dart';
import 'package:app/protector_home_screen.dart';
import 'package:app/foreign_home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final String baseUrl = "http://172.23.250.30:8000"; // FastAPI 서버 IP 사용
    final String url = "$baseUrl/login";
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final token = responseData['access_token'];
      final userType = responseData['user_type'];

      // 사용자 유형에 따라 다른 화면으로 이동
      if (userType == 'foreign') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ForeignHomeScreen(token: token)),
        );
      } else if (userType == 'protector') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ProtectorUserHomeScreen(token: token)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인에 실패하였습니다. 다시 입력해 주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(title: Text('로그인')),
      body: SingleChildScrollView( 
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, 
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('assets/images/carenova2.png', width: 120, height: 120),
              ),
              SizedBox(height: 80),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: '이메일'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: '비밀번호'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              TextButton(
                child: Text('로그인', style: Theme.of(context).textTheme.bodyMedium),
                onPressed: _login,
              ),
              SizedBox(height: 10),
              TextButton(
                child: Text('회원가입', style: Theme.of(context).textTheme.bodyMedium),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserTypeSelectionScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }


}
