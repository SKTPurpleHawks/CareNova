import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


/*
------------------------------------------------------------------------------------------------------
file_name : main.dart

Developer
 ● Frontend : 최명일, 서민석
 ● UI/UX : 서민석                                                     
                                                                  
description : 어플 실행시 첫 화면 지정 및 스타일 테마 설정 화면
------------------------------------------------------------------------------------------------------
*/


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: "assets/.env");
    print(".env 파일 로드 성공");
  } catch (e) {
    print(".env 파일 로드 실패: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.notoSansKrTextTheme(),

        scaffoldBackgroundColor: Color(0xFFFFFFFF), // 전체 화면 배경색
        fontFamily: 'NanumSquareNeobRg', // 앱 전체 기본 글꼴
        // textTheme: TextTheme(
        //   bodyLarge: TextStyle(
        //       fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        //   bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        //   bodySmall: TextStyle(fontSize: 14, color: Colors.black54),
        // ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, // 버튼 배경색
            foregroundColor: Colors.black, // 버튼 글씨색
            padding: EdgeInsets.symmetric(horizontal: 100, vertical: 5),
            textStyle: TextStyle(fontSize: 18),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontFamily: 'NanumSquareNeodEb',
          ),
        ),
      ),
      home: LoginScreen(),
    );
  }
}
