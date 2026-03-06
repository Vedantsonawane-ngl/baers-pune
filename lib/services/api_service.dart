import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/blood_request_api_model.dart';

class ApiService {
  static const _base = AppConfig.baseUrl;

  // ── Fetch all active requests (optional filters) ──────────────────────

  static Future<List<BloodRequestApiModel>> fetchRequests({
    String? bloodGroup,
    String? urgency,
  }) async {
    final uri = Uri.parse('$_base/requests/').replace(
      queryParameters: {
        if (bloodGroup != null && bloodGroup.isNotEmpty)
          'blood_group': bloodGroup,
        if (urgency != null && urgency.isNotEmpty) 'urgency': urgency,
      },
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['requests'] as List)
          .map((e) => BloodRequestApiModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load requests: ${response.statusCode}');
  }

  // ── Create a new blood request ────────────────────────────────────────

  static Future<BloodRequestApiModel> createRequest({
    required String bloodGroup,
    required String reason,
    required String urgency,
    required int unitsRequired,
    required String hospitalName,
    String hospitalCity = 'Pune',
    String neededIn = 'Needed ASAP',
  }) async {
    final uri = Uri.parse('$_base/requests/');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'blood_group': bloodGroup,
            'reason': reason,
            'urgency': urgency,
            'units_required': unitsRequired,
            'hospital_name': hospitalName,
            'hospital_city': hospitalCity,
            'needed_in': neededIn,
          }),
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode == 201) {
      return BloodRequestApiModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to create request: ${response.statusCode}');
  }

  // ── Cancel a request ──────────────────────────────────────────────────

  static Future<void> cancelRequest(int id) async {
    final uri = Uri.parse('$_base/requests/$id/cancel/');
    final response = await http.post(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw Exception('Failed to cancel request: ${response.statusCode}');
    }
  }

  // ── Donor responds to a request ───────────────────────────────────────

  static Future<BloodRequestApiModel> respondToRequest(int id) async {
    final uri = Uri.parse('$_base/requests/$id/respond/');
    final response = await http.post(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode == 200) {
      return BloodRequestApiModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to respond: ${response.statusCode}');
  }
}
