import 'package:dio/dio.dart';

import '../models/patient_api_model.dart';
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
          if (medicalRecordNumber != null && medicalRecordNumber.isNotEmpty)
            'medicalRecordNumber': medicalRecordNumber,
          if (chronicDiseases != null && chronicDiseases.isNotEmpty) 'chronicDiseases': chronicDiseases,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Map<String, dynamic>.from(response.data as Map);
      } else {
        throw Exception('Failed to create patient: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error creating patient: $e');
    }
  }

  Future<List<dynamic>> getAllPatients({int page = 1, int pageSize = 200}) async {
    try {
      final response = await _dio.get(
        ApiConstants.patients,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('Error fetching patients: $e');
    }
  }

  Future<PatientApiModel> getPatientById(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.patients}/$id');
      return PatientApiModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } catch (e) {
      throw Exception('Error fetching patient: $e');
    }
  }

  Future<void> updatePatient(int id, Map<String, dynamic> data) async {
    try {
      await _dio.put('${ApiConstants.patients}/$id', data: data);
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
