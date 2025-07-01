class LocationRequest {
  final String name;
  final double latitude;
  final double longitude;
  final String speed;
  final String accuracy;
  final String timestamp;

  LocationRequest({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.accuracy,
    required this.timestamp,
  });
}
