import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/services/patient_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/networking/api_error_handler.dart';
import '../../core/localization/app_localizations.dart';

class AddPatientPage extends StatefulWidget {
  final Map<String, dynamic>? patient;
  const AddPatientPage({super.key, this.patient});

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController phoneController;
  late TextEditingController notesController;

  String selectedGender = 'Male';
  DateTime? selectedDateOfBirth;
  bool isLoading = false;

  final Map<String, bool> diseases = {
    'Asthma': false,
    'Hypertension': false,
    'Heart Diseases': false,
    'Diabetes': false,
    'Other': false,
  };

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.patient?['fullName'] ?? '');
    ageController = TextEditingController(text: widget.patient?['age']?.toString() ?? '');
    phoneController = TextEditingController(text: widget.patient?['phoneNumber'] ?? '');
    notesController = TextEditingController(text: widget.patient?['notes'] ?? '');

    if (widget.patient != null) {
      selectedGender = widget.patient!['gender'] ?? 'Male';
      final chronicDiseases = (widget.patient!['chronicDiseases'] ?? '').toString().split(', ');
      for (var d in diseases.keys) {
        if (chronicDiseases.contains(d)) diseases[d] = true;
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateOfBirth ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDateOfBirth = picked;
        final age = DateTime.now().year - picked.year;
        ageController.text = age.toString();
      });
    }
  }

  Future<void> savePatient() async {
    if (nameController.text.trim().isEmpty || ageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Age are required')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final selectedDiseases = diseases.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .join(', ');

      final patientData = {
        'fullName': nameController.text.trim(),
        'age': int.parse(ageController.text.trim()),
        'gender': selectedGender,
        'phoneNumber': phoneController.text.trim(),
        'chronicDiseases': selectedDiseases,
        'notes': notesController.text.trim(),
      };

      if (widget.patient != null) {
        await PatientService().updatePatient(widget.patient!['id'], patientData);
      } else {
        await PatientService().createPatient(
          fullName: patientData['fullName'] as String,
          age: patientData['age'] as int,
          gender: patientData['gender'] as String,
          phone: patientData['phoneNumber'] as String,
          chronicDiseases: patientData['chronicDiseases'] as String,
          notes: patientData['notes'] as String,
        );
      }

      if (mounted) {
        context.read<AppState>().triggerDashboardRefresh();
        if (context.canPop()) { context.pop(); } else { context.go('/home'); }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiErrorHandler.getMessage(e, context))),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient != null ? 'edit_patient'.tr(context) : 'add_patient'.tr(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () { if (context.canPop()) { context.pop(); } else { context.go('/home'); } },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildSection(
              context,
              'patient_info'.tr(context),
              [
                AppTextField(
                  label: 'name'.tr(context),
                  hint: 'Enter Patient Name',
                  controller: nameController,
                  prefixIcon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'age'.tr(context),
                        hint: 'Age',
                        controller: ageController,
                        prefixIcon: Icons.calendar_today_rounded,
                        keyboardType: TextInputType.number,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildGenderDropdown(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'phone'.tr(context),
                  hint: 'Enter Phone Number',
                  controller: phoneController,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'medical_info'.tr(context),
              [
                Text(
                  'chronic_diseases'.tr(context),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: diseases.keys.map((d) => _buildDiseaseChip(d)).toList(),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'doctor_notes'.tr(context),
                  hint: 'Add medical observations...',
                  controller: notesController,
                  maxLines: 4,
                  prefixIcon: Icons.note_alt_outlined,
                ),
              ],
            ),
            const SizedBox(height: 40),
            AppButton(
              text: 'save_patient'.tr(context),
              isLoading: isLoading,
              onPressed: savePatient,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
          ),
        ),
        AppCard(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'gender'.tr(context),
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedGender,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: ['Male', 'Female'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedGender = v!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiseaseChip(String disease) {
    final isSelected = diseases[disease]!;
    return FilterChip(
      label: Text(disease),
      selected: isSelected,
      onSelected: (v) => setState(() => diseases[disease] = v),
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.secondary.withValues(alpha: 0.2)),
      ),
    );
  }
}