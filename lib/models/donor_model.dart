class DonorModel {
  final String fullName;
  final String phone;
  final String bloodGroup;
  final String city;
  final double weight;
  final DateTime? lastDonationDate;
  final bool isEmergencyDonor;

  const DonorModel({
    required this.fullName,
    required this.phone,
    required this.bloodGroup,
    required this.city,
    required this.weight,
    this.lastDonationDate,
    required this.isEmergencyDonor,
  });

  String get firstName => fullName.trim().split(' ').first;

  String get formattedLastDonation {
    if (lastDonationDate == null) return 'N/A';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${lastDonationDate!.day} ${months[lastDonationDate!.month - 1]} ${lastDonationDate!.year}';
  }
}
