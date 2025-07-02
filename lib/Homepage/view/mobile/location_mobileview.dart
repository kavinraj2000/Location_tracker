import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:locationtracker/Homepage/bloc/locationbloc.dart';
import 'package:locationtracker/Homepage/model/location_request_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationMobileview extends StatelessWidget {
  const LocationMobileview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationBloc, LocationState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: Text(
            'Test App',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.grey[800],
          elevation: 0,
        ),
        body: Column(children: [_buildButtonSection(context), _buildLocationList()]),
      ),
    );
  }

  Widget _buildButtonSection(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        final isLoading = state.status == LocationStatus.loading;
        final isTracking = state.isLocationUpdateActive;

        return Container(
          color: Colors.grey[800],
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildButton(
                context,
                'Request Location Permission',
                Colors.blue,
                isLoading ? null : () => context.read<LocationBloc>().add(RequestLocationPermission()),
                isLoading,
              ),
              SizedBox(height: 12),
              _buildButton(
                context,
                'Request Notification Permission',
                Colors.yellow,
                isLoading ? null : () => _requestNotificationPermission(context),
                isLoading,
              ),
              SizedBox(height: 12),
              _buildButton(
                context,
                'Start Location Update',
                isTracking ? Colors.grey : Colors.green,
                (isLoading || isTracking) ? null : () => _showConfirmationDialog(context),
                isLoading,
              ),
              SizedBox(height: 12),
              _buildButton(
                context,
                'Stop Location Update',
                !isTracking ? Colors.grey : Colors.red,
                (isLoading || !isTracking) ? null : () => context.read<LocationBloc>().add(StopLocationUpdates()),
                isLoading,
              ),
              SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm'),
        content: Text('Do you want to start location updates?'),
        actions: [
          TextButton(child: Text('NO'), onPressed: () => Navigator.pop(context, false)),
          TextButton(child: Text('YES'), onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    );

    if (result == true) {
      context.read<LocationBloc>().add(StartLocationUpdates());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location update started'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _requestNotificationPermission(BuildContext context) async {
    try {
      final status = await Permission.notification.status;

      if (status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification permission already granted'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final result = await Permission.notification.request();

      if (result.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification permission granted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (result.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification permission denied'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (result.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permission permanently denied. Enable from settings.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(label: 'Settings', textColor: Colors.white, onPressed: () => openAppSettings()),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error requesting permission: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildButton(BuildContext context, String text, Color color, VoidCallback? onPressed, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        child: isLoading && onPressed != null
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
      ),
    );
  }

  Widget _buildLocationList() {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        return Expanded(
          child: state.requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_searching, size: 64, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text('No location data yet', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                      SizedBox(height: 8),
                      Text(
                        'Request location permission and start tracking',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: state.requests.length,
                  itemBuilder: (context, index) {
                    final request = state.requests[index];
                    _saveToPrefs(request);
                    return _buildRequestCard(request);
                  },
                ),
        );
      },
    );
  }

  Future<void> _saveToPrefs(LocationRequest request) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'last_location',
      '${request.latitude},${request.longitude},${request.speed},${request.timestamp}',
    );
  }

  Widget _buildRequestCard(LocationRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  request.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Lat: ${request.latitude?.toStringAsFixed(5) ?? "N/A"}',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey[700]),
                ),
              ),
              Expanded(
                child: Text(
                  'Lng: ${request.longitude?.toStringAsFixed(5) ?? "N/A"}',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey[700]),
                ),
              ),
              Expanded(
                child: Text(
                  'Speed: ${request.speed?.toString() ?? "N/A"}',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
