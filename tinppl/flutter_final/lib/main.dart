import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prac11/Caregiver/caregiver_edit_profile_screen.dart' as edit;
import 'package:prac11/Caregiver/caregiver_profile_screen.dart' as profile;

import 'login/language_screen.dart';
import 'login/caregiver_search.dart';
import 'login/login_screen.dart';
import 'login/caregiver_signup.dart';
import 'login/guardian_signup.dart';
import 'guardian/guardian_patient_selection_screen.dart';
import 'guardian/guardian_patient_list_screen.dart';
import 'guardian/guardian_patient_detail_screen.dart';
import 'guardian/guardian_patient_register_screen.dart';
import 'guardian/caregiver_log_screen.dart';
import 'guardian/caregiver_list_screen2.dart'; // ✅ CaregiverListScreen2 추가
import 'Caregiver/caregiver_patient_list_screen.dart';
import 'Caregiver/caregiver_patient_logs_screen.dart';
import 'Caregiver/caregiver_patient_log_detail_screen.dart';
import 'Caregiver/caregiver_patient_log_create_screen.dart';
import 'Caregiver/caregiver_patient_info_screen.dart';
import 'Caregiver/caregiver_patient_detail_screen.dart';
import 'recorder_screen.dart'; // ✅ RecorderScreen 추가

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SBJNMCCARE',
      theme: ThemeData(
        textTheme: GoogleFonts.notoSansKrTextTheme(), // 🔹 앱 전체에 적용
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/caregiver_patient_logs':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (context) => CaregiverPatientLogsScreen(
                  patientName: args['patientName'] ?? "환자 1"),
            );

          case '/caregiver_patient_info':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (context) =>
                  CaregiverPatientInfoScreen(patientData: args),
            );

          case '/caregiver_edit_profile':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (context) =>
                  edit.CaregiverEditProfileScreen(userData: args),
            );

          case '/caregiver_patient_detail':
            final args = settings.arguments as String? ?? "환자";
            return MaterialPageRoute(
              builder: (context) =>
                  CaregiverPatientDetailScreen(patientName: args),
            );

          case '/caregiver_patient_log_create':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            final patientName = args['patientName'] as String? ?? "환자";
            return MaterialPageRoute(
              builder: (context) =>
                  CaregiverPatientLogCreateScreen(patientName: patientName),
            );

          case '/caregiver_list': // ✅ CaregiverListScreen2와 연결
            final args = settings.arguments as String? ?? "환자";
            return MaterialPageRoute(
              builder: (context) => CaregiverListScreen2(patientName: args),
            );

          case '/recorder_screen': // ✅ RecorderScreen 추가
            return MaterialPageRoute(
              builder: (context) => const RecorderScreen(),
            );

          default:
            return MaterialPageRoute(
              builder: (context) => const LanguageScreen(),
            );
        }
      },
      routes: {
        '/language': (context) => const LanguageScreen(),
        '/caregiver_search': (context) => const CaregiverSearchScreen(),
        '/login_caregiver': (context) =>
            const LoginScreen(userType: 'caregiver'),
        '/login_guardian': (context) => const LoginScreen(userType: 'guardian'),
        '/caregiver_signup': (context) => const CaregiverSignupScreen(),
        '/guardian_signup': (context) => const GuardianSignupScreen(),
        '/guardian_patient_selection': (context) =>
            const GuardianPatientSelectionScreen(),
        '/guardian_patient_list': (context) =>
            const GuardianPatientListScreen(),
        '/guardian_patient_detail': (context) =>
            const GuardianPatientDetailScreen(),
        '/guardian_patient_register': (context) =>
            const GuardianPatientRegisterScreen(),
        '/caregiver_log': (context) => const CaregiverLogScreen(),
        '/caregiver_profile': (context) =>
            const profile.CaregiverProfileScreen(),
        '/caregiver_patient_list': (context) =>
            const CaregiverPatientListScreen(),
        '/caregiver_patient_log_detail': (context) =>
            const CaregiverPatientLogDetailScreen(),
        '/recorder_screen': (context) => const RecorderScreen(), // ✅ 추가된 화면 이동
      },
    );
  }
}
