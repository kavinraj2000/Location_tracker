part of 'locationbloc.dart';

enum LocationStatus { initial, loading, success, error, tracking }

class LocationState extends Equatable {
  final LocationStatus status;
  final List<LocationRequest> requests;
  final bool isLocationUpdateActive;
  final String? errorMessage;
  final String? successMessage;

  const LocationState({
    this.status = LocationStatus.initial,
    this.requests = const [],
    this.isLocationUpdateActive = false,
    this.errorMessage,
    this.successMessage,
  });

  LocationState copyWith({
    LocationStatus? status,
    List<LocationRequest>? requests,
    bool? isLocationUpdateActive,
    String? errorMessage,
    String? successMessage,
  }) {
    return LocationState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      isLocationUpdateActive: isLocationUpdateActive ?? this.isLocationUpdateActive,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [status, requests, isLocationUpdateActive, errorMessage, successMessage];
}
