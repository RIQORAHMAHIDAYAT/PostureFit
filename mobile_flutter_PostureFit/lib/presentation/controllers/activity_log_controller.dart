import 'package:get/get.dart';

class ActivityLogController extends GetxController {
  // Mock data for activity logs
  final logs = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _fetchLogs();
  }

  void _fetchLogs() {
    // In a real app, fetch from repository/API
    // For now, dummy data
    logs.assignAll([]);
  }
}
