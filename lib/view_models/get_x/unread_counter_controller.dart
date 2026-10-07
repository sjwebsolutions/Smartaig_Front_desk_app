import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnreadCounterController extends GetxController {
  static UnreadCounterController get to {
    if (Get.isRegistered<UnreadCounterController>()) {
      return Get.find<UnreadCounterController>();
    }
    return Get.put(UnreadCounterController(), permanent: true);
  }

  var callbackCount = 0.obs;
  var gatePassCount = 0.obs;
  var visitorCount = 0.obs;
  var admissionCount = 0.obs;
  var studentLeaveCount = 0.obs;
  var teacherLeaveCount = 0.obs;
  var studentCount = 0.obs;
  var scanAttendanceCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    reloadCounters();
  }

  Future<void> reloadCounters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      callbackCount.value = prefs.getInt('unread_callback_count') ?? 0;
      gatePassCount.value = prefs.getInt('unread_gate_pass_count') ?? 0;
      visitorCount.value = prefs.getInt('unread_visitor_count') ?? 0;
      admissionCount.value = prefs.getInt('unread_admission_count') ?? 0;
      studentLeaveCount.value = prefs.getInt('unread_student_leave_count') ?? 0;
      teacherLeaveCount.value = prefs.getInt('unread_teacher_leave_count') ?? 0;
      studentCount.value = prefs.getInt('unread_student_count') ?? 0;
      scanAttendanceCount.value = prefs.getInt('unread_scan_attendance_count') ?? 0;
    } catch (_) {}
  }

  Future<void> incrementCallback() async {
    callbackCount.value++;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('unread_callback_count', callbackCount.value);
    } catch (_) {}
  }

  Future<void> incrementGatePass() async {
    gatePassCount.value++;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('unread_gate_pass_count', gatePassCount.value);
    } catch (_) {}
  }

  Future<void> incrementVisitor() async {
    visitorCount.value++;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('unread_visitor_count', visitorCount.value);
    } catch (_) {}
  }

  Future<void> incrementAdmission() async {
    admissionCount.value++;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('unread_admission_count', admissionCount.value);
    } catch (_) {}
  }

  Future<void> incrementStudentLeave() async {
    studentLeaveCount.value++;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('unread_student_leave_count', studentLeaveCount.value);
    } catch (_) {}
  }

  Future<void> incrementTeacherLeave() async {
    teacherLeaveCount.value++;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('unread_teacher_leave_count', teacherLeaveCount.value);
    } catch (_) {}
  }

  Future<void> incrementStudentCount() async {
    studentCount.value++;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('unread_student_count', studentCount.value);
    } catch (_) {}
  }

  Future<void> incrementScanAttendance() async {
    scanAttendanceCount.value++;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('unread_scan_attendance_count', scanAttendanceCount.value);
    } catch (_) {}
  }

  Future<void> clearCallback() async {
    callbackCount.value = 0;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('unread_callback_count', 0);
    } catch (_) {}
  }

  Future<void> clearGatePass() async {
    gatePassCount.value = 0;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('unread_gate_pass_count', 0);
    } catch (_) {}
  }

  Future<void> clearVisitor() async {
    visitorCount.value = 0;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('unread_visitor_count', 0);
    } catch (_) {}
  }

  Future<void> clearAdmission() async {
    admissionCount.value = 0;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('unread_admission_count', 0);
    } catch (_) {}
  }

  Future<void> clearStudentLeave() async {
    studentLeaveCount.value = 0;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('unread_student_leave_count', 0);
    } catch (_) {}
  }

  Future<void> clearTeacherLeave() async {
    teacherLeaveCount.value = 0;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('unread_teacher_leave_count', 0);
    } catch (_) {}
  }

  Future<void> clearStudentCount() async {
    studentCount.value = 0;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('unread_student_count', 0);
    } catch (_) {}
  }

  Future<void> clearScanAttendance() async {
    scanAttendanceCount.value = 0;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('unread_scan_attendance_count', 0);
    } catch (_) {}
  }
}
