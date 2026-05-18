import 'package:get/get.dart';
import '../bindings/splash_binding.dart';
import '../features/splash/presentation/pages/splash_screen.dart';
import '../bindings/login_binding.dart';
import '../bindings/register_binding.dart';
import '../bindings/main_binding.dart';
import '../bindings/home_binding.dart';
import '../bindings/scan_binding.dart';
import '../bindings/result_binding.dart';
import '../bindings/analysis_result_binding.dart';
import '../bindings/workout_plan_binding.dart';
import '../bindings/education_binding.dart';
import '../bindings/profile_binding.dart';
import '../bindings/edit_profile_binding.dart';
import '../bindings/notification_binding.dart';
import '../presentation/pages/login/login_view.dart';
import '../presentation/pages/register/register_view.dart';
import '../presentation/pages/main/main_view.dart';
import '../presentation/pages/home/home_view.dart';
import '../presentation/pages/scan/scan_view.dart';
import '../presentation/pages/scan/result_view.dart';
import '../presentation/pages/scan/analysis_result_view.dart';
import '../presentation/pages/workout_plan/workout_plan_view.dart';
import '../presentation/pages/education/education_view.dart';
import '../presentation/pages/profile/profile_view.dart';
import '../presentation/pages/notification/notification_view.dart';
import '../presentation/pages/scan/image_preview_view.dart';
import '../presentation/pages/profile/edit_profile/edit_profile_view.dart';
import '../presentation/pages/profile/activity_log/activity_log_view.dart';
import '../presentation/pages/dss_analysis/dss_analysis_view.dart';
import '../presentation/pages/progress_report/progress_report_view.dart';
import '../presentation/pages/workout_log/workout_log_view.dart';
import '../bindings/activity_log_binding.dart';
import '../bindings/dss_analysis_binding.dart';
import '../bindings/progress_report_binding.dart';
import '../bindings/workout_log_binding.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen(), binding: SplashBinding(), transition: Transition.fadeIn, transitionDuration: const Duration(milliseconds: 300)),
    GetPage(name: AppRoutes.login, page: () => const LoginView(), binding: LoginBinding(), transition: Transition.noTransition),
    GetPage(name: AppRoutes.register, page: () => const RegisterView(), binding: RegisterBinding(), transition: Transition.noTransition),
    GetPage(name: AppRoutes.main, page: () => const MainView(), binding: MainBinding()),
    GetPage(name: AppRoutes.home, page: () => const HomeView(), binding: HomeBinding()),
    GetPage(name: AppRoutes.scan, page: () => const ScanView(), binding: ScanBinding(), transition: Transition.downToUp),
    GetPage(name: AppRoutes.result, page: () => const ResultView(), binding: ResultBinding(), transition: Transition.cupertino),
    GetPage(name: AppRoutes.analysisResult, page: () => const AnalysisResultView(), binding: AnalysisResultBinding(), transition: Transition.cupertino),
    GetPage(name: AppRoutes.workoutPlan, page: () => const WorkoutPlanView(), binding: WorkoutPlanBinding(), transition: Transition.cupertino),
    GetPage(name: AppRoutes.education, page: () => const EducationView(), binding: EducationBinding(), transition: Transition.cupertino),
    GetPage(name: AppRoutes.profile, page: () => const ProfileView(), binding: ProfileBinding(), transition: Transition.cupertino),
    GetPage(name: AppRoutes.notification, page: () => const NotificationView(), binding: NotificationBinding(), transition: Transition.cupertino),
    GetPage(name: AppRoutes.imagePreview, page: () => const ImagePreviewView(), transition: Transition.cupertino),
    GetPage(name: AppRoutes.editProfile, page: () => const EditProfileView(), binding: EditProfileBinding(), transition: Transition.cupertino),
    GetPage(name: AppRoutes.activityLog, page: () => const ActivityLogView(), binding: ActivityLogBinding(), transition: Transition.cupertino),
    GetPage(name: AppRoutes.dssAnalysis, page: () => const DssAnalysisView(), binding: DssAnalysisBinding(), transition: Transition.cupertino),
    GetPage(name: AppRoutes.progressReport, page: () => const ProgressReportView(), binding: ProgressReportBinding(), transition: Transition.cupertino),
    GetPage(name: AppRoutes.workoutLog, page: () => const WorkoutLogView(), binding: WorkoutLogBinding(), transition: Transition.cupertino),
  ];
}