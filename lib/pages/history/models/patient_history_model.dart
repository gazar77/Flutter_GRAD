class PatientHistory {
  final String name;
  final int age;
  final String date;
  final int stenosis;

  PatientHistory({
    required this.name,
    required this.age,
    required this.date,
    required this.stenosis,
  });

  String get status {
    if (stenosis < 40) return 'Normal';
    if (stenosis < 70) return 'Moderate';
    return 'Critical';
  }
}