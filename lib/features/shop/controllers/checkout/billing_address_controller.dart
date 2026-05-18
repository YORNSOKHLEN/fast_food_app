import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../utils/popups/loaders.dart';

class BillingAddressController extends GetxController {
  static BillingAddressController get instance => Get.find();

  // Observable variables
  final Rx<String> address = Rx<String>('No shipping address selected');
  // Start empty so the customer can input their phone if not available from profile
  final Rx<String> phoneNumber = Rx<String>('');
  final Rx<LatLng> selectedLocation = Rx<LatLng>(const LatLng(11.5564, 104.9282)); // Phnom Penh default
  final isLoadingLocation = false.obs;
  final hasLocationPermission = false.obs;
  final isPhoneValid = true.obs;
  final phoneErrorMessage = Rx<String>('');

  // Form key and text controller
  late GlobalKey<FormState> formKey;
  late TextEditingController phoneController;

  @override
  void onInit() {
    super.onInit();
    formKey = GlobalKey<FormState>();
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

  /// Show map picker dialog to select location
  Future<void> showMapPicker() async {
    setLoading(true);

    // Get current location
    final currentLocation = await getCurrentLocation();
    if (currentLocation != null) {
      updateLocation(currentLocation);
    }

    setLoading(false);

    // Show a dialog with an interactive map. The user can tap to place a marker
    // or move the camera; the confirm button sets the selected location.
    LatLng tempLocation = getSelectedLocation();
    GoogleMapController? mapController;

    Get.dialog(
      AlertDialog(
        contentPadding: const EdgeInsets.all(8),
        title: const Text('Select Delivery Location'),
        content: SizedBox(
          height: 500,
          width: double.maxFinite,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: tempLocation,
                      zoom: 15,
                    ),
                    onMapCreated: (ctrl) async {
                      mapController = ctrl;
                      // Move camera to current selection
                      await mapController?.moveCamera(
                        CameraUpdate.newLatLng(tempLocation),
                      );
                    },
                    onTap: (LatLng latLng) {
                      tempLocation = latLng;
                      setState(() {});
                    },
                    onCameraMove: (position) {
                      // Update temp location as camera moves (optional)
                      tempLocation = position.target;
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('selected_location'),
                        position: tempLocation,
                        infoWindow: const InfoWindow(title: 'Selected Location'),
                        draggable: true,
                        onDragEnd: (latLng) {
                          tempLocation = latLng;
                          setState(() {});
                        },
                      ),
                    },
                    myLocationEnabled: hasLocationPermission.value,
                    myLocationButtonEnabled: hasLocationPermission.value,
                    zoomControlsEnabled: true,
                  ),

                  // Center marker UI hint
                  Center(
                    child: IgnorePointer(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Icon(
                          Icons.location_on,
                          size: 48,
                          color: Colors.red.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Open external Google Maps app at the temporary location
              await openInGoogleMaps(tempLocation);
            },
            child: const Text('Open in Maps'),
          ),
          TextButton(
            onPressed: () {
              // Save the temporary selection as the controller's selected location
              updateLocation(tempLocation);
              Get.back();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  /// Open the given location in the external Google Maps app or browser
  Future<void> openInGoogleMaps(LatLng loc) async {
    try {
      final lat = loc.latitude;
      final lng = loc.longitude;

      // Try geo: URI first (opens native app on Android)
      final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
        return;
      }

      // Try native iOS URL scheme for Google Maps
      final iosUri = Uri.parse('comgooglemaps://?q=$lat,$lng');
      if (await canLaunchUrl(iosUri)) {
        await launchUrl(iosUri, mode: LaunchMode.externalApplication);
        return;
      }

      // Fallback to Google Maps web
      final mapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
      if (await canLaunchUrl(mapsUrl)) {
        await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
        return;
      }

      YLoaders.errorSnackBar(title: 'Unable to Open Maps', message: 'No application found to open maps.');
    } catch (e) {
      YLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Validate phone number and form
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }
}
