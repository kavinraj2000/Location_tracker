part of 'locationbloc.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object> get props => [];
}

class RequestLocationPermission extends LocationEvent {}

class GetCurrentLocation extends LocationEvent {}

class StartLocationUpdates extends LocationEvent {}

class StopLocationUpdates extends LocationEvent {}

class ClearAllLocations extends LocationEvent {}

class LocationUpdated extends LocationEvent {
  final double latitude;
  final double longitude;
  final int? speed;

  const LocationUpdated({required this.latitude, required this.longitude, this.speed});

  @override
  List<Object> get props => [latitude, longitude, speed ?? 0];
}
