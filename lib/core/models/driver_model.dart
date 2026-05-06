enum DriverVehicleType { bike, motorcycle }

class DriverAccount {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DriverVehicleType vehicleType;
  final bool isOnline;
  final double? lat;
  final double? lng;
  final int todayDeliveries;
  final double todayEarnings;

  const DriverAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.vehicleType,
    this.isOnline = false,
    this.lat,
    this.lng,
    this.todayDeliveries = 0,
    this.todayEarnings = 0,
  });

  DriverAccount copyWith({
    bool? isOnline,
    double? lat,
    double? lng,
    int? todayDeliveries,
    double? todayEarnings,
  }) => DriverAccount(
        id: id,
        name: name,
        email: email,
        phone: phone,
        vehicleType: vehicleType,
        isOnline: isOnline ?? this.isOnline,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        todayDeliveries: todayDeliveries ?? this.todayDeliveries,
        todayEarnings: todayEarnings ?? this.todayEarnings,
      );
}
