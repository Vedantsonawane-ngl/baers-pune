import '../widgets/blood_request_card.dart';

/// Mirrors the Django `BloodRequest` model returned by `/api/requests/`.
class BloodRequestApiModel {
  final int id;
  final String bloodGroup;
  final String reason;
  final String urgency; // 'emergency' | 'high' | 'normal'
  final int unitsRequired;
  final String hospitalName;
  final String hospitalCity;
  final String neededIn;
  final bool isActive;
  final int donorsResponding;
  final String? createdAt;

  const BloodRequestApiModel({
    required this.id,
    required this.bloodGroup,
    required this.reason,
    required this.urgency,
    required this.unitsRequired,
    required this.hospitalName,
    required this.hospitalCity,
    required this.neededIn,
    required this.isActive,
    required this.donorsResponding,
    this.createdAt,
  });

  factory BloodRequestApiModel.fromJson(Map<String, dynamic> json) {
    return BloodRequestApiModel(
      id: json['id'] as int,
      bloodGroup: json['blood_group'] as String,
      reason: json['reason'] as String,
      urgency: json['urgency'] as String,
      unitsRequired: json['units_required'] as int,
      hospitalName: json['hospital_name'] as String,
      hospitalCity: json['hospital_city'] as String? ?? 'Pune',
      neededIn: json['needed_in'] as String? ?? 'Needed ASAP',
      isActive: json['is_active'] as bool? ?? true,
      donorsResponding: json['donors_responding'] as int? ?? 0,
      createdAt: json['created_at'] as String?,
    );
  }

  /// Convert to the `BloodRequest` type used in the donor dashboard cards.
  BloodRequest toDonorCard() {
    return BloodRequest(
      bloodGroup: bloodGroup,
      hospitalName: hospitalName,
      distance: hospitalCity,
      neededBy: neededIn,
      urgency: _toUrgencyLevel(urgency),
    );
  }

  static UrgencyLevel _toUrgencyLevel(String u) {
    switch (u) {
      case 'emergency':
        return UrgencyLevel.critical;
      case 'high':
        return UrgencyLevel.high;
      default:
        return UrgencyLevel.normal;
    }
  }
}
