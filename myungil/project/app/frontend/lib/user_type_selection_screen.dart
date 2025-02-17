import 'package:flutter/material.dart';
import 'foreign_user_signup_screen.dart';
import 'protector_user_signup_screen.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // 상단 이미지 추가
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset('assets/images/carenova2.png', width: 125, height: 125), // 이미지 크기 조절 가능
          ),
          SizedBox(height: 55),
          ElevatedButton(
            child: Text(
              '간병일감을 찾으시나요?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ForeignUserSignupScreen()),
              );
            },
          ),
          SizedBox(height: 30),


          ElevatedButton(
            child: Text(
              '간병인을 찾으시나요?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProtectorUserSignupScreen()),
              );
            },
          ),
          SizedBox(height: 80),
        ],
      ),
      ),
    );
  }
}
