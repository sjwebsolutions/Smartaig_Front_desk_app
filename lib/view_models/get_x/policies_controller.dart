import 'package:get/get.dart';
import '../../models/policies_model.dart';
import '../../services/policies_service.dart';
import '../../utils/app_error_formatter.dart';

class PoliciesController extends GetxController {
  final PoliciesService _policiesService = PoliciesService();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var policiesData = Rxn<PoliciesData>();

  @override
  void onInit() {
    super.onInit();
    fetchPolicies();
  }

  Future<void> fetchPolicies() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _policiesService.fetchPolicies();
      if (response.success == true && response.data != null) {
        policiesData.value = response.data;
      } else {
        errorMessage.value = response.message ?? 'Failed to load policies';
      }
    } catch (e) {
      errorMessage.value = AppErrorFormatter.format(e);
    } finally {
      isLoading.value = false;
    }
  }
}
