import 'dart:async';
import 'package:get/get.dart';
import '../../models/admission_model.dart';
import '../../services/admission_service.dart';
import '../../utils/app_error_formatter.dart';
import '../../utils/app_snackbar.dart';

class AdmissionController extends GetxController {
  final AdmissionService _service = AdmissionService();

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  var isDetailLoading = false.obs;
  var detailErrorMessage = ''.obs;
  Rxn<AdmissionDetailModel> admissionDetail = Rxn<AdmissionDetailModel>();

  var isAddingFollowup = false.obs;
  var isAddingEnquiry = false.obs;

  var classList = <AdmissionClassItem>[].obs;
  var isClassLoading = false.obs;

  var enquiryList = <AdmissionEnquiryModel>[].obs;
  var searchQuery = ''.obs;
  var selectedStatus = 'all'.obs;
  var selectedSessionYear = 'all'.obs;
  Timer? _syncTimer;

  @override
  void onInit() {
    super.onInit();
    fetchAdmissionEnquiries();
    fetchAdmissionClasses();
    _startPeriodicSync();
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    super.onClose();
  }

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      fetchAdmissionEnquiries(isSilent: true);
    });
  }

  Future<void> fetchAdmissionEnquiries({bool isSilent = false}) async {
    if (!isSilent) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final response = await _service.fetchAdmissionEnquiries(
        status: selectedStatus.value,
        sessionYear: selectedSessionYear.value,
      );

      if (response.success == true && response.data != null) {
        enquiryList.value = response.data!;
      } else {
        if (!isSilent) {
          enquiryList.clear();
          errorMessage.value = 'Failed to load admission enquiries';
        }
      }
    } catch (e) {
      if (!isSilent) {
        errorMessage.value = AppErrorFormatter.format(e);
      }
    } finally {
      if (!isSilent) {
        isLoading.value = false;
      }
    }
  }

  Future<void> fetchAdmissionDetail(int id) async {
    isDetailLoading.value = true;
    detailErrorMessage.value = '';
    admissionDetail.value = null;

    try {
      final response = await _service.fetchAdmissionDetail(id);
      if (response.success == true && response.data != null) {
        admissionDetail.value = response.data;
      } else {
        detailErrorMessage.value = 'Failed to load admission enquiry detail';
      }
    } catch (e) {
      detailErrorMessage.value = AppErrorFormatter.format(e);
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<void> fetchAdmissionClasses() async {
    isClassLoading.value = true;
    try {
      final response = await _service.fetchAdmissionClasses();
      if (response.success == true && response.data != null) {
        classList.value = response.data!;
      }
    } catch (_) {
    } finally {
      isClassLoading.value = false;
    }
  }

  Future<bool> addAdmissionFollowup({
    required int enquiryId,
    required String note,
  }) async {
    isAddingFollowup.value = true;
    try {
      final response = await _service.addAdmissionFollowup(
        enquiryId: enquiryId,
        note: note,
      );

      if (response.success == true || response.data != null) {
        AppSnackbar.showSuccess(
          title: 'Follow-up Added',
          message: response.message ?? 'Follow-up note added successfully.',
        );
        fetchAdmissionDetail(enquiryId);
        fetchAdmissionEnquiries(isSilent: true);
        return true;
      } else {
        AppSnackbar.showError(
          title: 'Failed',
          message: response.message ?? 'Could not add follow-up note.',
        );
        return false;
      }
    } catch (e) {
      AppSnackbar.showError(
        title: AppErrorFormatter.getTitle(e, defaultTitle: 'Error'),
        message: AppErrorFormatter.format(e),
      );
      return false;
    } finally {
      isAddingFollowup.value = false;
    }
  }

  Future<bool> addAdmissionEnquiry({
    required String fullName,
    required String gender,
    required String fatherMobile,
    required String address,
    String? studentClassId,
    String? dob,
    String? aadhaarNo,
    String? fatherName,
    String? motherName,
    String? motherMobile,
    String? alternateContact,
    String? locality,
    String? city,
    String? state,
    String? pincode,
    String? category,
    String? religion,
    String? caste,
    String? previousSchool,
    String? lastClassAttended,
    String? reasonForLeaving,
    String? interestLevel,
    String? remarks,
    dynamic imageFile,
  }) async {
    isAddingEnquiry.value = true;
    try {
      final response = await _service.addAdmissionEnquiry(
        fullName: fullName,
        gender: gender,
        fatherMobile: fatherMobile,
        address: address,
        studentClassId: studentClassId,
        dob: dob,
        aadhaarNo: aadhaarNo,
        fatherName: fatherName,
        motherName: motherName,
        motherMobile: motherMobile,
        alternateContact: alternateContact,
        locality: locality,
        city: city,
        state: state,
        pincode: pincode,
        category: category,
        religion: religion,
        caste: caste,
        previousSchool: previousSchool,
        lastClassAttended: lastClassAttended,
        reasonForLeaving: reasonForLeaving,
        interestLevel: interestLevel,
        remarks: remarks,
        imageFile: imageFile,
      );

      if (response.success == true || response.data != null) {
        fetchAdmissionEnquiries(isSilent: true);
        return true;
      } else {
        AppSnackbar.showError(
          title: 'Registration Failed',
          message: response.message ?? 'Could not register admission enquiry.',
        );
        return false;
      }
    } catch (e) {
      AppSnackbar.showError(
        title: AppErrorFormatter.getTitle(e, defaultTitle: 'Error'),
        message: AppErrorFormatter.format(e),
      );
      return false;
    } finally {
      isAddingEnquiry.value = false;
    }
  }

  List<AdmissionEnquiryModel> get filteredEnquiries {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return enquiryList;
    }
    return enquiryList.where((item) {
      final name = item.fullName?.toLowerCase() ?? '';
      final inqNum = item.inquiryNumber?.toLowerCase() ?? '';
      final fatherName = item.fatherName?.toLowerCase() ?? '';
      final fatherMobile = item.fatherMobile?.toLowerCase() ?? '';
      final motherMobile = item.motherMobile?.toLowerCase() ?? '';
      final className = item.className?.toLowerCase() ?? '';
      final statusLabel = item.statusLabel?.toLowerCase() ?? '';

      return name.contains(query) ||
          inqNum.contains(query) ||
          fatherName.contains(query) ||
          fatherMobile.contains(query) ||
          motherMobile.contains(query) ||
          className.contains(query) ||
          statusLabel.contains(query);
    }).toList();
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
    fetchAdmissionEnquiries();
  }

  void filterBySessionYear(String sessionYear) {
    selectedSessionYear.value = sessionYear;
    fetchAdmissionEnquiries();
  }
}
