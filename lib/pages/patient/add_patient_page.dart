import 'package:flutter/material.dart';
import 'package:fp/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';

class AddPatientPage extends StatefulWidget {
  const AddPatientPage({super.key});

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otherDiseaseController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String selectedGender = 'Male';

  final Map<String, bool> diseases = {
    'Asthma': false,
    'Hypertension': true,
    'Heart Diseases': false,
    'Diabetes': true,
    'Other': false,
  };

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    otherDiseaseController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void toggleDisease(String disease) {
    setState(() {
      diseases[disease] = !(diseases[disease] ?? false);
    });
  }

  void savePatient() {
    final selectedDiseases = diseases.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    final patientData = {
      'name': nameController.text.trim(),
      'age': ageController.text.trim(),
      'phone': phoneController.text.trim(),
      'gender': selectedGender,
      'diseases': selectedDiseases,
      'otherDisease': otherDiseaseController.text.trim(),
      'notes': notesController.text.trim(),
    };

    debugPrint(patientData.toString());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Patient saved successfully'),
      ),
    );

    // هنا بعدين تربطه بالـ API
    // context.pop();
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
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2B4F7A),
                    Color(0xFF5F7695),
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Add Patient',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
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
                                  child: _CustomInput(
                                    controller: ageController,
                                    hint: 'Enter Age',
                                    icon: Icons.calendar_today_outlined,
                                    keyboardType: TextInputType.number,
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
                                color: const Color(0xFFEAD9CC),
                                icon: Icons.favorite,
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
                                icon: Icons.water_drop,
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
                        child: const Text(
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
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 3),
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

  const _CustomInput({
    required this.controller,
    required this.hint,
    this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black26),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
          prefixIcon: icon != null
              ? Icon(icon, size: 18, color: Colors.grey)
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
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
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black26),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: const [
            DropdownMenuItem(
              value: 'Male',
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 18),
                  SizedBox(width: 8),
                  Text('Male'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'Female',
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 18),
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