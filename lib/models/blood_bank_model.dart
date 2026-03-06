class BloodBankModel {
  final String name;
  final String city;
  final String state;
  final String logoInitials;
  final Map<String, int> inventory;

  const BloodBankModel({
    required this.name,
    required this.city,
    required this.state,
    required this.logoInitials,
    required this.inventory,
  });
}

enum SosUrgency { critical, high, normal }

class BloodBankSosRequest {
  final String id;
  final String hospitalName;
  final String location;
  final String bloodGroup;
  final int unitsNeeded;
  final String neededIn;
  final String distance;
  final String message;
  final double lat;
  final double lng;
  final SosUrgency urgency;
  bool isResponded;
  bool isRejected;

  BloodBankSosRequest({
    required this.id,
    required this.hospitalName,
    required this.location,
    required this.bloodGroup,
    required this.unitsNeeded,
    required this.neededIn,
    required this.distance,
    required this.message,
    required this.lat,
    required this.lng,
    required this.urgency,
    this.isResponded = false,
    this.isRejected = false,
  });
}
