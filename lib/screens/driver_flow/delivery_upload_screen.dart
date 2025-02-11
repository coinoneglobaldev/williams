import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:williams/common/custom_overlay_loading.dart';
import 'package:williams/models/delivery_save_model.dart';
import 'package:williams/services/api_services.dart';

import '../../constants.dart';
import '../../custom_widgets/custom_scaffold_driver.dart';
import '../../custom_widgets/util_class.dart';
import '../../models/daily_drop_list_model.dart';

class DeliveryUploadScreen extends StatefulWidget {
  final DailyDropListModel deliveryItem;

  const DeliveryUploadScreen({
    super.key,
    required this.deliveryItem,
  });

  @override
  State<DeliveryUploadScreen> createState() => _DeliveryUploadScreenState();
}

class _DeliveryUploadScreenState extends State<DeliveryUploadScreen> {
  final List<File?> _images = List.filled(3, null);
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;
  ApiServices apiServices = ApiServices();
  List<XFile> selectedXFiles = [];
  List<String> uploadedImagesName = [];

  @override
  void initState() {
    super.initState();
    _fnGenerateXFiles();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fnCheckLocationEmptyOrNot();
    });
  }

  void _fnGenerateXFiles() async {
    ByteData byteData = await rootBundle.load('assets/images/warning.png');
    Uint8List bytes = byteData.buffer.asUint8List();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File tempFile = File('$tempPath/warning.png');
    await tempFile.writeAsBytes(bytes);
    XFile nullImage = XFile(tempFile.path);
    selectedXFiles = [nullImage, nullImage, nullImage];
    uploadedImagesName = ['none.png', 'none.png', 'none.png'];
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
          showDialog(
            barrierColor: Colors.black.withValues(alpha: 0.8),
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return const CustomOverlayLoading();
            },
          );
          await updateCustomerLocation(
            latitude: position.latitude.toString(),
            longitude: position.longitude.toString(),
          ).whenComplete(() {
            Navigator.pop(context);
          });
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
          selectedXFiles[index] = photo;
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
                    "Failed to update location.",
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
    if (imagesCount < 1) {
      Util.customErrorSnackBar(
        context,
        "Please take  photos to continue",
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
      await _uploadScreenshot();
      final result = await apiServices.fnSaveDeliveryDetails(
        prmAutoId: widget.deliveryItem.autoId,
        prmId: widget.deliveryItem.id,
        prmImage1: uploadedImagesName[0],
        prmImage2: uploadedImagesName[1],
        prmImage3: uploadedImagesName[2],
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
        prmAutoId: widget.deliveryItem.autoId,
      );
      if (!mounted) return result;
      if (result.message == "Success") {
        Util.customSuccessSnackBar(context, "Location updated successfully!");
        Navigator.pop(context); // recheck if needed to pop
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
    return Container(
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
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffoldDriver(
      title: 'Delivery Upload',
      bodyWidget: Column(
        children: [
          Expanded(
            child: GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              children: [
                // Only show the required number of image containers
                ...List.generate(
                  3,
                  (index) => _buildImageContainer(index),
                ),
              ],
            ),
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
            onPressed: () => uploadDeliveryPhoto(),
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
                  isUploading ? 'Uploading...' : 'Complete Delivery',
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
              'Complete your delivery and capture proof of delivery)',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _uploadScreenshot() async {
    try {
      log('Uploading ${selectedXFiles.length} images...');
      if (selectedXFiles.isEmpty) {
        throw Exception('No images selected');
      }
      setState(() {
        isUploading = true;
      });

      int i = 0;
      for (final image in selectedXFiles) {
        final directory = await getApplicationDocumentsDirectory();
        final String imageUrl =
            '${widget.deliveryItem.refNo}-${image.path.split('/').last}';
        uploadedImagesName[i] = imageUrl;

        final File newImage = await File(image.path).copy(
          '${directory.path}/$imageUrl',
        );

        final selectedImage = XFile(newImage.path);
        await ApiServices().fnUploadFiles(
          imageNameWithType: imageUrl,
          image: selectedImage,
          sketchNameWithType: '',
          videoNameWithType: '',
          sketch: null,
          video: null,
        );
        i++;
      }

      setState(() {
        isUploading = false;
      });
      if (mounted) {
        Util.customSuccessSnackBar(context, 'Images uploaded successfully');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
        Util.customErrorSnackBar(
            context, 'Failed to upload screenshot: ${e.toString()}');
      }
    }
  }
}
