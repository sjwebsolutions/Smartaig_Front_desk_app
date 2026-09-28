import 'package:get/get.dart';
import '../../models/support_settings_model.dart';
import '../../services/support_service.dart';
import '../../utils/app_error_formatter.dart';

class SupportController extends GetxController {
  final SupportService _supportService = SupportService();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var supportData = Rxn<SupportSettingsData>();

  @override
  void onInit() {
    super.onInit();
    fetchSupportSettings();
  }

  Future<void> fetchSupportSettings() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _supportService.fetchSupportSettings();
      if (response.success == true && response.data != null) {
        supportData.value = response.data;
      } else {
        errorMessage.value = response.message ?? 'Failed to load support settings';
      }
    } catch (e) {
      errorMessage.value = AppErrorFormatter.format(e);
    } finally {
      isLoading.value = false;
    }
  }
}
