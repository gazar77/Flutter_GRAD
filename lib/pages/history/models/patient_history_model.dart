class PatientHistory {
  final String? id;
  final String name;
  final int age;
  final String date;
  final String gender;
  final int stenosis;
  final String? artery;
  final String? riskLevel;
  final String? notes;
  final String? image1;
  final String? image2;

  PatientHistory({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.date,
    required this.stenosis,
    this.artery,
    this.riskLevel,
    this.notes,
    this.image1,
    this.image2,
  });

  String get status {
    if (riskLevel != null && riskLevel != 'N/A') return riskLevel!;
    if (stenosis < 40) return 'Normal';
    if (stenosis < 70) return 'Moderate';
    return 'Critical';
  }
}