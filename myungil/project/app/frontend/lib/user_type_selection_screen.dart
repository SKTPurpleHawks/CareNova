import 'package:flutter/material.dart';
import 'foreign_user_signup_screen.dart';
import 'protector_user_signup_screen.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select User Type')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text('간병일감을 찾으시나요?'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForeignUserSignupScreen()),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('간병인을 찾으시나요?'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProtectorUserSignupScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
