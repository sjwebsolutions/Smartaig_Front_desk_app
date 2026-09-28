import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_snackbar.dart';
import '../../view_models/get_x/admission_controller.dart';

class AadhaarNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limitedDigits = digits.length > 12 ? digits.substring(0, 12) : digits;

    final buffer = StringBuffer();
    for (int i = 0; i < limitedDigits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(limitedDigits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class AddAdmissionEnquiryScreen extends StatefulWidget {
  const AddAdmissionEnquiryScreen({super.key});

  @override
  State<AddAdmissionEnquiryScreen> createState() => _AddAdmissionEnquiryScreenState();
}

class _AddAdmissionEnquiryScreenState extends State<AddAdmissionEnquiryScreen> {
  final AdmissionController _controller = Get.find<AdmissionController>();
  final _formKey = GlobalKey<FormState>();

  // Student Image Picker
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Required Fields
  final _fullNameController = TextEditingController();
  String _selectedGender = 'male';
  final _fatherMobileController = TextEditingController();
  final _addressController = TextEditingController();

  // Optional Fields
  String? _selectedClassId;
  DateTime? _selectedDob;
  final _dobController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _motherMobileController = TextEditingController();
  final _alternateContactController = TextEditingController();
  final _localityController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  String? _selectedCategory;
  final _religionController = TextEditingController();
  final _casteController = TextEditingController();
  final _previousSchoolController = TextEditingController();
  final _lastClassAttendedController = TextEditingController();
  final _reasonForLeavingController = TextEditingController();
  String? _selectedInterestLevel;
  final _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (_controller.classList.isEmpty) {
      _controller.fetchAdmissionClasses();
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _fatherMobileController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _aadhaarController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _motherMobileController.dispose();
    _alternateContactController.dispose();
    _localityController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _religionController.dispose();
    _casteController.dispose();
    _previousSchoolController.dispose();
    _lastClassAttendedController.dispose();
    _reasonForLeavingController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        setState(() {
          _selectedImage = picked;
        });
      }
    } catch (_) {
      AppSnackbar.showError(title: 'Image Error', message: 'Could not select image.');
    }
  }

  void _showImagePickerModal() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Student Photo',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF4F46E5)),
              title: Text('Take Photo', style: GoogleFonts.poppins(fontSize: 14)),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF4F46E5)),
              title: Text('Choose from Gallery', style: GoogleFonts.poppins(fontSize: 14)),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                title: Text('Remove Photo', style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFFEF4444))),
                onTap: () {
                  Get.back();
                  setState(() => _selectedImage = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDob(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(now.year - 5, now.month, now.day),
      firstDate: DateTime(now.year - 20),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4F46E5),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      AppSnackbar.showError(
        title: 'Validation Error',
        message: 'Please check form errors and fill required fields (*).',
      );
      return;
    }

    final fatherMobile = _fatherMobileController.text.trim();
    if (fatherMobile.length != 10) {
      AppSnackbar.showError(
        title: 'Invalid Mobile Number',
        message: 'Father Mobile must be exactly 10 digits.',
      );
      return;
    }

    final motherMobile = _motherMobileController.text.trim();
    if (motherMobile.isNotEmpty && motherMobile.length != 10) {
      AppSnackbar.showError(
        title: 'Invalid Mobile Number',
        message: 'Mother Mobile must be exactly 10 digits.',
      );
      return;
    }

    final alternateContact = _alternateContactController.text.trim();
    if (alternateContact.isNotEmpty && alternateContact.length != 10) {
      AppSnackbar.showError(
        title: 'Invalid Contact Number',
        message: 'Alternate Contact must be exactly 10 digits.',
      );
      return;
    }

    final rawAadhaar = _aadhaarController.text.replaceAll(' ', '').trim();
    if (rawAadhaar.isNotEmpty && rawAadhaar.length != 12) {
      AppSnackbar.showError(
        title: 'Invalid Aadhaar Number',
        message: 'Aadhaar Number must be exactly 12 digits.',
      );
      return;
    }

    final success = await _controller.addAdmissionEnquiry(
      fullName: _fullNameController.text.trim(),
      gender: _selectedGender,
      fatherMobile: fatherMobile,
      address: _addressController.text.trim(),
      studentClassId: _selectedClassId,
      dob: _dobController.text.trim(),
      aadhaarNo: rawAadhaar,
      fatherName: _fatherNameController.text.trim(),
      motherName: _motherNameController.text.trim(),
      motherMobile: motherMobile,
      alternateContact: alternateContact,
      locality: _localityController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
      category: _selectedCategory,
      religion: _religionController.text.trim(),
      caste: _casteController.text.trim(),
      previousSchool: _previousSchoolController.text.trim(),
      lastClassAttended: _lastClassAttendedController.text.trim(),
      reasonForLeaving: _reasonForLeavingController.text.trim(),
      interestLevel: _selectedInterestLevel,
      remarks: _remarksController.text.trim(),
      imageFile: _selectedImage != null ? File(_selectedImage!.path) : null,
    );

    if (success) {
      Get.back();
      AppSnackbar.showSuccess(
        title: 'Registered Successfully',
        message: 'Admission enquiry registered successfully.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD1E9FF), // Light Blue
              Color(0xFFE9D5FF), // Light Purple
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // -------------------------------------------------
              // APP BAR
              // -------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3E50), size: 20),
                      onPressed: () => Get.back(),
                      tooltip: 'Back',
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'NEW ADMISSION ENQUIRY',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C3E50),
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // Balance back icon
                  ],
                ),
              ),

              // -------------------------------------------------
              // FORM BODY
              // -------------------------------------------------
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // IMAGE PICKER CARD
                        _buildImagePickerCard(),

                        const SizedBox(height: 14),

                        // 1. Basic Details (Required)
                        _buildSectionCard(
                          title: 'Basic Details (Required)',
                          icon: Icons.person_add_rounded,
                          children: [
                            _buildTextField(
                              label: 'Full Name *',
                              controller: _fullNameController,
                              hint: 'Enter student full name',
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Full Name is required';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildDropdownField<String>(
                              label: 'Gender *',
                              initialValue: _selectedGender,
                              items: const [
                                DropdownMenuItem(value: 'male', child: Text('Male')),
                                DropdownMenuItem(value: 'female', child: Text('Female')),
                                DropdownMenuItem(value: 'other', child: Text('Other')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedGender = val);
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              label: 'Father Mobile *',
                              controller: _fatherMobileController,
                              hint: '10-digit mobile number',
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Father Mobile is required';
                                if (val.trim().length != 10) return 'Enter a valid 10-digit mobile number';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              label: 'Address *',
                              controller: _addressController,
                              hint: 'Enter residence address',
                              maxLines: 2,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Address is required';
                                return null;
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // 2. Class & DOB
                        _buildSectionCard(
                          title: 'Class & Date of Birth',
                          icon: Icons.school_rounded,
                          children: [
                            Obx(() {
                              final classes = _controller.classList;
                              return _buildDropdownField<String?>(
                                label: 'Class Applied',
                                initialValue: _selectedClassId,
                                hintText: _controller.isClassLoading.value
                                    ? 'Loading classes...'
                                    : 'Select Class',
                                items: [
                                  const DropdownMenuItem<String?>(value: null, child: Text('Select Class')),
                                  ...classes.map((c) => DropdownMenuItem<String?>(
                                        value: c.id?.toString(),
                                        child: Text(c.name ?? ''),
                                      )),
                                ],
                                onChanged: (val) => setState(() => _selectedClassId = val),
                              );
                            }),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => _selectDob(context),
                              child: AbsorbPointer(
                                child: _buildTextField(
                                  label: 'Date of Birth',
                                  controller: _dobController,
                                  hint: 'YYYY-MM-DD',
                                  suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF4F46E5)),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // 3. Parent Details
                        _buildSectionCard(
                          title: 'Parent & Guardian Details',
                          icon: Icons.family_restroom_rounded,
                          children: [
                            _buildTextField(
                              label: 'Father Name',
                              controller: _fatherNameController,
                              hint: 'Enter father name',
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              label: 'Mother Name',
                              controller: _motherNameController,
                              hint: 'Enter mother name',
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              label: 'Mother Mobile',
                              controller: _motherMobileController,
                              hint: '10-digit mobile number',
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validator: (val) {
                                if (val != null && val.trim().isNotEmpty && val.trim().length != 10) {
                                  return 'Enter a valid 10-digit mobile number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              label: 'Alternate Contact',
                              controller: _alternateContactController,
                              hint: 'Alternate phone number',
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validator: (val) {
                                if (val != null && val.trim().isNotEmpty && val.trim().length != 10) {
                                  return 'Enter a valid 10-digit mobile number';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // 4. Address Details
                        _buildSectionCard(
                          title: 'Locality & City Details',
                          icon: Icons.location_on_rounded,
                          children: [
                            _buildTextField(
                              label: 'Locality',
                              controller: _localityController,
                              hint: 'Area / Sector',
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    label: 'City',
                                    controller: _cityController,
                                    hint: 'City',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildTextField(
                                    label: 'State',
                                    controller: _stateController,
                                    hint: 'State',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              label: 'Pincode',
                              controller: _pincodeController,
                              hint: '6-digit pincode',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // 5. Category & Aadhaar
                        _buildSectionCard(
                          title: 'Category & Demographics',
                          icon: Icons.badge_rounded,
                          children: [
                            _buildTextField(
                              label: 'Aadhaar Card No.',
                              controller: _aadhaarController,
                              hint: '12-digit (e.g. 1234 5678 9012)',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                AadhaarNumberFormatter(),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildDropdownField<String?>(
                              label: 'Category',
                              initialValue: _selectedCategory,
                              hintText: 'Select Category',
                              items: const [
                                DropdownMenuItem(value: null, child: Text('Select Category')),
                                DropdownMenuItem(value: 'General', child: Text('General')),
                                DropdownMenuItem(value: 'OBC', child: Text('OBC')),
                                DropdownMenuItem(value: 'SC', child: Text('SC')),
                                DropdownMenuItem(value: 'ST', child: Text('ST')),
                                DropdownMenuItem(value: 'Other', child: Text('Other')),
                              ],
                              onChanged: (val) => setState(() => _selectedCategory = val),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    label: 'Religion',
                                    controller: _religionController,
                                    hint: 'e.g. Hindu, Sikh',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildTextField(
                                    label: 'Caste',
                                    controller: _casteController,
                                    hint: 'Sub-caste',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // 6. Academic Details
                        _buildSectionCard(
                          title: 'Academic History',
                          icon: Icons.menu_book_rounded,
                          children: [
                            _buildTextField(
                              label: 'Previous School',
                              controller: _previousSchoolController,
                              hint: 'Previous school name',
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    label: 'Last Class Attended',
                                    controller: _lastClassAttendedController,
                                    hint: 'e.g. Nursery',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildDropdownField<String?>(
                                    label: 'Interest Level',
                                    initialValue: _selectedInterestLevel,
                                    hintText: 'Select',
                                    items: const [
                                      DropdownMenuItem(value: null, child: Text('Select')),
                                      DropdownMenuItem(value: 'High', child: Text('High')),
                                      DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                                      DropdownMenuItem(value: 'Low', child: Text('Low')),
                                    ],
                                    onChanged: (val) => setState(() => _selectedInterestLevel = val),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              label: 'Reason for Leaving',
                              controller: _reasonForLeavingController,
                              hint: 'Reason for leaving previous school',
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // 7. Remarks
                        _buildSectionCard(
                          title: 'Lead Remarks & Notes',
                          icon: Icons.notes_rounded,
                          children: [
                            _buildTextField(
                              label: 'Remarks',
                              controller: _remarksController,
                              hint: 'Additional notes or parent conversation details...',
                              maxLines: 3,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // SUBMIT BUTTON
                        Obx(() {
                          return SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _controller.isAddingEnquiry.value ? null : _submitForm,
                              icon: _controller.isAddingEnquiry.value
                                  ? const SizedBox.shrink()
                                  : const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                              label: _controller.isAddingEnquiry.value
                                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                  : Text(
                                      'REGISTER ADMISSION ENQUIRY',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 2,
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _showImagePickerModal,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFFEEF2FF),
                  backgroundImage: _selectedImage != null ? FileImage(File(_selectedImage!.path)) : null,
                  child: _selectedImage == null
                      ? const Icon(Icons.person_rounded, size: 48, color: Color(0xFF818CF8))
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4F46E5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 15, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedImage == null ? 'Upload Student Photo (Optional)' : 'Tap to change photo',
            style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF2FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 16, color: const Color(0xFF4F46E5)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF1E293B)),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF4F46E5)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T initialValue,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: initialValue,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF4F46E5), size: 22),
          style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF4F46E5)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
