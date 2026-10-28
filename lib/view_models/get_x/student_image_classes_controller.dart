import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../models/student_image_classes_model.dart';
import '../../services/student_image_classes_service.dart';
import '../../utils/app_error_formatter.dart';
import '../../utils/app_snackbar.dart';

class StudentImageClassesController extends GetxController {
  final StudentImageClassesService _service = StudentImageClassesService();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var classesData = Rxn<StudentImageClassesData>();

  var selectedClass = Rxn<StudentClassItem>();
  var selectedSection = Rxn<StudentSectionItem>();
  var selectedStream = Rxn<StudentStreamItem>();

  @override
  void onInit() {
    super.onInit();
    fetchStudentImageClasses();
  }

  Future<void> fetchStudentImageClasses({bool isManualRefresh = false}) async {
    if (!isManualRefresh && classesData.value == null) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      debugPrint('🚀 [StudentImageClassesController] Fetching student image classes data...');
      final response = await _service.fetchStudentImageClasses();

      if ((response.success == true || response.data != null) && response.data != null) {
        classesData.value = response.data;
        debugPrint('✅ [StudentImageClassesController] Classes data loaded successfully');
      } else {
        errorMessage.value = response.message ?? 'Failed to load classes data';
      }
    } catch (e, stack) {
      debugPrint('❌ [StudentImageClassesController Exception]: $e\n$stack');
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

  List<StudentClassItem> get classesList => classesData.value?.classes ?? [];
  List<StudentSectionItem> get allSections => classesData.value?.allSections ?? [];
  List<StudentStreamItem> get allStreams => classesData.value?.allStreams ?? [];

  List<StudentSectionItem> get availableSections {
    if (selectedClass.value != null && selectedClass.value!.sections != null && selectedClass.value!.sections!.isNotEmpty) {
      return selectedClass.value!.sections!;
    }
    return allSections;
  }

  List<StudentStreamItem> get availableStreams {
    if (selectedClass.value != null && selectedClass.value!.streams != null) {
      return selectedClass.value!.streams!;
    }
    return allStreams;
  }

  void selectClass(StudentClassItem? item) {
    selectedClass.value = item;
    selectedSection.value = null;
    selectedStream.value = null;
  }

  void selectSection(StudentSectionItem? item) {
    selectedSection.value = item;
  }

  void selectStream(StudentStreamItem? item) {
    selectedStream.value = item;
  }
}
