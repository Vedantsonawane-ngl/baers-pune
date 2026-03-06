class HospitalModel {
  final String name;
  final String city;
  final String state;
  final String logoInitials;

  const HospitalModel({
    required this.name,
    required this.city,
    required this.state,
    required this.logoInitials,
  });
}

enum HospitalRequestUrgency { emergency, high, normal }

class HospitalBloodRequest {
  final String id;
  final String bloodGroup;
  final String reason;
  final String neededIn;
  final int unitsRequired;
  final int donorsResponding;
  final double progressPercent;
  final HospitalRequestUrgency urgency;
  bool isCancelled;

  HospitalBloodRequest({
    required this.id,
    required this.bloodGroup,
    required this.reason,
    required this.neededIn,
    required this.unitsRequired,
    required this.donorsResponding,
    required this.progressPercent,
    required this.urgency,
    this.isCancelled = false,
  });
}

enum DonorResponseStatus { pending, accepted, denied }

class DonorResponse {
  final String id;
  final String donorName;
  final String bloodGroup;
  final String distance;
  final String phone;
  final String requestId; // links to HospitalBloodRequest.id
  final String requestReason;
  DonorResponseStatus status;

  DonorResponse({
    required this.id,
    required this.donorName,
    required this.bloodGroup,
    required this.distance,
    required this.phone,
    required this.requestId,
    required this.requestReason,
    this.status = DonorResponseStatus.pending,
  });
}

class NearbyBloodBank {
  final String name;
  final String distance;
  final Map<String, int> availableUnits; // e.g. {'A+': 4, 'B+': 2}

  const NearbyBloodBank({
    required this.name,
    required this.distance,
    required this.availableUnits,
  });
}

class BloodShortagePrediction {
  final String bloodGroup;
  final double predictedDemand;
  final double predictedAvailable;
  final String shortageRisk; // HIGH / MEDIUM / LOW
  final double shortageProbability;

  const BloodShortagePrediction({
    required this.bloodGroup,
    required this.predictedDemand,
    required this.predictedAvailable,
    required this.shortageRisk,
    required this.shortageProbability,
  });

  factory BloodShortagePrediction.fromJson(Map<String, dynamic> json) {
    return BloodShortagePrediction(
      bloodGroup: json['blood_group'] as String,
      predictedDemand: (json['predicted_demand'] as num).toDouble(),
      predictedAvailable: (json['predicted_available'] as num).toDouble(),
      shortageRisk: json['shortage_risk'] as String,
      shortageProbability: (json['shortage_probability'] as num).toDouble(),
    );
  }
}
