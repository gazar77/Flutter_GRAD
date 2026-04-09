import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fp/pages/auth/signup_page.dart';
import 'package:fp/pages/auth/verify_code_page.dart';
import 'package:fp/pages/auth/forget_password_page.dart';
import 'package:fp/pages/auth/create_new_password_page.dart';
import 'package:fp/pages/patient/add_patient_page.dart';
import 'package:fp/pages/home/home_page.dart';
import 'package:fp/pages/analysis/upload_page.dart';
import 'package:fp/pages/analysis/processing_page.dart';
import 'package:fp/pages/analysis/result_page.dart';
import 'package:fp/pages/history/history_page.dart';
import 'package:fp/pages/history/case_details.dart';
import 'package:fp/pages/patient/patients_page.dart';
import 'package:fp/pages/patient/patient_profile_page.dart';
import 'package:fp/pages/profile/edit_profile_page.dart';
import 'package:fp/pages/profile/change_password_page.dart';
import 'package:fp/pages/profile/update_email_page.dart';
import 'package:fp/pages/profile/profile_page.dart' as profile_page;
import 'package:fp/pages/profile/settings_page.dart';
import 'package:fp/pages/auth/login_page.dart';
import '../../pages/splash/splash_page.dart';
import 'app_routes.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),

      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignUpPage(),
      ),

      GoRoute(
        path: AppRoutes.forgetPassword,
        builder: (context, state) => const ForgetPasswordPage(),
      ),

      GoRoute(
        path: AppRoutes.verifyCode,
        builder: (context, state) => const VerifyCodePage(),
      ),

      GoRoute(
        path: AppRoutes.createNewPassword,
        builder: (context, state) => const CreateNewPasswordPage(),
      ),

      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => HomePage(),
      ),

      GoRoute(
        path: AppRoutes.addPatient,
        builder: (context, state) => const AddPatientPage(),
      ),

      GoRoute(
        path: AppRoutes.upload,
        builder: (context, state) => const UploadPage(),
      ),

      GoRoute(
        path: AppRoutes.processing,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return ProcessingPage(
            file: data['file'] as File,
            studyId: data['studyId'] as int,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.result,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return ResultPage(
            file: data['file'] as File,
            result: data['result'] as Map<String, dynamic>,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const HistoryPage(),
      ),

      GoRoute(
        path: AppRoutes.caseDetails,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return CaseDetailsPage(data: data);
        },
      ),

      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const profile_page.ProfilePage(),
      ),

      GoRoute(
        path: AppRoutes.patients,
        builder: (context, state) => const PatientsPage(),
      ),

      GoRoute(
        path: AppRoutes.patientProfile,
        builder: (context, state) {
          final patient = state.extra as Map<String, dynamic>;
          return PatientProfilePage(patient: patient);
        },
      ),

      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfilePage(),
      ),

      GoRoute(
        path: AppRoutes.changePassword,
        builder: (context, state) => const ChangePasswordPage(),
      ),

      GoRoute(
        path: AppRoutes.updateEmail,
        builder: (context, state) => const UpdateEmailPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.editPatient,
        builder: (context, state) {
          final patient = state.extra as Map<String, dynamic>?;
          return AddPatientPage(patient: patient);
        },
      ),
    ],
  );
}

class PlaceholderNextPage extends StatelessWidget {
  const PlaceholderNextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Next Screen Here',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}