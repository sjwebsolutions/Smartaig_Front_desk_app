import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../models/student_count_model.dart';
import '../../services/student_count_service.dart';
import '../../utils/app_error_formatter.dart';
import '../../utils/app_snackbar.dart';

class StudentCountController extends GetxController {
  final StudentCountService _service = StudentCountService();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var studentCountData = Rxn<StudentCountData>();
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStudentCount();
  }

  Future<void> fetchStudentCount({bool isManualRefresh = false}) async {
    if (!isManualRefresh && studentCountData.value == null) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      debugPrint('🚀 [StudentCountController] Fetching student count data...');
      final response = await _service.fetchStudentCount();

      if ((response.success == true || response.data != null) && response.data != null) {
        studentCountData.value = response.data;
        debugPrint('✅ [StudentCountController] Student count data loaded successfully');
      } else {
        errorMessage.value = response.message ?? 'Failed to load student count';
      }
    } catch (e, stack) {
      debugPrint('❌ [StudentCountController Exception]: $e\n$stack');
      errorMessage.value = AppErrorFormatter.format(e);
      if (isManualRefresh) {
        AppSnackbar.showError(
          title: 'Refresh Failed',
          message: errorMessage.value,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  List<ClassWiseCount> get filteredClassWiseCounts {
    final data = studentCountData.value;
    if (data?.classWiseCounts == null) return [];

    final list = data!.classWiseCounts!;
    final query = searchQuery.value.trim().toLowerCase();

    if (query.isEmpty) return list;

    return list.where((item) {
      final className = (item.className ?? '').toLowerCase();
      final streamName = (item.streamName ?? '').toLowerCase();
      final sectionName = (item.sectionName ?? '').toLowerCase();
      return className.contains(query) || streamName.contains(query) || sectionName.contains(query);
    }).toList();
  }
}
