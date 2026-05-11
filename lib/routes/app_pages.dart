import 'package:get/get.dart';
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
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    GetPage(name: AppRoutes.login, page: () => const LoginView(), binding: LoginBinding(), transition: Transition.fadeIn, transitionDuration: const Duration(milliseconds: 220)),
    GetPage(name: AppRoutes.register, page: () => const RegisterView(), binding: RegisterBinding(), transition: Transition.fadeIn, transitionDuration: const Duration(milliseconds: 220)),
    GetPage(name: AppRoutes.main, page: () => const MainView(), binding: MainBinding()),
    GetPage(name: AppRoutes.home, page: () => const HomeView(), binding: HomeBinding()),
    GetPage(name: AppRoutes.scan, page: () => const ScanView(), binding: ScanBinding(), transition: Transition.downToUp),
    GetPage(name: AppRoutes.result, page: () => const ResultView(), binding: ResultBinding(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.analysisResult, page: () => const AnalysisResultView(), binding: AnalysisResultBinding(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.workoutPlan, page: () => const WorkoutPlanView(), binding: WorkoutPlanBinding(), transition: Transition.fadeIn),
    GetPage(name: AppRoutes.education, page: () => const EducationView(), binding: EducationBinding(), transition: Transition.fadeIn),
    GetPage(name: AppRoutes.profile, page: () => const ProfileView(), binding: ProfileBinding(), transition: Transition.fadeIn),
    GetPage(name: AppRoutes.notification, page: () => const NotificationView(), binding: NotificationBinding(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.imagePreview, page: () => const ImagePreviewView(), transition: Transition.rightToLeft),
  ];
}