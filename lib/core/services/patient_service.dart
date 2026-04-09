import 'package:dio/dio.dart';
import '../networking/api_constants.dart';
import '../networking/dio_factory.dart';

class PatientService {
  final Dio _dio = DioFactory.getDio();

  Future<Map<String, dynamic>> createPatient({
    required String fullName,
    required int age,
    required String gender,
    required String phone,
    String? medicalRecordNumber,
    String? chronicDiseases,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.patients,
        data: {
          'fullName': fullName,
          'age': age,
          'gender': gender,
          'phoneNumber': phone,
          'medicalRecordNumber': medicalRecordNumber,
          'chronicDiseases': chronicDiseases,
          'notes': notes,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to create patient: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error creating patient: $e');
    }
  }

  Future<List<dynamic>> getAllPatients() async {
    try {
      final response = await _dio.get(ApiConstants.patients);
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('Error fetching patients: $e');
    }
  }

  Future<Map<String, dynamic>> updatePatient(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('${ApiConstants.patients}/$id', data: data);
      return response.data;
    } catch (e) {
      throw Exception('Error updating patient: $e');
    }
  }

  Future<void> deletePatient(int id) async {
    try {
      await _dio.delete('${ApiConstants.patients}/$id');
    } catch (e) {
      throw Exception('Error deleting patient: $e');
    }
  }
}
