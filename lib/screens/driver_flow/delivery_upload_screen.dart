import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:williams/models/delivery_save_model.dart';
import 'package:williams/services/api_services.dart';
import '../../constants.dart';
import '../../custom_widgets/custom_scaffold_driver.dart';
import '../../custom_widgets/util_class.dart';
import '../../models/daily_drop_list_model.dart';

class DeliveryUploadScreen extends StatefulWidget {
  final DailyDropListModel deliveryItem;
  final int requiredImages;

  const DeliveryUploadScreen({
    super.key,
    required this.deliveryItem,
    this.requiredImages = 3,
  });

  @override
  State<DeliveryUploadScreen> createState() => _DeliveryUploadScreenState();
}

class _DeliveryUploadScreenState extends State<DeliveryUploadScreen> {
  final List<File?> _images = List.filled(3, null);
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;
  ApiServices apiServices = ApiServices();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fnCheckLocationEmptyOrNot();
    });
  }

  void _showLocationRequiredDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: Colors.grey.shade900,
            title: Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
            content: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _checkAndRequestLocation();
                },
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Exit App',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _checkAndRequestLocation() async {
    try {
      bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationEnabled) {
        if (!mounted) return;
        _showLocationRequiredDialog(
          'Location Services Disabled',
          'Please turn on location services from the quick tiles / settings and retry.',
        );
      } else {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever ||
            permission == LocationPermission.unableToDetermine) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied ||
              permission == LocationPermission.deniedForever ||
              permission == LocationPermission.unableToDetermine) {
            if (!mounted) return;
            _showLocationRequiredDialog(
              'Location Permission Required',
              'This app requires location permission to function. Please grant location permission to continue.',
            );
          }
        } else {
          Position position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          );
          await updateCustomerLocation(
            latitude: position.latitude.toString(),
            longitude: position.longitude.toString(),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting location: $e");
      }
      if (!mounted) return;
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              backgroundColor: Colors.grey.shade900,
              titleTextStyle: const TextStyle(color: Colors.white),
              contentTextStyle: const TextStyle(color: Colors.white),
              title: const Text(
                "Error !",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                ),
              ),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Ok",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Future<void> _takePhoto(int index) async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _images[index] = File(photo.path);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error taking photo: $e");
      }
      if (!mounted) return;
      Util.customErrorSnackBar(context, "Failed to take photo");
    }
  }

  void _fnCheckLocationEmptyOrNot() {
    if (!mounted) return;
    if (widget.deliveryItem.latitude.isEmpty ||
        widget.deliveryItem.longitude.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Location not found'),
          content: const Text('Please update the customer location.'),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await _checkAndRequestLocation();
                } catch (e) {
                  if (!context.mounted) return;
                  Util.customErrorSnackBar(
                    context,
                    "Failed to update location.\n(${e.toString()})",
                  );
                }
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    }
  }

  bool _validateImages() {
    int imagesCount = _images.where((image) => image != null).length;
    if (imagesCount < widget.requiredImages) {
      Util.customErrorSnackBar(
        context,
        "Please take ${widget.requiredImages} photos to continue",
      );
      return false;
    }
    return true;
  }

  Future<CommonResponseModel> uploadDeliveryPhoto() async {
    if (!_validateImages()) {
      throw Exception("Required number of photos not taken");
    }

    setState(() {
      isUploading = true;
    });

    try {
      // Here you would need to modify your API service to handle multiple images
      final result = await apiServices.fnSaveDeliveryDetails(
        prmAutoId: widget.deliveryItem.autoId,
        prmId: widget.deliveryItem.id,
        prmImage1: '', // TODO: Handle multiple images in API
        prmImage2: '', // TODO: Handle multiple images in API
        prmImage3: '', // TODO: Handle multiple images in API
        prmDeliveryRemarks: 'remarks',
        prmCmpId: widget.deliveryItem.companyId,
        prmBrId: widget.deliveryItem.branchId,
        prmFaId: widget.deliveryItem.faId,
        prmUId: widget.deliveryItem.userId,
      );

      if (!mounted) return result;
      if (result.message == "Success") {
        Util.customSuccessSnackBar(context, "Photos uploaded successfully!");
        Navigator.pop(context);
        return result;
      } else {
        throw Exception("Upload failed: ${result.message}");
      }
    } catch (e) {
      if (!mounted) rethrow;
      Util.customErrorSnackBar(
        context,
        "Failed to upload photos.\n(${e.toString()})",
      );
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  Future<CommonResponseModel> updateCustomerLocation({
    required String latitude,
    required String longitude,
  }) async {
    try {
      final result = await apiServices.fnUpdateCustomerLocation(
        prmAccId: widget.deliveryItem.crId,
        prmLatitude: latitude,
        prmLongitude: longitude,
      );
      if (!mounted) return result;
      if (result.message == "Success") {
        Util.customSuccessSnackBar(context, "Location updated successfully!");
        Navigator.pop(context);// recheck if needed to pop
        return result;
      } else {
        throw Exception("Update location failed: ${result.message}");
      }
    } catch (e) {
      Util.customErrorSnackBar(
        context,
        "Failed to update location.\n(${e.toString()})",
      );
      rethrow;
    }
  }

  Widget _buildImageContainer(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: MediaQuery.of(context).size.width * 0.4,
      height: MediaQuery.of(context).size.width * 0.4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade200,
            Colors.blue.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100,
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _takePhoto(index),
          child: Center(
            child: _images[index] == null
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt,
                  size: 80,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 10),
                Text(
                  'Photo ${index + 1}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
                : Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    _images[index]!,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () => _takePhoto(index),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffoldDriver(
      title: 'Delivery Upload',
      bodyWidget: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Only show the required number of image containers
                ...List.generate(
                  widget.requiredImages,
                      (index) => _buildImageContainer(index),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  onPressed: isUploading ? null : uploadDeliveryPhoto,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isUploading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      else
                        const Icon(Icons.cloud_upload),
                      const SizedBox(width: 10),
                      Text(
                        isUploading ? 'Uploading...' : 'Upload Photos',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_images.every((image) => image == null))
                  Text(
                    'Complete your delivery and capture proof of delivery\n(${widget.requiredImages} photos required)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}