import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:locationtracker/Homepage/model/location_request_model.dart';

part 'locationevent.dart';
part 'locationstate.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  StreamSubscription<Position>? _positionStreamSubscription;

  LocationBloc() : super(const LocationState()) {
    on<RequestLocationPermission>(_onRequestLocationPermission);
    on<GetCurrentLocation>(_onGetCurrentLocation);
    on<StartLocationUpdates>(_onStartLocationUpdates);
    on<StopLocationUpdates>(_onStopLocationUpdates);
    on<ClearAllLocations>(_onClearAllLocations);
    on<LocationUpdated>(_onLocationUpdated);
  }

  @override
  Future<void> close() {
    _positionStreamSubscription?.cancel();
    return super.close();
  }

  Future<void> _onRequestLocationPermission(RequestLocationPermission event, Emitter<LocationState> emit) async {
    emit(state.copyWith(status: LocationStatus.loading));

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        emit(
          state.copyWith(
            status: LocationStatus.error,
            errorMessage: 'Location permission denied permanently. Please enable in settings.',
          ),
        );
        return;
      }

      if (permission == LocationPermission.denied) {
        emit(state.copyWith(status: LocationStatus.error, errorMessage: 'Location permission denied.'));
        return;
      }

      emit(state.copyWith(status: LocationStatus.success, successMessage: 'Location permission granted!'));
    } catch (e) {
      emit(state.copyWith(status: LocationStatus.error, errorMessage: 'Error requesting location permission: $e'));
    }
  }

  Future<void> _onGetCurrentLocation(GetCurrentLocation event, Emitter<LocationState> emit) async {
    emit(state.copyWith(status: LocationStatus.loading));

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(
          state.copyWith(
            status: LocationStatus.error,
            errorMessage: 'Location services are disabled. Please enable them.',
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        emit(
          state.copyWith(
            status: LocationStatus.error,
            errorMessage: 'Location permission not granted. Please request permission first.',
          ),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      final newRequest = LocationRequest(
        name: 'Current Location',
        latitude: position.latitude,
        longitude: position.longitude,
        speed: position.speed != null ? '${(position.speed * 3.6).toStringAsFixed(1)} m' : 'N/A',
        timestamp: DateTime.now().toString().substring(11, 19),
      );

      final updatedRequests = [newRequest, ...state.requests];

      emit(
        state.copyWith(
          status: LocationStatus.success,
          requests: updatedRequests,
          successMessage: 'Current location retrieved successfully!',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: LocationStatus.error, errorMessage: 'Error getting current location: $e'));
    }
  }

  Future<void> _onStartLocationUpdates(StartLocationUpdates event, Emitter<LocationState> emit) async {
    if (state.isLocationUpdateActive) return;

    emit(state.copyWith(status: LocationStatus.loading));

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(
          state.copyWith(
            status: LocationStatus.error,
            errorMessage: 'Location services are disabled. Please enable them.',
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        emit(
          state.copyWith(
            status: LocationStatus.error,
            errorMessage: 'Location permission not granted. Please request permission first.',
          ),
        );
        return;
      }

      const LocationSettings locationSettings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10);

      _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position position) {
          add(
            LocationUpdated(latitude: position.latitude, longitude: position.longitude, speed: position.speed.toInt()),
          );
        },
        onError: (error) {
          add(StopLocationUpdates());
          emit(state.copyWith(status: LocationStatus.error, errorMessage: 'Error in location stream: $error'));
        },
      );

      emit(
        state.copyWith(
          status: LocationStatus.tracking,
          isLocationUpdateActive: true,
          successMessage: 'Location updates started!',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: LocationStatus.error, errorMessage: 'Error starting location updates: $e'));
    }
  }

  Future<void> _onStopLocationUpdates(StopLocationUpdates event, Emitter<LocationState> emit) async {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;

    emit(
      state.copyWith(
        status: LocationStatus.success,
        isLocationUpdateActive: false,
        successMessage: 'Location updates stopped!',
      ),
    );
  }

  Future<void> _onClearAllLocations(ClearAllLocations event, Emitter<LocationState> emit) async {
    emit(state.copyWith(status: LocationStatus.success, requests: [], successMessage: 'All location data cleared!'));
  }

  Future<void> _onLocationUpdated(LocationUpdated event, Emitter<LocationState> emit) async {
    int requestCounter = 0;

    requestCounter++;

    final newRequest = LocationRequest(
      name: 'Request $requestCounter',
      latitude: event.latitude,
      longitude: event.longitude,
      speed: event.speed != null ? '${(event.speed! * 3).toStringAsFixed(1)} m' : 'N/A',
      timestamp: DateTime.now().toString().substring(11, 19),
    );

    final updatedRequests = [newRequest, ...state.requests];

    emit(state.copyWith(status: LocationStatus.tracking, requests: updatedRequests));
  }
}
