import 'package:get/get.dart';
import '../../models/active_event_model.dart';
import '../../services/active_event_service.dart';
import '../../utils/app_error_formatter.dart';

class ActiveEventController extends GetxController {
  final ActiveEventService _service = ActiveEventService();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var activeEvents = <ActiveEventItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchActiveEvents();
  }

  Future<void> fetchActiveEvents({bool isManualRefresh = false}) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _service.fetchActiveEvents();

      if (response.success == true && response.data != null) {
        activeEvents.value = response.data!;
      } else {
        activeEvents.clear();
        errorMessage.value = response.message ?? 'Failed to load active events';
      }
    } catch (e) {
      activeEvents.clear();
      errorMessage.value = AppErrorFormatter.format(e);
    } finally {
      isLoading.value = false;
    }
  }
}
