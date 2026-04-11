import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../core/routing/app_routes.dart';
import '../../core/services/patient_service.dart';

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
  late TextEditingController otherDiseaseController;
  late TextEditingController notesController;

  String selectedGender = 'Male';
  DateTime? selectedDateOfBirth;

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
    otherDiseaseController = TextEditingController();

    if (widget.patient != null) {
      selectedGender = widget.patient!['gender'] ?? 'Male';
      final chronicDiseases = (widget.patient!['chronicDiseases'] ?? '').toString().split(', ');
      for (var d in diseases.keys) {
        if (chronicDiseases.contains(d)) {
          diseases[d] = true;
        }
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    otherDiseaseController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    setState(() {
      ageController.text = age.toString();
      selectedDateOfBirth = birthDate;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateOfBirth ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2B4F7A),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _calculateAge(picked);
    }
  }

  void toggleDisease(String disease) {
    setState(() {
      diseases[disease] = !(diseases[disease] ?? false);
    });
  }

  bool isLoading = false;

  Future<void> savePatient() async {
    if (nameController.text.trim().isEmpty || ageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Age are required')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.patient != null ? 'Patient updated successfully' : 'Patient saved successfully')),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.home);
        }
      }
    } catch (e) {
      debugPrint('Save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving patient: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2B4F7A);
    const pageBg = Color(0xFFF4F4F4);

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            /// Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 14, 10, 18),
              decoration: const BoxDecoration(
                color: Color(0xFF2B4F7A),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 0,
                    child: IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.home);
                        }
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  Text(
                    widget.patient != null ? 'Edit Patient' : 'Add Patient',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Patient Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _LabeledField(
                                  label: 'Name',
                                  child: _CustomInput(
                                    controller: nameController,
                                    hint: 'Enter Patient Name',
                                    icon: Icons.person_outline,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: _LabeledField(
                                  label: 'Age',
                                  child: GestureDetector(
                                    onTap: () => _selectDate(context),
                                    child: AbsorbPointer(
                                      child: _CustomInput(
                                        controller: ageController,
                                        hint: 'Enter Age',
                                        icon: Icons.calendar_month_outlined,
                                        readOnly: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _LabeledField(
                                  label: 'Phone Number',
                                  child: _CustomInput(
                                    controller: phoneController,
                                    hint: 'Enter Phone Number',
                                    icon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: _LabeledField(
                                  label: 'Gender',
                                  child: _GenderDropdown(
                                    value: selectedGender,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedGender = value!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Medical information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Chronic Diseases (Select all that apply)',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),

                           Wrap(
                            spacing: 8,
                            runSpacing: 10,
                            children: [
                              _DiseaseChip(
                                title: 'Asthma',
                                isSelected: diseases['Asthma']!,
                                color: const Color(0xFFD9EDF7),
                                icon: Icons.air,
                                onTap: () => toggleDisease('Asthma'),
                              ),
                              _DiseaseChip(
                                title: 'Hypertension',
                                isSelected: diseases['Hypertension']!,
                                color: const Color(0xFFF0E4D7),
                                icon: Icons.check_circle_outline,
                                onTap: () => toggleDisease('Hypertension'),
                              ),
                              _DiseaseChip(
                                title: 'Heart Diseases',
                                isSelected: diseases['Heart Diseases']!,
                                color: const Color(0xFFD7ECE8),
                                icon: Icons.monitor_heart,
                                onTap: () => toggleDisease('Heart Diseases'),
                              ),
                              _DiseaseChip(
                                title: 'Diabetes',
                                isSelected: diseases['Diabetes']!,
                                color: const Color(0xFFCFE0F5),
                                icon: Icons.check_circle,
                                onTap: () => toggleDisease('Diabetes'),
                              ),
                              _DiseaseChip(
                                title: 'Other',
                                isSelected: diseases['Other']!,
                                color: const Color(0xFFE2E2E2),
                                icon: Icons.add,
                                onTap: () => toggleDisease('Other'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          _CustomInput(
                            controller: otherDiseaseController,
                            hint: 'Other Disease Details   (if needed)',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DOCTOR NOTES',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.black26),
                            ),
                            child: TextField(
                              controller: notesController,
                              maxLines: null,
                              expands: true,
                              decoration: const InputDecoration(
                                hintText:
                                    'Add relevant medical notes, history, or observations...',
                                prefixIcon: Padding(
                                  padding: EdgeInsets.only(bottom: 55),
                                  child: Icon(Icons.edit),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: savePatient,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Save Patient',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _CustomInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final TextInputType keyboardType;
  final bool readOnly;

  const _CustomInput({
    required this.controller,
    required this.hint,
    this.icon,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          prefixIcon: icon != null
              ? Icon(icon, size: 20, color: Colors.grey)
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

class _GenderDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _GenderDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: const [
            DropdownMenuItem(
              value: 'Male',
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 20, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Male'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'Female',
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 20, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Female'),
                ],
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _DiseaseChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _DiseaseChip({
    required this.title,
    required this.isSelected,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = isSelected ? color : const Color(0xFFE8E8E8);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: displayColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.black12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.blueGrey.shade700),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}