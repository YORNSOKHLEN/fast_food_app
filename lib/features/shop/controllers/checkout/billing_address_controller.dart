import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import '../../../../utils/popups/loaders.dart';

class BillingAddressController extends GetxController {
  static BillingAddressController get instance => Get.find();

  // Observable variables
  final Rx<String> address = Rx<String>('No shipping address selected');
  final Rx<String> phoneNumber = Rx<String>('+855-96-280-7801');
  final Rx<LatLng> selectedLocation = Rx<LatLng>(const LatLng(11.5564, 104.9282)); // Phnom Penh default
  final isLoadingLocation = false.obs;
  final hasLocationPermission = false.obs;

  // Text controller for phone number
  late TextEditingController phoneController;

  @override
  void onInit() {
    super.onInit();
    phoneController = TextEditingController(text: phoneNumber.value);
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  /// Get current location
  Future<LatLng?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        hasLocationPermission.value = false;
        YLoaders.warningSnackBar(
          title: 'Location Services Disabled',
          message: 'Please enable location services to use this feature.',
        );
        return null;
      }

      // Request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          hasLocationPermission.value = false;
          YLoaders.warningSnackBar(
            title: 'Permission Denied',
            message: 'Location permission is required to select delivery address.',
          );
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        hasLocationPermission.value = false;
        YLoaders.warningSnackBar(
          title: 'Permission Denied Forever',
          message: 'Please enable location permission from app settings.',
        );
        Geolocator.openLocationSettings();
        return null;
      }

      hasLocationPermission.value = true;

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      hasLocationPermission.value = false;
      YLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to get location: ${e.toString()}',
      );
      return null;
    }
  }

  /// Update selected location
  void updateLocation(LatLng location) {
    selectedLocation.value = location;
    address.value = 'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}';
  }

  /// Update phone number
  void updatePhoneNumber(String phone) {
    phoneNumber.value = phone;
  }

  /// Set loading state
  void setLoading(bool loading) {
    isLoadingLocation.value = loading;
  }

  /// Get phone number
  String getPhoneNumber() => phoneNumber.value;

  /// Get selected location
  LatLng getSelectedLocation() => selectedLocation.value;

  /// Get address
  String getAddress() => address.value;
}

